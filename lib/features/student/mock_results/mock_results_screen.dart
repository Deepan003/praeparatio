import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/exam_result_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/exam_provider.dart';
import '../../../providers/student_provider.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/stat_card.dart';

class MockResultsScreen extends ConsumerStatefulWidget {
  const MockResultsScreen({super.key});

  @override
  ConsumerState<MockResultsScreen> createState() => _MockResultsScreenState();
}

class _MockResultsScreenState extends ConsumerState<MockResultsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;
    if (user == null) return const SizedBox.shrink();

    return Column(
      children: [
        Container(
          color: AppColors.neuSurface,
          child: TabBar(
            controller: _tabs,
            tabs: const [
              Tab(text: 'My Performance'),
              Tab(text: 'Leaderboard'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _MyPerformance(userId: user.id),
              _Leaderboard(userId: user.id, batch: user.batch),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
class _MyPerformance extends ConsumerWidget {
  final String userId;
  const _MyPerformance({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(studentResultsProvider(userId));

    return resultsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (results) {
        if (results.isEmpty) {
          return const Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.emoji_events_outlined, size: 60, color: AppColors.textHint),
              SizedBox(height: 12),
              Text('No exam results yet. Take a test!',
                  style: TextStyle(color: AppColors.textHint)),
            ]),
          );
        }

        final sorted =
            List<ExamResultModel>.from(results)
              ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

        final avgScore = results
                .map((r) => r.percentage)
                .reduce((a, b) => a + b) /
            results.length;
        final best =
            results.map((r) => r.neetScore).reduce((a, b) => a > b ? a : b);
        final totalCorrect = results.fold<int>(0, (s, r) => s + r.correctCount);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary stats
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  StatCard(
                      label: 'Tests Taken',
                      value: '${results.length}',
                      icon: Icons.quiz_outlined,
                      color: AppColors.primary),
                  StatCard(
                      label: 'Avg Score',
                      value: '${avgScore.toStringAsFixed(1)}%',
                      icon: Icons.analytics_outlined,
                      color: AppColors.info),
                  StatCard(
                      label: 'Best NEET Score',
                      value: '$best',
                      icon: Icons.emoji_events_outlined,
                      color: AppColors.success),
                ],
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: 24),

              // Performance over time
              SolidCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Score Trend',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    const Text('All first attempts, oldest → newest',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: _TrendChart(results: sorted.reversed.toList()),
                    ),
                  ],
                ),
              ).animate(delay: 100.ms).fadeIn(duration: 300.ms),
              const SizedBox(height: 24),

              // Correct / Incorrect / Skipped donut
              SolidCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Overall Answer Breakdown',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: _BreakdownDonut(results: results),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _LegendItem('Correct', AppColors.success,
                                  results.fold<int>(
                                      0, (s, r) => s + r.correctCount)),
                              const SizedBox(height: 8),
                              _LegendItem('Incorrect', AppColors.error,
                                  results.fold<int>(
                                      0, (s, r) => s + r.incorrectCount)),
                              const SizedBox(height: 8),
                              _LegendItem('Skipped', AppColors.warning,
                                  results.fold<int>(
                                      0, (s, r) => s + r.unattemptedCount)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate(delay: 200.ms).fadeIn(duration: 300.ms),
              const SizedBox(height: 24),

              // Recent results list
              const Text('Recent Results',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ...sorted.take(15).map((r) => _ResultRow(result: r)),
            ],
          ),
        );
      },
    );
  }
}

class _TrendChart extends StatelessWidget {
  final List<ExamResultModel> results;
  const _TrendChart({required this.results});

  @override
  Widget build(BuildContext context) {
    final spots = results
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.percentage))
        .toList();

    return LineChart(LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppColors.primary,
          barWidth: 2.5,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
              show: true, color: AppColors.primary.withOpacity(0.08)),
        ),
      ],
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (v, _) => Text('${v.toInt()}%',
                style: const TextStyle(fontSize: 9)),
          ),
        ),
        bottomTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) =>
            const FlLine(color: AppColors.border, strokeWidth: 1),
      ),
      borderData: FlBorderData(show: false),
      minY: 0,
      maxY: 100,
    ));
  }
}

class _BreakdownDonut extends StatelessWidget {
  final List<ExamResultModel> results;
  const _BreakdownDonut({required this.results});

  @override
  Widget build(BuildContext context) {
    final correct = results.fold<int>(0, (s, r) => s + r.correctCount);
    final incorrect = results.fold<int>(0, (s, r) => s + r.incorrectCount);
    final skipped = results.fold<int>(0, (s, r) => s + r.unattemptedCount);
    final total = correct + incorrect + skipped;
    if (total == 0) return const SizedBox.shrink();

    return PieChart(PieChartData(
      sectionsSpace: 2,
      centerSpaceRadius: 40,
      sections: [
        PieChartSectionData(
            value: correct.toDouble(),
            color: AppColors.success,
            title: '',
            radius: 28),
        PieChartSectionData(
            value: incorrect.toDouble(),
            color: AppColors.error,
            title: '',
            radius: 28),
        PieChartSectionData(
            value: skipped.toDouble(),
            color: AppColors.warning,
            title: '',
            radius: 28),
      ],
    ));
  }
}

Widget _LegendItem(String label, Color color, int count) => Row(
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500)),
        const Spacer(),
        Text('$count',
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );

class _ResultRow extends StatelessWidget {
  final ExamResultModel result;
  const _ResultRow({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.neuSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _scoreColor(result.percentage).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${result.percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: _scoreColor(result.percentage)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.examTitle.isEmpty ? 'Online Exam' : result.examTitle,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  DateFormat('MMM d, yyyy').format(result.submittedAt),
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'NEET: ${result.neetScore}',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w800,
                    color: AppColors.primary),
              ),
              Text(
                '✅${result.correctCount}  ❌${result.incorrectCount}  ⏭${result.unattemptedCount}',
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _scoreColor(double pct) =>
      pct >= 70 ? AppColors.success : pct >= 40 ? AppColors.warning : AppColors.error;
}

// ─────────────────────────────────────────────
class _Leaderboard extends ConsumerWidget {
  final String userId;
  final String batch;
  const _Leaderboard({required this.userId, required this.batch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allResultsAsync = ref.watch(batchStudentsProvider(batch));

    return allResultsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (students) {
        return FutureBuilder<List<_LeaderEntry>>(
          future: _buildEntries(students),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final entries = snap.data!
              ..sort((a, b) => b.avgScore.compareTo(a.avgScore));

            if (entries.isEmpty) {
              return const Center(
                child: Text('No data yet',
                    style: TextStyle(color: AppColors.textHint)),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: entries.length,
              itemBuilder: (_, i) {
                final e = entries[i];
                final isMe = e.studentId == userId;
                final rank = i + 1;

                return AnimatedContainer(
                  duration: 200.ms,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: isMe
                        ? const LinearGradient(
                            colors: [
                              AppColors.primarySurface,
                              AppColors.neuSurface
                            ],
                          )
                        : null,
                    color: isMe ? null : AppColors.neuSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color:
                          isMe ? AppColors.primary : AppColors.border,
                      width: isMe ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      _RankBadge(rank: rank),
                      const SizedBox(width: 12),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primarySurface,
                        child: Text(
                          e.name.isNotEmpty ? e.name[0].toUpperCase() : '?',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  e.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: isMe
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                if (isMe) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius:
                                          BorderRadius.circular(4),
                                    ),
                                    child: const Text('YOU',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800)),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              '${e.examCount} exams  •  Avg ${e.avgScore.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Best: ${e.bestScore}',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary),
                          ),
                          const Text(
                            'NEET marks',
                            style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate(delay: (i * 30).ms).fadeIn(duration: 200.ms);
              },
            );
          },
        );
      },
    );
  }

  Future<List<_LeaderEntry>> _buildEntries(List<dynamic> students) async {
    final entries = <_LeaderEntry>[];
    for (final s in students) {
      final results =
          await SupabaseService.instance.getFirstAttemptResults(s.id);
      if (results.isEmpty) continue;
      final avg = results.map((r) => r.percentage).reduce((a, b) => a + b) /
          results.length;
      final best =
          results.map((r) => r.neetScore).reduce((a, b) => a > b ? a : b);
      entries.add(_LeaderEntry(
        studentId: s.id,
        name: s.name,
        avgScore: avg,
        bestScore: best,
        examCount: results.length,
      ));
    }
    return entries;
  }
}

class _LeaderEntry {
  final String studentId, name;
  final double avgScore;
  final int bestScore, examCount;
  _LeaderEntry(
      {required this.studentId,
      required this.name,
      required this.avgScore,
      required this.bestScore,
      required this.examCount});
}

class _RankBadge extends StatelessWidget {
  final int rank;
  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    if (rank <= 3) {
      const medals = ['🥇', '🥈', '🥉'];
      return Text(medals[rank - 1], style: const TextStyle(fontSize: 28));
    }
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.neuBackground,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Text(
          '$rank',
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
