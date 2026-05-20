import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uuid/uuid.dart';
import '../../../services/badge_service.dart';
import '../../../services/haptic_service.dart';
import '../../../core/constants/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/exam_result_model.dart';
import '../../../models/question_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/exam_provider.dart';
import '../../../models/notification_model.dart';
import '../../../services/notification_service.dart';
import '../../../services/supabase_service.dart';
import '../../../services/toast_service.dart';
import '../../../widgets/coin_rain.dart';
import '../../../widgets/custom_button.dart';

const _uuid = Uuid();

class CBTPortal extends ConsumerStatefulWidget {
  final String examId;
  final List<QuestionModel>? questions;  // for PYQ mode
  final int? durationMinutes;            // for PYQ mode
  /// When true, any saved in-progress state is discarded → fresh retake
  final bool forceNew;

  const CBTPortal({
    super.key,
    required this.examId,
    this.questions,
    this.durationMinutes,
    this.forceNew = false,
  });

  @override
  ConsumerState<CBTPortal> createState() => _CBTPortalState();
}

class _CBTPortalState extends ConsumerState<CBTPortal> with WidgetsBindingObserver {
  ExamResultModel? _result;
  List<QuestionModel> _questions = [];
  int _currentIndex = 0;
  Timer? _timer;
  int _remainingSeconds = 0;
  int _totalSeconds = 0; // used to compute warning thresholds
  bool _loading = true;
  bool _submitting = false;
  bool _submitted = false;
  String? _resultId;
  Map<String, String> _answers = {};
  Map<String, bool> _flagged = {};
  final Stopwatch _stopwatch = Stopwatch();
  // Tracks which percentage-remaining warnings have already fired
  final Set<int> _warnedAt = {}; // stores threshold values: 50, 20, 10

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Block non-urgent toasts while exam is active
    ToastService.instance.setExamActive(true);
    BadgeService.isExamActive = true;
    _initialize();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _saveProgress();
    }
  }

  Future<void> _initialize() async {
    final user = ref.read(authProvider).value;
    if (user == null) return;

    _resultId = _uuid.v4();

    // PYQ mode — questions passed directly, skip all Supabase
    if (widget.questions != null) {
      _questions = widget.questions!;
      _remainingSeconds = (widget.durationMinutes ?? 90) * 60;
      _totalSeconds = _remainingSeconds;
      _result = ExamResultModel(
        id: _resultId!,
        examId: widget.examId,
        studentId: user.id,
        totalQuestions: _questions.length,
        submittedAt: DateTime.now(),
        isInProgress: true,
        startedAt: DateTime.now(),
        remainingSeconds: _remainingSeconds,
        examTitle: 'PYQ Test',
        examType: 'pyq',
      );
      setState(() => _loading = false);
      _startTimer();
      return;
    }

    // Fetch exam first so we know the total duration
    final exam = await SupabaseService.instance.getExam(widget.examId);
    if (exam == null && !mounted) return;
    final examDurationSecs = (exam?.durationMinutes ?? 90) * 60;
    _totalSeconds = examDurationSecs;
    // Initialise remaining to full duration now — overwritten if resuming
    _remainingSeconds = examDurationSecs;

    // Regular exam mode — check for resume (unless forceNew = brand-new retake)
    if (!widget.forceNew) {
      // Scoped to this exact exam — robust detection even on old DB schemas
      final inProgress = await SupabaseService.instance
          .getInProgressForExam(user.id, widget.examId);

      if (inProgress != null) {
        int serverRemaining;

        final anchor = inProgress.startedAt ?? inProgress.submittedAt;
        // Compare strictly in UTC to avoid local timezone drift.
        final elapsed = DateTime.now().toUtc().difference(anchor.toUtc()).inSeconds;
        
        // If elapsed is negative, it means the stored timestamp was affected by the legacy 
        // local-to-UTC Supabase parser bug. In that case, we fall back to the last known 
        // remainingSeconds to prevent the timer from resetting to the full duration.
        if (elapsed < 0 && inProgress.remainingSeconds > 0) {
          serverRemaining = inProgress.remainingSeconds;
        } else {
          // Standard continuation: time keeps ticking even if the app was closed.
          // clamp to ensure we don't go below 0 or above total duration.
          final safeElapsed = elapsed < 0 ? 0 : elapsed;
          serverRemaining = (examDurationSecs - safeElapsed).clamp(0, examDurationSecs);
        }

        debugPrint('[CBT] Resume: anchor=$anchor elapsed=${elapsed}s '
            'remaining=${serverRemaining}s answers=${inProgress.answers.length}');

        // If startedAt was missing, patch it so future resumes are accurate
        if (inProgress.startedAt == null) {
          inProgress.startedAt = anchor;
          SupabaseService.instance.upsertResult(inProgress);
        }

        debugPrint('[CBT] Resuming: answers=${inProgress.answers.length} '
            'remaining=${serverRemaining}s startedAt=${inProgress.startedAt}');

        setState(() {
          _result        = inProgress;
          _resultId      = inProgress.id;
          _answers       = Map.from(inProgress.answers);
          _remainingSeconds = serverRemaining;
        });
      }
    } else {
      // forceNew=true — clear any stale in-progress so fresh attempt begins
      try {
        await SupabaseService.instance
            .clearInProgressForExam(user.id, widget.examId);
      } catch (e) {
        debugPrint('[CBT] clearInProgress error (non-fatal): $e');
      }
    }

    _questions = await SupabaseService.instance.getQuestionsForExam(widget.examId);
    // If no in-progress was loaded (new attempt or retake), ensure full duration.
    // _result is null for new/retake; non-null means we resumed with serverRemaining.
    if (_result == null) {
      _remainingSeconds = examDurationSecs;
    }

    if (_questions.isEmpty) {
      setState(() => _loading = false);
      return;
    }

    if (_result == null) {
      // New attempt or retake — create the in-progress record
      final now = DateTime.now().toUtc();
      _result = ExamResultModel(
        id: _resultId!,
        examId: widget.examId,
        studentId: user.id,
        totalQuestions: _questions.length,
        submittedAt: now,
        isInProgress: true,
        startedAt: now,         // anchor for server-side time computation
        remainingSeconds: _remainingSeconds,
        examTitle: exam?.title ?? 'Exam',
        examType: 'online',
      );
      try {
        await SupabaseService.instance.upsertResult(_result!);
        debugPrint('[CBT] New attempt created: ${_result!.id} '
            'startedAt=$now duration=${_remainingSeconds}s');
      } catch (e) {
        // DB error (likely missing column) — still let the exam run in-memory
        // but the student's progress won't be recoverable if they leave.
        debugPrint('[CBT] WARNING: could not save in-progress record: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Warning: progress auto-save unavailable. '
                'Do not close the app mid-exam.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ));
        }
      }
    }

    setState(() => _loading = false);

    // If student comes back after time already expired, auto-submit immediately
    // instead of showing the exam UI for 1 second before the timer fires
    if (_remainingSeconds <= 0 && !_submitted) {
      _autoSubmit();
      return;
    }

    _startTimer();
  }

  void _startTimer() {
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      // Simple decrement — reliable and works in all Flutter environments.
      // Server accuracy is already handled in _initialize():
      //   • on resume → _remainingSeconds = totalSeconds - elapsed(since startedAt)
      //   • on new exam → _remainingSeconds = full duration, startedAt = now
      // So the countdown always starts from the right value.
      if (_remainingSeconds <= 0) {
        _timer?.cancel();
        _autoSubmit();
        return;
      }

      if (mounted) setState(() => _remainingSeconds--);

      // Save every 10 seconds so remainingSeconds in DB stays close to real value
      final elapsed = _stopwatch.elapsed.inSeconds;
      if (elapsed > 0 && elapsed % 10 == 0) _saveProgress();

      _checkTimeWarnings();
    });
  }

  // ── PrepCoin reward dialog ───────────────────────────────────
  Future<void> _showCoinRewardDialog(int earned, int deducted, double scorePct) async {
    final perf = scorePct >= 80
        ? 'Excellent work!'
        : scorePct >= 60
            ? 'Great job!'
            : scorePct >= 40
                ? 'Good effort!'
                : 'Keep practising!';
    final net = earned - deducted;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated coin icon
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.elasticOut,
                builder: (_, v, child) => Transform.scale(scale: v, child: child),
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.4),
                        blurRadius: 24, spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🪙', style: TextStyle(fontSize: 38)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                builder: (_, v, child) =>
                    Opacity(opacity: v, child: child),
                child: Column(children: [
                  Text(perf,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 16),

                  // Coin breakdown
                  if (deducted > 0)
                    _CoinRow(Icons.remove_circle_rounded, '−$deducted', 'Exam entry cost', AppColors.error),
                  if (earned > 0) ...[
                    if (deducted > 0) const SizedBox(height: 6),
                    _CoinRow(Icons.add_circle_rounded, '+$earned', 'Completion bonus', AppColors.success),
                  ],
                  if (deducted > 0 && earned > 0) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(),
                    ),
                    _CoinRow(
                      net >= 0 ? Icons.account_balance_wallet_rounded : Icons.warning_amber_rounded,
                      net >= 0 ? '+$net net' : '$net net',
                      'PrepCoins change',
                      net >= 0 ? AppColors.accent : AppColors.error,
                      large: true,
                    ),
                  ] else if (earned > 0) ...[
                    const SizedBox(height: 4),
                    Text('+$earned PrepCoins added!',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.accent)),
                  ],

                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.infoSurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'First attempt only — retakes neither cost nor earn coins.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 11, color: AppColors.info, height: 1.4),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => Navigator.pop(dx),
                  child: const Text('View Results',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _checkTimeWarnings() {
    if (_totalSeconds <= 0 || !mounted) return;
    final pctRemaining = (_remainingSeconds / _totalSeconds * 100).round();

    // Warn at 50%, 20%, 10% remaining
    for (final threshold in [50, 20, 10]) {
      if (pctRemaining <= threshold && !_warnedAt.contains(threshold)) {
        _warnedAt.add(threshold);
        _showTimeWarning(threshold);
      }
    }
  }

  void _showTimeWarning(int pctRemaining) {
    // Use toast instead of SnackBar — swipeable and non-blocking
    final msg = pctRemaining <= 10
        ? 'Only 10% time left! Submit soon!'
        : pctRemaining <= 20
            ? '20% time remaining — wrap up!'
            : 'Half the time is up. Keep pace!';
    final type = pctRemaining <= 10
        ? NotificationType.lowCoinBalance  // red — reuse warning color
        : NotificationType.coinsDeducted;  // orange-ish
    ToastService.instance.showTimeWarning(msg, type);
  }

  Future<void> _saveProgress() async {
    if (_result == null || _submitted || widget.questions != null) return;
    _result!.answers = Map.from(_answers);
    _result!.remainingSeconds = _remainingSeconds;
    try {
      await SupabaseService.instance.upsertResult(_result!);
    } catch (e) {
      debugPrint('[CBT] _saveProgress error: $e');
    }
  }

  void _selectAnswer(String questionId, String option) {
    setState(() {
      if (_answers[questionId] == option) {
        _answers.remove(questionId);
      } else {
        _answers[questionId] = option;
      }
    });
    // Save immediately on every answer - ensures state is current on resume
    _saveProgress();
  }

  void _toggleFlag(String questionId) {
    setState(() => _flagged[questionId] = !(_flagged[questionId] ?? false));
  }

  Future<void> _confirmSubmit() async {
    final unanswered = _questions.where((q) => !_answers.containsKey(q.id)).length;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dx) => AlertDialog(
        title: const Text('Submit Exam?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Answered: ${_questions.length - unanswered}/${_questions.length}'),
            if (unanswered > 0)
              Text('Unanswered: $unanswered', style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Once submitted, you cannot re-enter this exam.'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dx, false), child: const Text('Continue Exam')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () { HapticService.submit(); Navigator.pop(dx, true); },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (confirmed == true) _submit();
  }

  Future<void> _autoSubmit() async {
    if (_submitted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Time up! Submitting...'), backgroundColor: AppColors.error));
    await _submit();
  }

  Future<void> _submit() async {
    if (_submitted || _submitting) return;
    _timer?.cancel();
    setState(() => _submitting = true);

    final user = ref.read(authProvider).value;
    if (user == null) {
      // Session expired mid-exam — stop submitting gracefully
      setState(() => _submitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Session expired. Please log in again.'),
          backgroundColor: Colors.red,
        ));
      }
      return;
    }
    // Use local stopwatch — timezone-independent, avoids Supabase UTC parsing issues
    final timeSpent = _stopwatch.elapsed.inSeconds.clamp(0, 86400);

    int correct = 0, incorrect = 0, unattempted = 0;
    for (final q in _questions) {
      final ans = _answers[q.id];
      if (ans == null) { unattempted++; }
      else if (ans == q.correctOption) { correct++; }
      else { incorrect++; }
    }

    final neetScore = (correct * 4) - incorrect;

    final result = ExamResultModel(
      id: _resultId!,
      examId: widget.examId,
      studentId: user.id,
      score: neetScore,
      totalQuestions: _questions.length,
      answers: Map.from(_answers),
      timeTakenSeconds: timeSpent,
      submittedAt: DateTime.now(),
      correctCount: correct,
      incorrectCount: incorrect,
      unattemptedCount: unattempted,
      dataRetained: true,
      examTitle: _result?.examTitle ?? 'Exam',
      examType: _result?.examType ?? 'online',
      isInProgress: false,
      remainingSeconds: 0,
    );

    // PYQ mode — store result in provider, skip Supabase entirely
    if (widget.questions != null) {
      ref.read(pyqLastResultProvider.notifier).state = result;
      ref.read(pyqLastQuestionsProvider.notifier).state = List.from(_questions);
      setState(() { _submitted = true; _submitting = false; });
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => _PYQResultScreen(result: result, questions: _questions),
        ));
      }
      return;
    }

    // Regular exam — determine if this is the first completed attempt.
    // We check for any completed result (is_in_progress=false) for this student+exam.
    // If none exists, this is the first. Using the earliest-record query prevents
    // race conditions where multiple retakes both think they're first.
    final existingCompleted = await SupabaseService.instance
        .getFirstAttemptForExam(user.id, widget.examId);
    final isFirst = existingCompleted == null;
    final finalResult = ExamResultModel(
      id: result.id, examId: result.examId, studentId: result.studentId,
      score: result.score, totalQuestions: result.totalQuestions,
      answers: result.answers, timeTakenSeconds: result.timeTakenSeconds,
      submittedAt: result.submittedAt, isFirstAttempt: isFirst,
      correctCount: result.correctCount, incorrectCount: result.incorrectCount,
      unattemptedCount: result.unattemptedCount, dataRetained: true,
      examTitle: result.examTitle, examType: result.examType,
      isInProgress: false, remainingSeconds: 0,
    );
    await SupabaseService.instance.upsertResult(finalResult);

    // PrepCoin transaction — only on first attempt
    // • Deduct expRequired (entry cost)
    // • Add expGained only if credit threshold is met
    int coinsEarned = 0;
    int coinsDeducted = 0;
    if (isFirst) {
      try {
        final exam = await SupabaseService.instance.getExam(widget.examId);
        if (exam != null) {
          final u2 = await SupabaseService.instance.getUserById(user.id);
          if (u2 != null) {
            int newBalance = u2.prepcoins;

            // Deduct entry cost
            if (exam.expRequired > 0) {
              newBalance -= exam.expRequired;
              coinsDeducted = exam.expRequired;
            }

            // Check credit earning threshold
            final meetsThreshold = exam.meetsThreshold(
              answeredCount: _answers.length,
              totalQuestions: _questions.length,
              elapsedSeconds: _stopwatch.elapsed.inSeconds,
            );

            // Add reward only if threshold met
            if (exam.expGained > 0 && meetsThreshold) {
              newBalance += exam.expGained;
              coinsEarned = exam.expGained;
            }

            if (newBalance != u2.prepcoins) {
              await SupabaseService.instance.updateUserPrepcoins(
                  user.id, newBalance.clamp(0, 999999));
            }
          }
        }
      } catch (_) {}
    }

    setState(() { _submitted = true; _submitting = false; });
    BadgeService.isExamActive = false;
    if (!mounted) return;

    // Badge check after exam
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await BadgeService.instance.checkAndAward(ref, context);
        BadgeService.flushPendingDialogs(context);
      }
    });

    // ── Auto-notifications ────────────────────────────────────
    // Exam submitted confirmation (always)
    NotificationService.instance.notifyExamSubmitted(
      studentId:  user.id,
      examTitle:  finalResult.examTitle,
      examId:     widget.examId,
      neetScore:  finalResult.neetScore,
      percentage: finalResult.percentage,
    );

    // Coin notifications (first attempt only)
    if (isFirst) {
      if (coinsEarned > 0) {
        final bal = (await SupabaseService.instance.getUserById(user.id))?.prepcoins ?? 0;
        NotificationService.instance.notifyCoinsEarned(
          studentId:  user.id,
          amount:     coinsEarned,
          newBalance: bal,
          examTitle:  finalResult.examTitle,
        );
      }
      if (coinsDeducted > 0) {
        final bal = (await SupabaseService.instance.getUserById(user.id))?.prepcoins ?? 0;
        NotificationService.instance.notifyCoinsDeducted(
          studentId:  user.id,
          amount:     coinsDeducted,
          newBalance: bal,
          examTitle:  finalResult.examTitle,
        );
        // Low balance warning
        final afterBalance = bal;
        if (afterBalance < 50) {
          NotificationService.instance.notifyLowBalance(
              studentId: user.id, balance: afterBalance);
        }
      }
    }
    // ─────────────────────────────────────────────────────────

    // Show coin dialog + rain if any coin transaction happened
    if (coinsEarned > 0 || coinsDeducted > 0) {
      if (coinsEarned > 0 && mounted) {
        CoinRain.show(context, coins: coinsEarned);
      }
      await _showCoinRewardDialog(coinsEarned, coinsDeducted, finalResult.percentage);
      if (!mounted) return;
    }

    context.go('${Routes.examResult.replaceAll(':examId', widget.examId)}?resultId=${finalResult.id}');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    // Release exam-active lock — queued toasts will now flush
    ToastService.instance.setExamActive(false);
    // Fire-and-forget: the async save runs after dispose on web since the Dart
    // event loop continues. On mobile, WidgetsBindingObserver handles the same
    // via didChangeAppLifecycleState so we get two save attempts for safety.
    _saveProgress();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.neuBackground,
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text('Loading exam...', style: TextStyle(color: AppColors.textSecondary)),
        ])),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, size: 60, color: AppColors.textHint),
          const SizedBox(height: 16),
          const Text('No questions found for this exam.'),
          TextButton(onPressed: () => context.go(Routes.studentOnlineTests), child: const Text('Go Back')),
        ])),
      );
    }

    final q = _questions[_currentIndex];
    final answered = _answers[q.id];
    final isFlagged = _flagged[q.id] ?? false;
    final isLowTime = _remainingSeconds < 300; // < 5 min

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) _confirmSubmit();
      },
      child: Scaffold(
        backgroundColor: AppColors.neuBackground,
        body: SafeArea(
          child: Column(
            children: [
              // Header bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                color: AppColors.neuSurface,
                child: Row(
                  children: [
                    // Q counter — compact text saves horizontal space
                    Text(
                      '${_currentIndex + 1}/${_questions.length}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 10),
                    // Progress bar fills remaining space
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (_currentIndex + 1) / _questions.length,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Timer badge
                    _TimerBadge(
                      remainingSeconds: _remainingSeconds,
                      totalSeconds: _totalSeconds,
                      isLowTime: isLowTime,
                    ),
                    const SizedBox(width: 10),
                    GradientButton(
                        label: 'Submit',
                        onPressed: _confirmSubmit,
                        isLoading: _submitting,
                        width: 80),
                  ],
                ),
              ),

              Expanded(
                child: LayoutBuilder(builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 800;
                  return Row(
                    children: [
                      // Main question area — GestureDetector enables swipe navigation
                      Expanded(
                        flex: 7,
                        child: GestureDetector(
                          onHorizontalDragEnd: (d) {
                            if (d.primaryVelocity == null) return;
                            if (d.primaryVelocity! < -300 && _currentIndex < _questions.length - 1) {
                              setState(() => _currentIndex++);
                            } else if (d.primaryVelocity! > 300 && _currentIndex > 0) {
                              setState(() => _currentIndex--);
                            }
                          },
                          child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Question
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 36, height: 36,
                                    decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(10)),
                                    child: Center(child: Text('${_currentIndex + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(q.text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.6)),
                                  ),
                                  IconButton(
                                    icon: Icon(isFlagged ? Icons.flag : Icons.flag_outlined, color: isFlagged ? AppColors.warning : AppColors.textHint),
                                    onPressed: () => _toggleFlag(q.id),
                                    tooltip: 'Flag for review',
                                  ),
                                ],
                              ),
                              if (q.imageUrl != null && q.imageUrl!.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(top: 12, bottom: 4),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: CachedNetworkImage(
                                      imageUrl: q.imageUrl!,
                                      fit: BoxFit.contain,
                                      maxHeightDiskCache: 600,
                                      placeholder: (_, __) => Shimmer.fromColors(
                                        baseColor: AppColors.border,
                                        highlightColor: AppColors.neuSurface,
                                        child: Container(
                                          height: 180,
                                          color: AppColors.neuSurface,
                                        ),
                                      ),
                                      errorWidget: (_, __, ___) => const SizedBox.shrink(),
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 24),

                              // Options
                              ...['A', 'B', 'C', 'D'].map((opt) {
                                final text = q.optionText(opt);
                                final isSelected = answered == opt;
                                return _OptionTile(
                                  key: ValueKey('${q.id}_$opt'),
                                  option: opt,
                                  text: text,
                                  isSelected: isSelected,
                                  onTap: () => _selectAnswer(q.id, opt),
                                );
                              }),

                              const SizedBox(height: 24),

                              // Navigation
                              Row(
                                children: [
                                  if (_currentIndex > 0)
                                    OutlinedButton.icon(
                                      icon: const Icon(Icons.arrow_back, size: 16),
                                      label: const Text('Previous'),
                                      onPressed: () => setState(() => _currentIndex--),
                                    ),
                                  const Spacer(),
                                  if (_currentIndex < _questions.length - 1)
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.arrow_forward, size: 16),
                                      label: const Text('Next'),
                                      onPressed: () => setState(() => _currentIndex++),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ), // GestureDetector
                      ),

                      // Question navigator panel (wide screens)
                      if (isWide) ...[
                        const VerticalDivider(width: 1),
                        SizedBox(
                          width: 240,
                          child: _QuestionNavigator(
                            questions: _questions,
                            answers: _answers,
                            flagged: _flagged,
                            currentIndex: _currentIndex,
                            onSelect: (i) => setState(() => _currentIndex = i),
                          ),
                        ),
                      ],
                    ],
                  );
                }),
              ),

              // Mobile question navigator
              LayoutBuilder(builder: (context, constraints) {
                if (constraints.maxWidth > 800) return const SizedBox.shrink();
                return Container(
                  height: 60,
                  color: AppColors.neuSurface,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: _questions.length,
                    itemBuilder: (_, i) => _QuestionBubble(
                      key: ValueKey(_questions[i].id),
                      index: i,
                      isCurrent: i == _currentIndex,
                      isAnswered: _answers.containsKey(_questions[i].id),
                      isFlagged: _flagged[_questions[i].id] ?? false,
                      onTap: () => setState(() => _currentIndex = i),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String option;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({super.key, required this.option, required this.text, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 150.ms,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : AppColors.neuSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 8)] : null,
        ),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : AppColors.neuBackground,
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
              ),
              child: Center(child: Text(option, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: isSelected ? Colors.white : AppColors.textSecondary))),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, height: 1.5))),
          ],
        ),
      ),
    );
  }
}

class _QuestionNavigator extends StatelessWidget {
  final List<QuestionModel> questions;
  final Map<String, String> answers;
  final Map<String, bool> flagged;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  const _QuestionNavigator({required this.questions, required this.answers, required this.flagged, required this.currentIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final answered = answers.length;
    final unanswered = questions.length - answered;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: AppColors.neuBackground,
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _Legend('Answered', AppColors.primary, answered),
                _Legend('Not Answered', AppColors.border, unanswered),
                _Legend('Flagged', AppColors.warning, flagged.values.where((v) => v).length),
              ]),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, mainAxisSpacing: 6, crossAxisSpacing: 6),
            itemCount: questions.length,
            itemBuilder: (_, i) => _QuestionBubble(
              index: i,
              isCurrent: i == currentIndex,
              isAnswered: answers.containsKey(questions[i].id),
              isFlagged: flagged[questions[i].id] ?? false,
              onTap: () => onSelect(i),
            ),
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final String label;
  final Color color;
  final int count;
  const _Legend(this.label, this.color, this.count);

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(height: 2),
      Text('$count', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
      Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
    ],
  );
}

class _QuestionBubble extends StatelessWidget {
  final int index;
  final bool isCurrent;
  final bool isAnswered;
  final bool isFlagged;
  final VoidCallback onTap;

  const _QuestionBubble({super.key, required this.index, required this.isCurrent, required this.isAnswered, required this.isFlagged, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color bg, borderColor;
    if (isCurrent) { bg = AppColors.primary; borderColor = AppColors.primary; }
    else if (isFlagged) { bg = AppColors.warningSurface; borderColor = AppColors.warning; }
    else if (isAnswered) { bg = AppColors.primarySurface; borderColor = AppColors.primary.withOpacity(0.4); }
    else { bg = AppColors.neuBackground; borderColor = AppColors.border; }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle, border: Border.all(color: borderColor)),
        child: Center(child: Text('${index + 1}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isCurrent ? Colors.white : AppColors.textPrimary))),
      ),
    );
  }
}

// ── Inline PYQ result screen (no Supabase, self-contained) ─────
class _PYQResultScreen extends StatefulWidget {
  final ExamResultModel result;
  final List<QuestionModel> questions;
  const _PYQResultScreen({required this.result, required this.questions});

  @override
  State<_PYQResultScreen> createState() => _PYQResultScreenState();
}

class _PYQResultScreenState extends State<_PYQResultScreen> {
  bool _showReview = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final pct = r.percentage;
    final Color sc = pct >= 70 ? AppColors.success : pct >= 40 ? AppColors.warning : AppColors.error;

    return Scaffold(
      backgroundColor: AppColors.neuBackground,
      appBar: AppBar(
        title: const Text('PYQ Result'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Score card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text(
                    pct >= 80 ? 'Excellent!' : pct >= 60 ? 'Good Job!' : pct >= 40 ? 'Keep Going!' : 'Keep Practising!',
                    style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  Text('${pct.toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('NEET Score: ${r.neetScore} marks',
                      style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.85))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Stats
            Row(children: [
              _StatBox('Correct', '${r.correctCount}', AppColors.success),
              const SizedBox(width: 10),
              _StatBox('Incorrect', '${r.incorrectCount}', AppColors.error),
              const SizedBox(width: 10),
              _StatBox('Skipped', '${r.unattemptedCount}', AppColors.warning),
            ]),
            const SizedBox(height: 16),
            // Actions
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: Icon(_showReview ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                label: Text(_showReview ? 'Hide Review' : 'Review Answers'),
                onPressed: () => setState(() => _showReview = !_showReview),
              ),
            ),
            // Answer review
            if (_showReview) ...[
              const SizedBox(height: 16),
              ...widget.questions.asMap().entries.map((e) {
                final q = e.value;
                final userAns = r.answers[q.id];
                final isCorrect = userAns == q.correctOption;
                final isSkipped = userAns == null;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.neuSurface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppColors.neuRaisedSoft,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          width: 26, height: 26,
                          decoration: BoxDecoration(
                            color: isSkipped ? AppColors.neuBackground
                                : isCorrect ? AppColors.successSurface : AppColors.errorSurface,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Center(child: Text('${e.key + 1}',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                                  color: isSkipped ? AppColors.textHint
                                      : isCorrect ? AppColors.success : AppColors.error))),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(q.text,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            maxLines: 3, overflow: TextOverflow.ellipsis)),
                        Icon(isSkipped ? Icons.remove_circle_outline
                            : isCorrect ? Icons.check_circle : Icons.cancel,
                            color: isSkipped ? AppColors.warning
                                : isCorrect ? AppColors.success : AppColors.error, size: 18),
                      ]),
                      const SizedBox(height: 8),
                      ...['A','B','C','D'].map((opt) {
                        final isUser = userAns == opt;
                        final isCorrectOpt = q.correctOption == opt;
                        Color bg = AppColors.neuBackground;
                        if (isCorrectOpt) bg = AppColors.successSurface;
                        else if (isUser) bg = AppColors.errorSurface;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
                          child: Row(children: [
                            Container(width: 20, height: 20,
                                decoration: BoxDecoration(shape: BoxShape.circle,
                                    color: isCorrectOpt ? AppColors.success : isUser ? AppColors.error : AppColors.neuBackground,
                                    border: Border.all(color: AppColors.border)),
                                child: Center(child: Text(opt, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800,
                                    color: (isCorrectOpt || isUser) ? Colors.white : AppColors.textSecondary)))),
                            const SizedBox(width: 8),
                            Expanded(child: Text(q.optionText(opt),
                                style: TextStyle(fontSize: 12, fontWeight: isCorrectOpt ? FontWeight.w600 : FontWeight.w400))),
                          ]),
                        );
                      }),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatBox(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(children: [
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ]),
        ),
      );
}

// ── Always-visible timer badge with pulse/shake on low time ──
class _TimerBadge extends StatefulWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final bool isLowTime;

  const _TimerBadge({
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.isLowTime,
  });

  @override
  State<_TimerBadge> createState() => _TimerBadgeState();
}

class _TimerBadgeState extends State<_TimerBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    if (widget.isLowTime) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_TimerBadge old) {
    super.didUpdateWidget(old);
    if (widget.isLowTime && !old.isLowTime) {
      _pulse.repeat(reverse: true);
    } else if (!widget.isLowTime && old.isLowTime) {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  String _fmt(int s) {
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final pct = widget.totalSeconds > 0
        ? widget.remainingSeconds / widget.totalSeconds
        : 1.0;
    final isCritical = widget.remainingSeconds < 300; // < 5 min
    final color = pct <= 0.10
        ? AppColors.error
        : pct <= 0.20
            ? AppColors.warning
            : AppColors.primary;
    final bgColor = pct <= 0.10
        ? AppColors.errorSurface
        : pct <= 0.20
            ? AppColors.warningSurface
            : AppColors.primarySurface;

    Widget badge = Container(
      width: 92,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.35), width: 1.5),
        boxShadow: isCritical
            ? [BoxShadow(color: color.withOpacity(0.25), blurRadius: 8, spreadRadius: 1)]
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_rounded, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            _fmt(widget.remainingSeconds),
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: color,
              fontSize: 14,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );

    if (!isCritical) return badge;

    // Pulsing scale when < 5 min remaining
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, child) => Transform.scale(
        scale: 1.0 + _pulse.value * 0.06,
        child: child,
      ),
      child: badge,
    );
  }
}

// ── Coin transaction row widget ───────────────────────────────
class _CoinRow extends StatelessWidget {
  final IconData icon;
  final String amount;
  final String label;
  final Color color;
  final bool large;
  const _CoinRow(this.icon, this.amount, this.label, this.color,
      {this.large = false});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: large ? 22 : 18),
          const SizedBox(width: 6),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(amount,
                style: TextStyle(
                    fontSize: large ? 22 : 16,
                    fontWeight: FontWeight.w900,
                    color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textSecondary)),
          ]),
        ],
      );
}
