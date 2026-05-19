import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:printing/printing.dart';
import '../../../core/constants/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/exam_model.dart';
import '../../../models/exam_result_model.dart';
import '../../../models/question_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/exam_provider.dart';
import '../../../services/pdf_service.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/coin_rain.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/stat_card.dart';

// Top-level function required by compute() — must not be a closure
Future<Uint8List> _computeTestReport(_TestReportArgs a) =>
    PdfService.studentTestReportPdf(
      exam: a.exam,
      firstAttempt: a.first,
      lastAttempt: a.last,
      studentName: a.studentName,
      batch: a.batch,
      // Skip chapter breakdown for large exams to prevent OOM on device
      questions: a.questions.length <= 60 ? a.questions : const [],
    );

class _TestReportArgs {
  final ExamModel exam;
  final ExamResultModel first;
  final ExamResultModel last;
  final String studentName;
  final String batch;
  final List<QuestionModel> questions;
  const _TestReportArgs({
    required this.exam, required this.first, required this.last,
    required this.studentName, required this.batch, required this.questions,
  });
}

class ExamResultScreen extends ConsumerStatefulWidget {
  final String examId;
  final String? resultId; // passed from GoRouter query params
  const ExamResultScreen({super.key, required this.examId, this.resultId});

  @override
  ConsumerState<ExamResultScreen> createState() => _ExamResultScreenState();
}

class _ExamResultScreenState extends ConsumerState<ExamResultScreen> {
  ExamResultModel? _result;
  ExamModel? _exam;
  List<QuestionModel> _questions = [];
  List<ExamResultModel> _myAttempts = [];
  ExamResultModel? _inProgressRetake; // non-null if student paused a retake mid-way
  bool _loading = true;
  bool _showReview = false;
  bool _downloading = false;
  // Class ranking
  int? _classRank;
  int? _classTotal;
  List<UserModel> _topScorers = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final resultId = widget.resultId;
    ExamResultModel? result;
    try {
      if (resultId != null && resultId.isNotEmpty) {
        // Direct lookup by ID — avoids is_first_attempt filter bug
        result = await SupabaseService.instance.getResultById(resultId);
      }
      // Fallback: most recent completed result for this exam
      if (result == null) {
        final all = await SupabaseService.instance.getAllResultsForExam(widget.examId);
        result = all.where((r) => !r.isInProgress).toList().lastOrNull;
      }
    } catch (_) {}
    final questions = await SupabaseService.instance
        .getQuestionsForExam(widget.examId);

    // Compute class ranking only if admin has published results
    int? rank, total;
    final topScorers = <UserModel>[];
    ExamModel? loadedExam;
    if (result != null) {
      try {
        loadedExam = await SupabaseService.instance.getExam(widget.examId);
        // Only show ranking if admin explicitly published results
        if (loadedExam != null && loadedExam.resultsPublished) {
          final allResults = await SupabaseService.instance
              .getAllResultsForExam(widget.examId);

          allResults.sort((a, b) => b.neetScore.compareTo(a.neetScore));
          total = allResults.length;
          final myIdx = allResults.indexWhere((r) => r.studentId == result!.studentId);
          if (myIdx >= 0) rank = myIdx + 1;
          for (final r in allResults.take(3)) {
            final u = await SupabaseService.instance.getUserById(r.studentId);
            if (u != null) topScorers.add(u);
          }
        }
      } catch (_) {}
    }

    // All attempts by this student for this exam
    List<ExamResultModel> myAttempts = [];
    ExamResultModel? inProgressRetake;
    if (result != null) {
      try {
        myAttempts = await SupabaseService.instance
            .getStudentResultsForExam(result.studentId, widget.examId);
      } catch (_) {}

      // Check whether the student paused a retake mid-way — if so we offer
      // "Resume Retake" instead of "Retake Exam" so they don't lose progress.
      try {
        final ip = await SupabaseService.instance
            .getInProgressForExam(result.studentId, widget.examId);
        if (ip != null && ip.isInProgress) inProgressRetake = ip;
      } catch (_) {}
    }

    // Guard against widget being disposed during multiple awaits
    if (!mounted) return;

    setState(() {
      _result = result;
      _exam = loadedExam;
      _questions = questions;
      _myAttempts = myAttempts;
      _inProgressRetake = inProgressRetake;
      _classRank = rank;
      _classTotal = total;
      _topScorers = topScorers;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_result == null) {
      return Scaffold(body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, size: 60, color: AppColors.textHint),
        const SizedBox(height: 12),
        const Text('Result not found'),
        TextButton(onPressed: () => context.go(Routes.studentOnlineTests), child: const Text('Back to Tests')),
      ])));
    }

    final result = _result!;
    final pct = result.percentage;

    // Score-adaptive palette — every accent on this screen derives from performance
    final Color scoreColor;
    final LinearGradient scoreGradient;
    final String scoreLabel;
    final String scoreEmoji;
    if (pct >= 80) {
      scoreColor   = const Color(0xFF2E7D32);
      scoreGradient = const LinearGradient(colors: [Color(0xFF43A047), Color(0xFF1B5E20)],
          begin: Alignment.topLeft, end: Alignment.bottomRight);
      scoreLabel   = 'Excellent!';
      scoreEmoji   = '🏆';
    } else if (pct >= 60) {
      scoreColor   = const Color(0xFF2E7D32);
      scoreGradient = const LinearGradient(colors: [Color(0xFF66BB6A), Color(0xFF388E3C)],
          begin: Alignment.topLeft, end: Alignment.bottomRight);
      scoreLabel   = 'Good Job!';
      scoreEmoji   = '🎯';
    } else if (pct >= 40) {
      scoreColor   = const Color(0xFFE65100);
      scoreGradient = const LinearGradient(colors: [Color(0xFFFF8F00), Color(0xFFE65100)],
          begin: Alignment.topLeft, end: Alignment.bottomRight);
      scoreLabel   = 'Keep Going!';
      scoreEmoji   = '💪';
    } else {
      scoreColor   = const Color(0xFFB71C1C);
      scoreGradient = const LinearGradient(colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
          begin: Alignment.topLeft, end: Alignment.bottomRight);
      scoreLabel   = 'Needs Work';
      scoreEmoji   = '📚';
    }

    return Scaffold(
      backgroundColor: AppColors.neuBackground,
      appBar: AppBar(
        title: const Text('Exam Result'),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.go(Routes.studentOnlineTests)),
        // Subtle accent tint in the appBar bottom border
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2, decoration: BoxDecoration(gradient: scoreGradient)),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 400 ? 16 : 24),
        child: Column(
          children: [
            // Score card — dynamic gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                gradient: scoreGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: scoreColor.withOpacity(0.30), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Row(
                children: [
                  // Animated circle
                  CircularPercentIndicator(
                    radius: 52,
                    lineWidth: 8,
                    percent: (pct / 100).clamp(0.0, 1.0),
                    center: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(scoreEmoji, style: const TextStyle(fontSize: 18)),
                      Text('${pct.toStringAsFixed(0)}%',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white)),
                    ]),
                    progressColor: Colors.white,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    animation: true,
                    animationDuration: 1100,
                    circularStrokeCap: CircularStrokeCap.round,
                  ).animate(delay: 200.ms).fadeIn().scale(begin: const Offset(0.7, 0.7), curve: Curves.elasticOut),
                  const SizedBox(width: 20),
                  // Right side info
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(scoreLabel,
                          style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      Text('NEET Score: ${result.neetScore} marks',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                      const SizedBox(height: 2),
                      // 3-zone bar: correct / wrong / unattempted
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: SizedBox(
                          height: 8,
                          child: Row(children: [
                            if (result.correctCount > 0)
                              Flexible(
                                flex: result.correctCount,
                                child: Container(color: Colors.white),
                              ),
                            if (result.incorrectCount > 0)
                              Flexible(
                                flex: result.incorrectCount,
                                child: Container(color: Colors.white.withOpacity(0.35)),
                              ),
                            if (result.unattemptedCount > 0)
                              Flexible(
                                flex: result.unattemptedCount,
                                child: Container(color: Colors.white.withOpacity(0.12)),
                              ),
                          ]),
                        ),
                      ).animate(delay: 600.ms).slideX(begin: -1, duration: 700.ms, curve: Curves.easeOut),
                      const SizedBox(height: 4),
                      Text('✓ ${result.correctCount}  ✗ ${result.incorrectCount}  — ${result.unattemptedCount}',
                          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.85))),
                    ],
                  )),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
            const SizedBox(height: 20),

            // Compact stats row
            Row(children: [
              _CompactStat('${result.correctCount}', 'Correct', AppColors.success, Icons.check_circle_outline),
              const SizedBox(width: 8),
              _CompactStat('${result.incorrectCount}', 'Wrong', AppColors.error, Icons.cancel_outlined),
              const SizedBox(width: 8),
              _CompactStat('${result.unattemptedCount}', 'Skipped', AppColors.warning, Icons.remove_circle_outline),
              const SizedBox(width: 8),
              _CompactStat(_formatTime(result.timeTakenSeconds), 'Time', AppColors.info, Icons.timer_outlined),
            ]),

            // ── Class ranking (shown only after admin publishes) ──
            const SizedBox(height: 16),
            if (_classRank != null && _classTotal != null)
              _ClassRankCard(
                rank: _classRank!,
                total: _classTotal!,
                topScorers: _topScorers,
              ).animate(delay: 200.ms).fadeIn(duration: 400.ms)
            else
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.neuBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(children: [
                  Icon(Icons.lock_clock_rounded, size: 16, color: AppColors.textHint),
                  SizedBox(width: 10),
                  Expanded(child: Text(
                    'Class rankings will be visible once your teacher releases them.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                  )),
                ]),
              ),

            // Chapter-wise analysis
            if (_questions.isNotEmpty) ...[
              const SizedBox(height: 16),
              _ChapterBreakdown(
                questions: _questions,
                answers: result.answers,
              ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
            ],

            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(_showReview
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    label: Text(_showReview ? 'Hide' : 'Review'),
                    onPressed: () { HapticFeedback.lightImpact(); setState(() => _showReview = !_showReview); },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _inProgressRetake != null
                      // Paused retake exists — resume it
                      ? GradientButton(
                          label: 'Resume',
                          icon: Icons.play_arrow_rounded,
                          onPressed: () { HapticFeedback.lightImpact(); context.go(Routes.cbt.replaceAll(':examId', widget.examId)); },
                        )
                      // No paused retake — fresh one
                      : GradientButton(
                          label: 'Retake',
                          icon: Icons.replay,
                          onPressed: () { HapticFeedback.lightImpact(); context.go('${Routes.cbt.replaceAll(':examId', widget.examId)}?forceNew=true'); },
                        ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Download buttons
            if (_myAttempts.isNotEmpty) ...[
              // My Test Report (always available after attempt)
              _DownloadActionBtn(
                icon: Icons.assessment_outlined,
                label: 'Download My Test Report',
                color: AppColors.info,
                loading: _downloading,
                onTap: () async {
                  setState(() => _downloading = true);
                  try {
                    final user = ref.read(authProvider).value;
                    final first = _myAttempts.first;
                    final last = _myAttempts.last;
                    // Run in separate isolate to prevent OOM on main thread
                    final bytes = await compute(
                      _computeTestReport,
                      _TestReportArgs(
                        exam: _exam ?? ExamModel(id: widget.examId, title: result.examTitle,
                            targetBatches: [], durationMinutes: 0, createdAt: DateTime.now(), createdBy: ''),
                        first: first,
                        last: last,
                        studentName: user?.name ?? '',
                        batch: user?.batch ?? '',
                        questions: _questions,
                      ),
                    );
                    await Printing.sharePdf(bytes: bytes,
                        filename: 'TestReport_${result.examTitle.replaceAll(RegExp(r"[^a-zA-Z0-9]"), "_")}.pdf');
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Download failed: $e'), backgroundColor: AppColors.error));
                  } finally {
                    if (mounted) setState(() => _downloading = false);
                  }
                },
              ),
              // Question Paper — only if admin enabled it
              if (_exam?.allowDownload == true) ...[
                const SizedBox(height: 8),
                _DownloadActionBtn(
                  icon: Icons.quiz_outlined,
                  label: 'Download Question Paper & Answer Key',
                  color: AppColors.success,
                  loading: _downloading,
                  onTap: () async {
                    setState(() => _downloading = true);
                    try {
                      final bytes = await PdfService.questionPaperPdf(
                        exam: _exam!, questions: _questions, showAnswers: true);
                      await Printing.sharePdf(bytes: bytes,
                          filename: 'QuestionPaper_${_exam!.title.replaceAll(RegExp(r"[^a-zA-Z0-9]"), "_")}.pdf');
                    } catch (e) {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Download failed: $e'), backgroundColor: AppColors.error));
                    } finally {
                      if (mounted) setState(() => _downloading = false);
                    }
                  },
                ),
              ],
            ],

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.home_outlined),
                label: const Text('Back to Tests'),
                onPressed: () => context.go(Routes.studentOnlineTests),
              ),
            ),

            // Answer review
            if (_showReview && _questions.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text('Answer Review', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ..._questions.asMap().entries.map((e) {
                final q = e.value;
                final userAns = result.answers[q.id];
                final isCorrect = userAns == q.correctOption;
                final isSkipped = userAns == null;

                return SolidCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  borderColor: isSkipped ? AppColors.border : isCorrect ? AppColors.success.withOpacity(0.3) : AppColors.error.withOpacity(0.3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: isSkipped ? AppColors.neuBackground : isCorrect ? AppColors.successSurface : AppColors.errorSurface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(child: Text('${e.key + 1}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: isSkipped ? AppColors.textHint : isCorrect ? AppColors.success : AppColors.error))),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(q.text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 3, overflow: TextOverflow.ellipsis)),
                          Icon(
                            isSkipped ? Icons.remove_circle_outline : isCorrect ? Icons.check_circle : Icons.cancel,
                            color: isSkipped ? AppColors.warning : isCorrect ? AppColors.success : AppColors.error,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Options
                      ...['A', 'B', 'C', 'D'].map((opt) {
                        final isUserAnswer = userAns == opt;
                        final isCorrectAnswer = q.correctOption == opt;
                        Color bg = AppColors.neuBackground;
                        if (isCorrectAnswer) bg = AppColors.successSurface;
                        else if (isUserAnswer && !isCorrect) bg = AppColors.errorSurface;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            children: [
                              Container(
                                width: 22, height: 22,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: isCorrectAnswer ? AppColors.success : isUserAnswer ? AppColors.error : AppColors.neuBackground, border: Border.all(color: AppColors.border)),
                                child: Center(child: Text(opt, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: (isCorrectAnswer || isUserAnswer) ? Colors.white : AppColors.textSecondary))),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(q.optionText(opt), style: TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: isCorrectAnswer ? FontWeight.w600 : FontWeight.w400))),
                              if (isCorrectAnswer) const Icon(Icons.check, color: AppColors.success, size: 14),
                              if (isUserAnswer && !isCorrectAnswer) const Icon(Icons.close, color: AppColors.error, size: 14),
                            ],
                          ),
                        );
                      }),

                      if (q.explanation != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppColors.infoSurface, borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.lightbulb_outline, color: AppColors.info, size: 14),
                              const SizedBox(width: 6),
                              Expanded(child: Text(q.explanation!, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.5))),
                            ],
                          ),
                        ),
                      ],
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

  String _formatTime(int seconds) {
    final s = seconds.clamp(0, 86400); // guard against negative/corrupt values
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m}m ${sec}s';
  }
}

class _CompactStat extends StatelessWidget {
  final String value, label;
  final Color color;
  final IconData icon;
  const _CompactStat(this.value, this.label, this.color, this.icon);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(height: 4),
              Text(value,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: color)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 9.5, color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
}

// ── Compact download action button ────────────────────────────
class _DownloadActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool loading;
  final VoidCallback onTap;
  const _DownloadActionBtn({
    required this.icon, required this.label, required this.color,
    required this.loading, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: loading ? null : onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(children: [
            loading
                ? SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(color: color, strokeWidth: 2))
                : Icon(icon, color: color, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(label,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color))),
            Icon(Icons.download_rounded, color: color.withOpacity(0.5), size: 16),
          ]),
        ),
      );
}

// ── Class rank card shown in exam result ──────────────────────
class _ClassRankCard extends StatelessWidget {
  final int rank;
  final int total;
  final List<UserModel> topScorers;
  const _ClassRankCard(
      {required this.rank, required this.total, required this.topScorers});

  @override
  Widget build(BuildContext context) {
    final medals = ['🥇', '🥈', '🥉'];
    final isTop3 = rank <= 3;
    final medal = isTop3 ? medals[rank - 1] : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isTop3
              ? [const Color(0xFFFFF3CD), const Color(0xFFFFE082)]
              : [AppColors.primarySurface, AppColors.neuSurface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: isTop3
                ? const Color(0xFFFFB300).withOpacity(0.5)
                : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            if (medal != null)
              Text(medal, style: const TextStyle(fontSize: 28)),
            if (medal != null) const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medal != null
                        ? 'You ranked #$rank in your class!'
                        : 'Your Class Rank',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isTop3
                            ? const Color(0xFF7B4F00)
                            : AppColors.textPrimary),
                  ),
                  Text('#$rank out of $total students (first attempts)',
                      style: TextStyle(
                          fontSize: 11,
                          color: isTop3
                              ? const Color(0xFF7B4F00).withOpacity(0.7)
                              : AppColors.textSecondary)),
                ],
              ),
            ),
            // Big rank badge
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: isTop3
                    ? const Color(0xFFFFB300).withOpacity(0.3)
                    : AppColors.primarySurface,
                shape: BoxShape.circle,
                border: Border.all(
                    color: isTop3
                        ? const Color(0xFFFFB300)
                        : AppColors.primary.withOpacity(0.3),
                    width: 2),
              ),
              child: Center(
                child: Text('#$rank',
                    style: TextStyle(
                        fontSize: rank > 99 ? 13 : 18,
                        fontWeight: FontWeight.w900,
                        color: isTop3
                            ? const Color(0xFF7B4F00)
                            : AppColors.primary)),
              ),
            ),
          ]),

          // Progress bar showing percentile
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total > 1 ? 1 - (rank - 1) / (total - 1) : 1,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                  isTop3 ? const Color(0xFFFFB300) : AppColors.primary),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            total > 1
                ? 'Better than ${((1 - (rank - 1) / (total - 1)) * 100).toStringAsFixed(0)}% of classmates'
                : 'First to attempt!',
            style: TextStyle(
                fontSize: 11,
                color: isTop3
                    ? const Color(0xFF7B4F00).withOpacity(0.8)
                    : AppColors.textSecondary),
          ),

          // Top scorers
          if (topScorers.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text('Top Scorers',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            ...topScorers.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(children: [
                    Text(medals[e.key],
                        style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(e.value.name,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                )),
          ],
        ],
      ),
    );
  }
}

// ── Chapter-wise performance breakdown ────────────────────────────────────────
class _ChapterBreakdown extends StatelessWidget {
  final List<QuestionModel> questions;
  final Map<String, String> answers;
  const _ChapterBreakdown({required this.questions, required this.answers});

  @override
  Widget build(BuildContext context) {
    // Group questions by chapter
    final chapterMap = <String, _ChapterStat>{};
    for (final q in questions) {
      final ch = q.chapter.isEmpty ? 'General' : q.chapter;
      chapterMap.putIfAbsent(ch, () => _ChapterStat(ch));
      chapterMap[ch]!.total++;
      final selected = answers[q.id];
      if (selected != null) {
        if (selected.toUpperCase() == q.correctOption.toUpperCase()) {
          chapterMap[ch]!.correct++;
        } else {
          chapterMap[ch]!.wrong++;
        }
      }
    }
    final chapters = chapterMap.values.toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    if (chapters.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neuSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.neuRaisedSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.bar_chart_rounded, size: 16, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Chapter-wise Analysis',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 14),
          ...chapters.map((ch) {
            final pct = ch.total > 0 ? ch.correct / ch.total : 0.0;
            final color = pct >= 0.7
                ? AppColors.success
                : pct >= 0.4
                    ? AppColors.warning
                    : AppColors.error;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(ch.name,
                          style: const TextStyle(
                              fontSize: 11.5, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    Text('${ch.correct}/${ch.total}',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: color)),
                  ]),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: color.withOpacity(0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ChapterStat {
  final String name;
  int total = 0, correct = 0, wrong = 0;
  _ChapterStat(this.name);
}
