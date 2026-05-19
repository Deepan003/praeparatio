import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Shows an exam start rules dialog.
/// Returns `true` if the student pressed "Start Exam", `false`/null otherwise.
Future<bool> showExamStartDialog(
  BuildContext context, {
  required String title,
  required int questionCount,
  required int durationMinutes,
  bool isPYQ = false,
  int coinCost = 0,
  int coinReward = 0,
  String creditMode = 'none',   // 'none'|'attempts'|'time'
  int creditThreshold = 30,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (dx) => _ExamStartDialog(
      title: title,
      questionCount: questionCount,
      durationMinutes: durationMinutes,
      isPYQ: isPYQ,
      coinCost: coinCost,
      coinReward: coinReward,
      creditMode: creditMode,
      creditThreshold: creditThreshold,
    ),
  );
  return result == true;
}

class _ExamStartDialog extends StatelessWidget {
  final String title;
  final int questionCount;
  final int durationMinutes;
  final bool isPYQ;
  final int coinCost;
  final int coinReward;
  final String creditMode;
  final int creditThreshold;

  const _ExamStartDialog({
    required this.title,
    required this.questionCount,
    required this.durationMinutes,
    required this.isPYQ,
    this.coinCost = 0,
    this.coinReward = 0,
    this.creditMode = 'none',
    this.creditThreshold = 30,
  });

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.sizeOf(context).height;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      // Reduce side margins on small phones
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 480,
          // Cap at 88% of screen height so dialog never overflows
          maxHeight: screenH * 0.88,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Scrollable content ───────────────────────────
            // Using Flexible so it shrinks when content is short
            // but scrolls when content is taller than available space.
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.quiz_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                            Text(isPYQ ? 'PYQ Practice Test' : 'Online Exam',
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // Exam info chips
                    Wrap(spacing: 6, runSpacing: 6, children: [
                      _InfoChip(Icons.quiz_outlined, '$questionCount Qs', AppColors.primary),
                      _InfoChip(Icons.timer_outlined, '$durationMinutes min', AppColors.info),
                      if (coinCost > 0)
                        _InfoChip(Icons.monetization_on_rounded, '−$coinCost coins', AppColors.error),
                      if (coinReward > 0)
                        _InfoChip(Icons.add_circle_rounded, '+$coinReward coins', AppColors.success),
                      if (coinCost == 0 && coinReward == 0 && !isPYQ)
                        const _InfoChip(Icons.check_circle_outline, 'Free', AppColors.success),
                    ]),

                    // Credit threshold note
                    if (coinReward > 0 && creditMode != 'none') ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.warningSurface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(children: [
                          const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.warning),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              creditMode == 'attempts'
                                  ? 'Earn $coinReward coins: answer ≥$creditThreshold% (${ (questionCount * creditThreshold / 100).ceil()} of $questionCount Qs).'
                                  : 'Earn $coinReward coins: spend ≥$creditThreshold% of time (${ (durationMinutes * creditThreshold / 100).ceil()} min).',
                              style: const TextStyle(fontSize: 11, color: AppColors.warning, height: 1.4),
                            ),
                          ),
                        ]),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Rules box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.neuBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(children: [
                            Icon(Icons.rule_rounded, size: 15, color: AppColors.primary),
                            SizedBox(width: 6),
                            Text('Rules',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary)),
                          ]),
                          const SizedBox(height: 10),
                          const _Rule(Icons.check_circle_rounded, 'Correct', '+4 marks', AppColors.success),
                          const _Rule(Icons.cancel_rounded, 'Wrong', '−1 mark', AppColors.error),
                          const _Rule(Icons.remove_circle_rounded, 'Unattempted', '0 marks', AppColors.warning),
                          const SizedBox(height: 8),
                          const _InfoNote(Icons.info_outline_rounded, AppColors.info,
                              'Timer starts now. Auto-submits when time is up.'),
                          if (!isPYQ) ...[
                            const SizedBox(height: 6),
                            const _InfoNote(Icons.save_rounded, AppColors.warning,
                                'Saved every 5 s. Close and resume anytime — timer keeps running.'),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // ── Action buttons — always pinned at bottom ─────
            // Outside the scroll area so they're always reachable.
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    icon: coinCost > 0
                        ? const Icon(Icons.monetization_on_rounded, size: 17)
                        : const Icon(Icons.play_arrow_rounded, size: 19),
                    label: Text(
                      coinCost > 0 ? 'Start ($coinCost coins)' : 'Start Exam',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// Compact info note row inside rules box
class _InfoNote extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _InfoNote(this.icon, this.color, this.text);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(text,
                style: TextStyle(fontSize: 10.5, color: color, height: 1.4)),
          ),
        ]),
      );
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ]),
      );
}

class _Rule extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _Rule(this.icon, this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 8),
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textPrimary))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(value,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: color)),
          ),
        ]),
      );
}
