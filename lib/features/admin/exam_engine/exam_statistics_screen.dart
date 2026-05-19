import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/exam_result_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/exam_provider.dart';
import '../../../providers/student_provider.dart';
import '../../../models/exam_model.dart';
import '../../../services/csv_service.dart';
import '../../../services/pdf_service.dart';
import '../../../widgets/download_button.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/stat_card.dart';

class ExamStatisticsScreen extends ConsumerWidget {
  final String examId;
  const ExamStatisticsScreen({super.key, required this.examId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examAsync = ref.watch(examDetailProvider(examId));
    final resultsAsync = ref.watch(examAllResultsProvider(examId));
    final studentsAsync = ref.watch(allStudentsProvider);

    return examAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (exam) => resultsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (results) => studentsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (students) {
            if (results.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bar_chart, size: 60, color: AppColors.textHint),
                    SizedBox(height: 12),
                    Text('No students have attempted this exam yet.', style: TextStyle(color: AppColors.textHint)),
                  ],
                ),
              );
            }

            final attempted = results.length;
            final scores = results.map((r) => r.neetScore).toList()..sort();
            final avg = scores.isNotEmpty ? scores.reduce((a, b) => a + b) / scores.length : 0;
            final highest = scores.isNotEmpty ? scores.last : 0;
            final lowest = scores.isNotEmpty ? scores.first : 0;
            final studentMap = {for (final s in students) s.id: s};

            return LayoutBuilder(builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              final hPad = isMobile ? 16.0 : 24.0;
              final statCols = isMobile ? 2 : 4;

              return SingleChildScrollView(
                // Extra bottom padding so content clears the admin bottom nav bar
                padding: EdgeInsets.fromLTRB(hPad, hPad, hPad, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exam?.title ?? 'Exam Statistics',
                        style: TextStyle(
                            fontSize: isMobile ? 17 : 22,
                            fontWeight: FontWeight.w800)),
                    SizedBox(height: isMobile ? 16 : 24),

                    // Stats grid — 2 cols on mobile, 4 on desktop
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: statCols,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: isMobile ? 2.2 : 1.5,
                      children: [
                        StatCard(label: 'Attempted', value: '$attempted', icon: Icons.people_outline, color: AppColors.primary),
                        StatCard(label: 'Avg Score', value: avg.toStringAsFixed(1), icon: Icons.analytics_outlined, color: AppColors.info),
                        StatCard(label: 'Highest', value: '$highest', icon: Icons.emoji_events_outlined, color: AppColors.success),
                        StatCard(label: 'Lowest', value: '$lowest', icon: Icons.arrow_downward_outlined, color: AppColors.warning),
                      ],
                    ),
                    SizedBox(height: isMobile ? 16 : 24),

                    // Score distribution chart
                    SolidCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Score Distribution',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 180,
                            child: _ScoreBarChart(
                                scores: scores,
                                total: exam?.questionIds.length ?? 0),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isMobile ? 16 : 24),

                    // Student results table
                    SolidCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Expanded(
                                child: Text('Student Results',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700))),
                            if (exam != null)
                              DownloadButton(
                                label: 'Download',
                                filename:
                                    'exam_results_${exam!.title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}',
                                csvBuilder: () async =>
                                    CsvService.exportExamResults(
                                        exam!, results, studentMap),
                                pdfBuilder: () async =>
                                    PdfService.examResultsPdf(
                                  exam: exam!,
                                  results: results,
                                  studentMap: studentMap,
                                ),
                              ),
                          ]),
                          const SizedBox(height: 12),
                          // On mobile: horizontal scroll so the table doesn't squash columns
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                  minWidth: constraints.maxWidth - hPad * 2 - 32),
                              child: Table(
                                defaultColumnWidth:
                                    const IntrinsicColumnWidth(),
                                children: [
                                  TableRow(
                                    decoration: const BoxDecoration(
                                        color: AppColors.neuBackground),
                                    children: [
                                      'Student',
                                      'Batch',
                                      'Score',
                                      'Correct',
                                      'Wrong',
                                      'Time'
                                    ]
                                        .map((h) => Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 10),
                                              child: Text(h,
                                                  style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: AppColors
                                                          .textSecondary)),
                                            ))
                                        .toList(),
                                  ),
                                  ...results.map((r) {
                                    final student = studentMap[r.studentId];
                                    return TableRow(
                                      decoration: const BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: AppColors.border))),
                                      children: [
                                        _Cell(student?.name ?? r.studentId),
                                        _Cell(student?.batch ?? ''),
                                        _Cell('${r.neetScore}',
                                            bold: true,
                                            color: r.neetScore >= 0
                                                ? AppColors.success
                                                : AppColors.error),
                                        _Cell('${r.correctCount}',
                                            color: AppColors.success),
                                        _Cell('${r.incorrectCount}',
                                            color: AppColors.error),
                                        _Cell(_formatTime(r.timeTakenSeconds)),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            });
          },
        ),
      ),
    );
  }

  Widget _Cell(String text, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Text(text, style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.w700 : FontWeight.w400, color: color ?? AppColors.textPrimary)),
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}m ${s}s';
  }
}

class _ScoreBarChart extends StatelessWidget {
  final List<int> scores;
  final int total;
  const _ScoreBarChart({required this.scores, required this.total});

  @override
  Widget build(BuildContext context) {
    // Create buckets: 0-20%, 20-40%, 40-60%, 60-80%, 80-100%
    final maxScore = total * 4;
    final buckets = [0, 0, 0, 0, 0];
    for (final s in scores) {
      final pct = maxScore > 0 ? s / maxScore : 0;
      final bucket = (pct * 5).floor().clamp(0, 4);
      buckets[bucket]++;
    }
    final labels = ['0-20%', '20-40%', '40-60%', '60-80%', '80-100%'];

    return BarChart(BarChartData(
      barGroups: List.generate(5, (i) => BarChartGroupData(
        x: i,
        barRods: [BarChartRodData(toY: buckets[i].toDouble(), color: AppColors.primary, width: 32, borderRadius: BorderRadius.circular(6))],
      )),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Text(labels[v.toInt()], style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)))),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.border, strokeWidth: 1)),
      borderData: FlBorderData(show: false),
    ));
  }
}
