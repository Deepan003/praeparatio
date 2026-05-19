import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/exam_provider.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/skeleton.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;
    if (user == null) return const SizedBox.shrink();

    // All attempts (first + retakes), capped at 10
    final resultsAsync = ref.watch(studentRecentAttemptsProvider(user.id));

    return resultsAsync.when(
      loading: () => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, __) =>
            const Padding(padding: EdgeInsets.only(bottom: 12), child: SkeletonCard(height: 88)),
      ),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (results) {
        if (results.isEmpty) {
          return const Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.history, size: 60, color: AppColors.textHint),
              SizedBox(height: 12),
              Text('No exam history yet',
                  style: TextStyle(color: AppColors.textHint, fontSize: 15)),
              SizedBox(height: 4),
              Text('Take a test to see your history here',
                  style: TextStyle(fontSize: 12, color: AppColors.textHint)),
            ]),
          );
        }

        return Column(
          children: [
            Container(
              color: AppColors.neuSurface,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Exam History',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                      Text('Last 10 attempts (first time & retakes)',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${results.length} entries',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                ),
              ]),
            ),
            // Score trend chart
            if (results.length >= 2)
              _ScoreTrendChart(results: results)
                  .animate().fadeIn(duration: 400.ms),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: results.length,
                itemBuilder: (_, i) {
                  final r = results[i];
                  final pct = r.percentage;
                  final scoreColor = pct >= 70
                      ? AppColors.success
                      : pct >= 40
                          ? AppColors.warning
                          : AppColors.error;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: AppColors.neuSurface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppColors.neuRaisedSoft,
                    ),
                    child: Row(
                      children: [
                        // Score badge
                        Container(
                          width: 64,
                          decoration: BoxDecoration(
                            color: scoreColor.withOpacity(0.10),
                            borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(16)),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${pct.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: scoreColor)),
                              Text('Score',
                                  style: TextStyle(
                                      fontSize: 9, color: scoreColor)),
                            ],
                          ),
                        ),
                        // Info
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Expanded(
                                    child: Text(
                                      r.examTitle.isEmpty ? 'Online Exam' : r.examTitle,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (!r.isFirstAttempt)
                                    Flexible(
                                      child: Container(
                                      margin: const EdgeInsets.only(left: 6),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.infoSurface,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: const Text('Retake',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.info)),
                                    ),
                                    ), // Flexible
                                ]),
                                const SizedBox(height: 3),
                                Text(
                                  DateFormat('MMM d, yyyy · h:mm a')
                                      .format(r.submittedAt),
                                  style: const TextStyle(
                                      fontSize: 10.5,
                                      color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 6),
                                Wrap(spacing: 8, children: [
                                  _Stat('✓ ${r.correctCount}', AppColors.success),
                                  _Stat('✗ ${r.incorrectCount}', AppColors.error),
                                  _Stat('NEET ${r.neetScore}', AppColors.primary),
                                ]),
                              ],
                            ),
                          ),
                        ),
                        // Review button
                        if (r.dataRetained)
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: TextButton(
                              onPressed: () => context.go(
                                  '${Routes.examResult.replaceAll(':examId', r.examId)}?resultId=${r.id}'),
                              style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6)),
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.visibility_outlined,
                                      size: 16, color: AppColors.primary),
                                  SizedBox(height: 2),
                                  Text('View',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.primary)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ).animate(delay: (i * 30).ms).fadeIn(duration: 200.ms);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

Widget _Stat(String text, Color color) => Text(text,
    style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600));

// ── Score trend chart ──────────────────────────────────────────
class _ScoreTrendChart extends StatelessWidget {
  final List results; // ExamResultModel list
  const _ScoreTrendChart({required this.results});

  @override
  Widget build(BuildContext context) {
    final sorted = [...results]
      ..sort((a, b) => (a.submittedAt as DateTime).compareTo(b.submittedAt as DateTime));

    final spots = sorted.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), (e.value.percentage as double).clamp(0, 100)))
        .toList();

    final avg = sorted.map((r) => r.percentage as double).reduce((a, b) => a + b) / sorted.length;
    final best = sorted.map((r) => r.percentage as double).reduce((a, b) => a > b ? a : b);
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neuSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.neuRaisedSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('Score Trend',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
            const Spacer(),
            _TrendChip('Avg ${avg.toStringAsFixed(0)}%', AppColors.primary),
            const SizedBox(width: 8),
            _TrendChip('Best ${best.toStringAsFixed(0)}%', AppColors.success),
          ]),
          const SizedBox(height: 12),
          SizedBox(
            height: isMobile ? 90 : 110,
            child: LineChart(LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              minY: 0, maxY: 100,
              lineTouchData: const LineTouchData(enabled: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.35,
                  color: AppColors.primary,
                  barWidth: 2.5,
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.primary.withOpacity(0.08),
                  ),
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                      radius: 4,
                      color: spot.y >= 70
                          ? AppColors.success
                          : spot.y >= 40
                              ? AppColors.warning
                              : AppColors.error,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    ),
                  ),
                ),
              ],
            )),
          ),
        ],
      ),
    );
  }
}

Widget _TrendChip(String text, Color color) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
