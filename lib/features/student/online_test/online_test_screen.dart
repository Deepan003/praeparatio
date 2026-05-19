import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../../../core/constants/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/neu_theme.dart';

import '../../../models/exam_model.dart';
import '../../../models/exam_result_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/exam_provider.dart';
import '../../../services/pdf_service.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/exam_start_dialog.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/skeleton.dart';

class OnlineTestScreen extends ConsumerStatefulWidget {
  const OnlineTestScreen({super.key});
  @override
  ConsumerState<OnlineTestScreen> createState() => _OnlineTestScreenState();
}

class _OnlineTestScreenState extends ConsumerState<OnlineTestScreen> {
  String _filter = 'all';
  String _sort = 'newest';
  @override
  void initState() {
    super.initState();
    // Streams handle real-time sync automatically now
  }

  static const _filters = [
    ('all', 'All'),
    ('new', 'New'),
    ('not_attempted', 'Pending'),
    ('attempted', 'Done'),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;
    if (user == null) return const SizedBox.shrink();
    final examsAsync = ref.watch(batchExamsProvider(user.batch));
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Column(
      children: [
        // ── Toolbar ──
        Container(
          color: context.neu.surface,
          padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 14 : 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter chips — scrollable on mobile
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ..._filters.map((f) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _FilterChip(
                        label: f.$2,
                        selected: _filter == f.$1,
                        onTap: () => setState(() => _filter = f.$1),
                      ),
                    )),
                    const SizedBox(width: 8),
                    // Progress report download
                    _ProgressReportBtn(user: user),
                    const SizedBox(width: 4),
                    // Sort dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 0),
                      decoration: BoxDecoration(
                        color: context.neu.insetFill,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: context.neu.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _sort,
                          isDense: true,
                          dropdownColor: context.neu.surface,
                          style: TextStyle(fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: context.neu.textPrimary),
                          items: const [
                            DropdownMenuItem(value: 'newest',
                                child: Text('Newest first')),
                            DropdownMenuItem(value: 'oldest',
                                child: Text('Oldest first')),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _sort = v);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: context.neu.border),

        // ── Exam list ──
        Expanded(
          child: examsAsync.when(
            loading: () => ListView.builder(
              padding: EdgeInsets.all(isMobile ? 14 : 20),
              itemCount: 3,
              itemBuilder: (_, __) => const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: SkeletonExamCard(),
              ),
            ),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (exams) {
              if (exams.isEmpty) {
                return const Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.quiz_outlined, size: 60, color: AppColors.textHint),
                    SizedBox(height: 12),
                    Text('No active tests', style: TextStyle(color: AppColors.textHint)),
                    SizedBox(height: 4),
                    Text('Check back soon!',
                        style: TextStyle(fontSize: 13, color: AppColors.textHint)),
                  ]),
                );
              }

              final sorted = _sort == 'oldest'
                  ? exams.reversed.toList() : List.from(exams);

              return FutureBuilder<List<ExamResultModel>>(
                future: SupabaseService.instance
                    .getFirstAttemptResults(
                        ref.read(authProvider).value!.id),
                builder: (_, snap) {
                  final results = snap.data ?? [];
                  final attemptedIds =
                      results.map((r) => r.examId).toSet();

                  final filtered = sorted.where((e) {
                    if (_filter == 'new') return e.isNew;
                    if (_filter == 'attempted') return attemptedIds.contains(e.id);
                    if (_filter == 'not_attempted') return !attemptedIds.contains(e.id);
                    return true;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text('No exams match this filter',
                          style: TextStyle(color: AppColors.textHint)));
                  }

                  return GridView.builder(
                    padding: EdgeInsets.all(isMobile ? 14 : 20),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 0.82, // taller cards so content fits
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final exam = filtered[i];
                      final userId = ref.read(authProvider).value?.id ?? '';
                      final firstResult = results
                          .where((r) => r.examId == exam.id)
                          .firstOrNull;
                      return _ExamCard(
                        exam: exam,
                        userId: userId,
                        userPrepcoins:
                            ref.read(authProvider).value?.prepcoins ?? 0,
                        firstResult: firstResult,
                      ).animate(delay: (i * 40).ms)
                          .fadeIn(duration: 250.ms)
                          .scale(begin: const Offset(0.92, 0.92),
                              curve: Curves.easeOut);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Progress report download button ──────────────────────────
class _ProgressReportBtn extends StatefulWidget {
  final UserModel user;
  const _ProgressReportBtn({required this.user});
  @override
  State<_ProgressReportBtn> createState() => _ProgressReportBtnState();
}

class _ProgressReportBtnState extends State<_ProgressReportBtn> {
  bool _loading = false;

  Future<void> _download() async {
    setState(() => _loading = true);
    try {
      final user = widget.user;
      // 1. All first attempt results for this student
      final results = await SupabaseService.instance.getFirstAttemptResults(user.id);
      if (results.isEmpty) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No exam attempts found yet')));
        setState(() => _loading = false);
        return;
      }
      // 2. Fetch exam models + top scores for each exam
      final examMap = <String, ExamModel>{};
      final topScores = <String, ({int topScore, int tiedCount})>{};
      for (final r in results) {
        if (!examMap.containsKey(r.examId)) {
          final e = await SupabaseService.instance.getExam(r.examId);
          if (e != null) examMap[r.examId] = e;
        }
        if (!topScores.containsKey(r.examId)) {
          topScores[r.examId] = await SupabaseService.instance
              .getTopScoreForExam(r.examId);
        }
      }
      // 3. Offline tests
      final offlineTests = await SupabaseService.instance
          .getOfflineTestsByBatch(user.batch);
      // 4. Build PDF
      final bytes = await PdfService.studentProgressReportPdf(
        student: user,
        onlineResults: results,
        examMap: examMap,
        topScores: topScores,
        offlineTests: offlineTests,
      );
      await Printing.sharePdf(bytes: bytes,
          filename: 'Progress_Report_${user.name.replaceAll(' ', '_')}.pdf');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Tooltip(
    message: 'Download My Progress Report',
    child: GestureDetector(
      onTap: _loading ? null : _download,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF8B83FF)]),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.3),
            blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: _loading
            ? const SizedBox(width: 14, height: 14,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.download_rounded, color: Colors.white, size: 14),
                SizedBox(width: 5),
                Text('My Report', style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
              ]),
      ),
    ),
  );
}

// ── Filter chip ──────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final neu = context.neu;
    return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.primaryGradient : null,
            color: selected ? null : neu.insetFill,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.primary : neu.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : neu.textSecondary,
              )),
        ),
      );
  } // build
} // _FilterChip

// ── Exam card ────────────────────────────────────────────────
class _ExamCard extends ConsumerWidget {
  final ExamModel exam;
  final String userId;
  final int userPrepcoins;
  final ExamResultModel? firstResult; // first official attempt

  const _ExamCard({
    required this.exam,
    required this.userId,
    required this.userPrepcoins,
    this.firstResult,
  });

  static const _subjectIcons = <String, IconData>{
    'bio': Icons.biotech_outlined,
    'cell': Icons.circle_outlined,
    'genetics': Icons.device_hub_outlined,
    'evolution': Icons.timeline_outlined,
    'ecology': Icons.park_outlined,
    'anatomy': Icons.accessibility_new_outlined,
    'plant': Icons.local_florist_outlined,
  };

  IconData _pickIcon() {
    final t = exam.title.toLowerCase();
    for (final e in _subjectIcons.entries) {
      if (t.contains(e.key)) return e.value;
    }
    return Icons.science_outlined;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch latest attempt (may differ from first)
    final latestAsync = firstResult != null
        ? ref.watch(latestExamResultProvider((userId, exam.id)))
        : const AsyncData<ExamResultModel?>(null);
    final latestResult = latestAsync.value;

    final isAttempted = firstResult != null;
    final canAfford = userPrepcoins >= exam.expRequired;
    final costCoins = exam.expRequired > 0;
    final pct = firstResult?.percentage ?? 0.0;
    final latestPct = latestResult?.percentage;
    final hasRetaken = latestResult != null &&
        latestResult.id != firstResult?.id;

    final tagColor = switch (exam.tag) {
      'Compulsory' => AppColors.error,
      'Revision' => AppColors.info,
      _ => AppColors.success,
    };

    return GestureDetector(
      onTap: () async {
        if (isAttempted && firstResult != null) {
          if (hasRetaken && latestResult != null) {
            _showAttemptPicker(context, firstResult!, latestResult);
          } else {
            context.go('${Routes.examResult.replaceAll(':examId', exam.id)}?resultId=${firstResult!.id}');
          }
        } else {
          // Check if there is an in-progress first attempt to resume before
          // showing the start dialog. If found, jump straight to the CBT so
          // the student cannot game the timer by sitting on the dialog.
          final inProgress = await SupabaseService.instance
              .getInProgressForExam(userId, exam.id);
          if (!context.mounted) return;

          if (inProgress != null) {
            // Resume transparently — CBT will pick up answers + server timer
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Resuming your exam — timer kept running!'),
              backgroundColor: AppColors.warning,
              duration: Duration(seconds: 3),
            ));
            context.go(Routes.cbt.replaceAll(':examId', exam.id));
            return;
          }

          // No in-progress attempt — check affordability then show start dialog
          if (!canAfford && costCoins) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Row(children: [
                const Icon(Icons.monetization_on_rounded, color: Colors.amber, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(
                  'You need ${exam.expRequired} PrepCoins to start this exam. You have $userPrepcoins coins.',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                )),
              ]),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 4),
            ));
            return;
          }

          final start = await showExamStartDialog(
            context,
            title: exam.title,
            questionCount: exam.questionIds.length,
            durationMinutes: exam.durationMinutes,
            coinCost: costCoins ? exam.expRequired : 0,
            coinReward: exam.expGained,
            creditMode: exam.creditMode,
            creditThreshold: exam.creditThreshold,
          );
          if (start && context.mounted) {
            context.go(Routes.cbt.replaceAll(':examId', exam.id));
          }
        }
      },
      // ClipRRect prevents badges/Stack children from bleeding outside the card
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SolidCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // ── Coloured top area ──────────────────────────
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      tagColor.withOpacity(0.18),
                      tagColor.withOpacity(0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  clipBehavior: Clip.antiAlias,
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_pickIcon(),
                              size: 18, color: tagColor.withOpacity(0.6)),
                          const SizedBox(height: 5),
                          // Always show question count — score is in the bottom strip
                          Text('${exam.questionIds.length}',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: isAttempted
                                      ? _scoreColor(pct)
                                      : tagColor.withOpacity(0.85))),
                          Text('Qs',
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: (isAttempted
                                      ? _scoreColor(pct)
                                      : tagColor).withOpacity(0.7),
                                  letterSpacing: 0.5)),
                        ],
                      ),
                    ),
                    // Top-left badge
                    if (exam.isNew)
                      Positioned(
                        top: 8, left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('NEW',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900)),
                        ),
                      ),
                    if (isAttempted)
                      const Positioned(
                        top: 8, right: 8,
                        child: Icon(Icons.check_circle_rounded,
                            size: 15, color: AppColors.success),
                      ),
                  ],
                ),
              ),
            ),
            // ── Info bottom ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exam.title,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          color: context.neu.textPrimary,
                          height: 1.25),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  // "1st attempt" + "Latest" shown here (below title) — no overflow risk
                  if (isAttempted) ...[
                    Row(children: [
                      Text('1st: ${pct.toStringAsFixed(0)}%',
                          style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: _scoreColor(pct))),
                      if (hasRetaken && latestPct != null) ...[
                        const SizedBox(width: 6),
                        Flexible(child: Text('Latest: ${latestPct.toStringAsFixed(0)}%',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 9.5,
                                color: _scoreColor(latestPct)))),
                      ],
                    ]),
                    const SizedBox(height: 4),
                  ],
                  Row(children: [
                    _SmallTag('${exam.durationMinutes}m', AppColors.info),
                    const SizedBox(width: 4),
                    _SmallTag(exam.difficulty, _diffColor(exam.difficulty)),
                    if (isAttempted) ...[
                      const SizedBox(width: 4),
                      _SmallTag(hasRetaken ? '2+ tries' : '1 try', context.neu.textSecondary),
                    ],
                  ]),
                  const SizedBox(height: 5),
                  // ── Action button area ─────────────────────
                  if (isAttempted)
                    const _MiniBtn('Retake', AppColors.primary, false)
                  else if (!canAfford && costCoins)
                    _InsufficientCoins(required: exam.expRequired)
                  else if (costCoins)
                    _CoinStartBtn(coins: exam.expRequired)
                  else
                    const _MiniBtn('Start', AppColors.primary, true),
                ],
              ),
            ),
          ],
        ),
        ), // SolidCard
      ), // ClipRRect
    );
  }

  Color _diffColor(String d) => switch (d) {
        'Easy' => AppColors.easy,
        'Medium' => AppColors.medium,
        'Hard' => AppColors.hard,
        _ => AppColors.neetLevel,
      };

  Color _scoreColor(double pct) =>
      pct >= 70 ? AppColors.success : pct >= 40 ? AppColors.warning : AppColors.error;

  void _showAttemptPicker(BuildContext context,
      ExamResultModel first, ExamResultModel latest) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        decoration: BoxDecoration(
          color: sheetCtx.neu.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('View Attempt Results',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text(
              'Your 1st attempt score is what is officially stored and shown to your admin.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 16),
            _AttemptRow(
              label: '1st Attempt (Official)',
              pct: first.percentage,
              neet: first.neetScore,
              isOfficial: true,
              onTap: () {
                Navigator.pop(context);
                context.go(
                    '${Routes.examResult.replaceAll(':examId', exam.id)}?resultId=${first.id}');
              },
            ),
            const SizedBox(height: 10),
            _AttemptRow(
              label: 'Latest Attempt',
              pct: latest.percentage,
              neet: latest.neetScore,
              isOfficial: false,
              onTap: () {
                Navigator.pop(context);
                context.go(
                    '${Routes.examResult.replaceAll(':examId', exam.id)}?resultId=${latest.id}');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _AttemptRow extends StatelessWidget {
  final String label;
  final double pct;
  final int neet;
  final bool isOfficial;
  final VoidCallback onTap;
  const _AttemptRow({required this.label, required this.pct, required this.neet,
      required this.isOfficial, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scoreColor = pct >= 70 ? AppColors.success : pct >= 40 ? AppColors.warning : AppColors.error;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isOfficial ? context.neu.primarySurface : context.neu.bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isOfficial ? AppColors.primary : context.neu.border,
              width: isOfficial ? 1.5 : 1),
        ),
        child: Row(children: [
          if (isOfficial)
            Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
              child: const Text('OFFICIAL',
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white)),
            ),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isOfficial ? AppColors.primary : context.neu.textPrimary)),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${pct.toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: scoreColor)),
            Text('NEET: $neet',
                style: TextStyle(fontSize: 10, color: context.neu.textSecondary)),
          ]),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded, color: context.neu.textHint, size: 18),
        ]),
      ),
    );
  }
}

// ── Coin-cost start button ────────────────────────────────────
class _CoinStartBtn extends StatelessWidget {
  final int coins;
  const _CoinStartBtn({required this.coins});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          gradient: AppColors.accentGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.monetization_on_rounded,
              color: Colors.white, size: 13),
          const SizedBox(width: 4),
          Text('$coins coins',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 11)),
        ]),
      );
}

// ── Insufficient coins state ──────────────────────────────────
class _InsufficientCoins extends StatelessWidget {
  final int required;
  const _InsufficientCoins({required this.required});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.errorSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.error.withOpacity(0.35)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.lock_outline_rounded,
              size: 11, color: AppColors.error),
          const SizedBox(width: 3),
          Text('Need $required 🪙',
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error)),
        ]),
      );
}

// ── Mini action button ────────────────────────────────────────
class _MiniBtn extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;
  const _MiniBtn(this.label, this.color, this.filled);
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          gradient: filled ? AppColors.primaryGradient : null,
          color: filled ? null : color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10),
          border: filled ? null : Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(
            filled ? Icons.play_arrow_rounded : Icons.replay_rounded,
            color: filled ? Colors.white : color,
            size: 13,
          ),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  color: filled ? Colors.white : color,
                  fontWeight: FontWeight.w800,
                  fontSize: 11)),
        ]),
      );
}

class _SmallTag extends StatelessWidget {
  final String label;
  final Color color;
  const _SmallTag(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: color)),
      );
}

// _MetaItem removed — no longer used in compact grid card design
Widget _MetaItem(IconData icon, String text, Color color) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(text, style: TextStyle(fontSize: 11, color: color,
            fontWeight: FontWeight.w600)),
      ],
    );
