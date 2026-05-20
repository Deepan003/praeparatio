import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/exam_result_model.dart';
import '../../../models/offline_test_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/exam_provider.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/skeleton.dart';

// ── Providers — both are live streams ─────────────────────────
final _offlineTestsResultProvider =
    StreamProvider.family<List<OfflineTestModel>, String>((ref, batch) {
  return SupabaseService.instance.streamOfflineTestsByBatch(batch);
});

// Students are already streaming via batchStudentsProvider but this
// local alias keeps the results screen self-contained.
final _batchStudentsForResultsProvider =
    StreamProvider.family<List<UserModel>, String>((ref, batch) {
  return SupabaseService.instance.streamStudentsByBatch(batch);
});

// ── Combined Results Screen ───────────────────────────────────
class OfflineResultsScreen extends ConsumerStatefulWidget {
  const OfflineResultsScreen({super.key});

  @override
  ConsumerState<OfflineResultsScreen> createState() =>
      _OfflineResultsScreenState();
}

class _OfflineResultsScreenState extends ConsumerState<OfflineResultsScreen>
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
        // Tab bar
        Container(
          color: AppColors.neuSurface,
          child: TabBar(
            controller: _tabs,
            tabs: const [
              Tab(text: 'Test Results'),
              Tab(text: 'Online Tests'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _OfflineTab(user: user),
              _OnlineTab(user: user),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Offline Test Results Tab ──────────────────────────────────
class _OfflineTab extends ConsumerStatefulWidget {
  final UserModel user;
  const _OfflineTab({required this.user});

  @override
  ConsumerState<_OfflineTab> createState() => _OfflineTabState();
}

class _OfflineTabState extends ConsumerState<_OfflineTab> {
  OfflineTestModel? _selected;

  @override
  Widget build(BuildContext context) {
    final testsAsync =
        ref.watch(_offlineTestsResultProvider(widget.user.batch));
    final studentsAsync =
        ref.watch(_batchStudentsForResultsProvider(widget.user.batch));

    return testsAsync.when(
      loading: () => const _LoadingSkeleton(),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (tests) {
        if (tests.isEmpty) {
          return const _EmptyState(
            icon: Icons.assignment_outlined,
            message: 'No test results yet',
            sub: 'Your admin will add results here',
          );
        }

        // Auto-select first if nothing selected
        if (_selected == null && tests.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback(
              (_) => setState(() => _selected = tests.first));
        }

        return studentsAsync.when(
          loading: () => const _LoadingSkeleton(),
          error: (_, __) => const SizedBox.shrink(),
          data: (students) {
            final studentMap = {for (final s in students) s.id: s};

            return Column(
              children: [
                // Dropdown selector
                _DropdownBar(
                  hint: 'Select a test',
                  value: _selected,
                  items: tests,
                  itemLabel: (t) =>
                      '${t.name}  ·  ${DateFormat("dd MMM yyyy").format(t.date)}',
                  onChanged: (t) => setState(() => _selected = t),
                ),
                // Detail
                Expanded(
                  child: _selected == null
                      ? const _EmptyState(
                          icon: Icons.touch_app_outlined,
                          message: 'Select a test above',
                          sub: 'to view your result',
                        )
                      : _OfflineDetail(
                          test: _selected!,
                          studentId: widget.user.id,
                          studentMap: studentMap,
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ── Online First-Attempt Results Tab ─────────────────────────
class _OnlineTab extends ConsumerStatefulWidget {
  final UserModel user;
  const _OnlineTab({required this.user});

  @override
  ConsumerState<_OnlineTab> createState() => _OnlineTabState();
}

class _OnlineTabState extends ConsumerState<_OnlineTab> {
  ExamResultModel? _selected;

  @override
  Widget build(BuildContext context) {
    // First attempts only for online exams
    final resultsAsync =
        ref.watch(studentResultsProvider(widget.user.id));

    return resultsAsync.when(
      loading: () => const _LoadingSkeleton(),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (results) {
        final onlineFirst = results
            .where((r) => !r.isInProgress && r.examType == 'online')
            .toList()
          ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

        if (onlineFirst.isEmpty) {
          return const _EmptyState(
            icon: Icons.quiz_outlined,
            message: 'No online exam results yet',
            sub: 'Take a test to see your first-attempt scores',
          );
        }

        if (_selected == null && onlineFirst.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback(
              (_) => setState(() => _selected = onlineFirst.first));
        }

        return Column(
          children: [
            _DropdownBar<ExamResultModel>(
              hint: 'Select an exam',
              value: _selected,
              items: onlineFirst,
              itemLabel: (r) =>
                  '${r.examTitle.isEmpty ? "Online Exam" : r.examTitle}  ·  ${DateFormat("dd MMM").format(r.submittedAt)}',
              onChanged: (r) => setState(() => _selected = r),
            ),
            Expanded(
              child: _selected == null
                  ? const _EmptyState(
                      icon: Icons.touch_app_outlined,
                      message: 'Select an exam above',
                      sub: 'to view your result',
                    )
                  : _OnlineDetail(result: _selected!, studentId: widget.user.id),
            ),
          ],
        );
      },
    );
  }
}

// ── Dropdown selector bar ─────────────────────────────────────
class _DropdownBar<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  const _DropdownBar({
    required this.hint,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.neuSurface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFD8DCF0), // visibly darker than background
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1.2),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            hint: Text(hint,
                style: const TextStyle(color: AppColors.textHint, fontSize: 13)),
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: AppColors.primary),
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600),
            items: items.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(itemLabel(item),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13)),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

// ── Offline test detail view ──────────────────────────────────
class _OfflineDetail extends StatelessWidget {
  final OfflineTestModel test;
  final String studentId;
  final Map<String, UserModel> studentMap;

  const _OfflineDetail({
    required this.test,
    required this.studentId,
    required this.studentMap,
  });

  @override
  Widget build(BuildContext context) {
    final myScore = test.studentMarks[studentId];
    final allScores = test.studentMarks.entries
        .where((e) => e.value != null)
        .map((e) => MapEntry(e.key, e.value!))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final highestScore = allScores.isNotEmpty ? allScores.first.value : null;
    final topScorers = allScores
        .where((e) => e.value == highestScore)
        .map((e) => studentMap[e.key]?.name ?? 'Unknown')
        .toList();

    final pct = myScore != null && test.fullMarks > 0
        ? (myScore / test.fullMarks) * 100
        : null;
    final scoreColor = pct == null
        ? AppColors.textHint
        : pct >= 70
            ? AppColors.success
            : pct >= 40
                ? AppColors.warning
                : AppColors.error;
    final isTopScorer =
        myScore != null && myScore == highestScore && myScore > 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppColors.glow(AppColors.primary, intensity: 0.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isTopScorer)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.emoji_events_rounded,
                          color: Colors.amber, size: 14),
                      SizedBox(width: 5),
                      Text('Top Scorer!',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800)),
                    ]),
                  ),
                Text(test.name,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white)),
                Text(
                  DateFormat('EEEE, dd MMMM yyyy').format(test.date),
                  style:
                      TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.75)),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 16),

          // Score cards row
          Row(children: [
            Expanded(child: _ScoreTile(
              label: 'My Score',
              value: myScore != null ? '$myScore / ${test.fullMarks}' : 'Not marked',
              color: scoreColor,
              icon: Icons.person_outline_rounded,
            )),
            const SizedBox(width: 10),
            Expanded(child: _ScoreTile(
              label: 'Percentage',
              value: pct != null ? '${pct.toStringAsFixed(1)}%' : '—',
              color: scoreColor,
              icon: Icons.percent_rounded,
            )),
            const SizedBox(width: 10),
            Expanded(child: _ScoreTile(
              label: 'Class High',
              value: highestScore != null ? '$highestScore' : '—',
              color: AppColors.accent,
              icon: Icons.emoji_events_rounded,
            )),
          ]).animate(delay: 100.ms).fadeIn(),

          // Progress bar
          if (myScore != null && test.fullMarks > 0) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (myScore / test.fullMarks).clamp(0.0, 1.0),
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                minHeight: 8,
              ),
            ),
          ],

          // Top scorer
          if (topScorers.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.accentSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                const Icon(Icons.emoji_events_rounded,
                    color: AppColors.accent, size: 18),
                const SizedBox(width: 8),
                const Text('Top scorer: ',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
                Expanded(
                  child: Text(topScorers.join(', '),
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.accent)),
                ),
              ]),
            ).animate(delay: 150.ms).fadeIn(),
          ],

          // Leaderboard
          if (allScores.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('Class Ranking',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            ...() {
              // Compute true rank: tied scores get the same rank number
              final top10 = allScores.take(10).toList();
              int trueRank = 1;
              int prevScore = -1;
              return top10.asMap().entries.map((e) {
                final score = e.value.value;
                if (score != prevScore) {
                  trueRank = e.key + 1;
                  prevScore = score;
                }
                final name = studentMap[e.value.key]?.name ?? 'Unknown';
                final isMe = e.value.key == studentId;
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe
                        ? AppColors.primarySurface
                        : AppColors.neuSurface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isMe ? AppColors.neuRaisedSoft : null,
                    border: isMe
                        ? Border.all(color: AppColors.primary, width: 1.2)
                        : null,
                  ),
                  child: Row(children: [
                    _RankBadge(trueRank),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(isMe ? 'You ($name)' : name,
                          style: TextStyle(
                              fontSize: 12.5,
                              fontWeight:
                                  isMe ? FontWeight.w800 : FontWeight.w500,
                              color: isMe
                                  ? AppColors.primary
                                  : AppColors.textPrimary)),
                    ),
                    Text('${e.value.value}',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: isMe
                                ? AppColors.primary
                                : AppColors.textPrimary)),
                    Text(' / ${test.fullMarks}',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                  ]),
                ).animate(delay: (e.key * 30).ms).fadeIn(duration: 200.ms);
              }).toList();
            }(),
          ],
        ],
      ),
    );
  }
}

// ── Online exam detail view ───────────────────────────────────
class _OnlineDetail extends StatefulWidget {
  final ExamResultModel result;
  final String studentId;
  const _OnlineDetail({required this.result, required this.studentId});

  @override
  State<_OnlineDetail> createState() => _OnlineDetailState();
}

class _OnlineDetailState extends State<_OnlineDetail> {
  int? _rank;
  int? _total;
  String? _topName;
  bool _rankLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRank();
  }

  @override
  void didUpdateWidget(_OnlineDetail old) {
    super.didUpdateWidget(old);
    if (old.result.examId != widget.result.examId) _loadRank();
  }

  Future<void> _loadRank() async {
    setState(() => _rankLoading = true);
    try {
      // Only show ranking if admin has published results for this exam
      final exam = await SupabaseService.instance
          .getExam(widget.result.examId);
      if (exam == null || !exam.resultsPublished) {
        setState(() => _rankLoading = false);
        return; // ranking hidden until admin publishes
      }

      final all = await SupabaseService.instance
          .getAllResultsForExam(widget.result.examId);
      all.sort((a, b) => b.neetScore.compareTo(a.neetScore));
      final total = all.length;
      final idx = all.indexWhere((r) => r.studentId == widget.studentId);
      String? topName;
      if (all.isNotEmpty) {
        final top = await SupabaseService.instance
            .getUserById(all.first.studentId);
        topName = top?.name;
      }
      setState(() {
        _rank = idx >= 0 ? idx + 1 : null;
        _total = total;
        _topName = topName;
        _rankLoading = false;
      });
    } catch (_) {
      setState(() => _rankLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pct = widget.result.percentage;
    final scoreColor = pct >= 70
        ? AppColors.success
        : pct >= 40
            ? AppColors.warning
            : AppColors.error;

    final perf = pct >= 80
        ? 'Excellent!'
        : pct >= 60
            ? 'Good Job!'
            : pct >= 40
                ? 'Keep Going!'
                : 'Needs Improvement';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [scoreColor, scoreColor.withOpacity(0.6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(perf,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(widget.result.examTitle.isEmpty ? 'Online Exam' : widget.result.examTitle,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white)),
                Text(
                  DateFormat('dd MMM yyyy · h:mm a').format(widget.result.submittedAt),
                  style:
                      TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.75)),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 16),

          // Score row
          Row(children: [
            Expanded(child: _ScoreTile(
              label: 'Score', value: '${pct.toStringAsFixed(1)}%',
              color: scoreColor, icon: Icons.percent_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _ScoreTile(
              label: 'NEET Marks', value: '${widget.result.neetScore}',
              color: AppColors.primary, icon: Icons.star_outlined)),
            const SizedBox(width: 10),
            Expanded(child: _ScoreTile(
              label: 'Total Qs', value: '${widget.result.totalQuestions}',
              color: AppColors.info, icon: Icons.quiz_outlined)),
          ]).animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _ScoreTile(
              label: 'Correct', value: '${widget.result.correctCount}',
              color: AppColors.success, icon: Icons.check_circle_outline)),
            const SizedBox(width: 10),
            Expanded(child: _ScoreTile(
              label: 'Wrong', value: '${widget.result.incorrectCount}',
              color: AppColors.error, icon: Icons.cancel_outlined)),
            const SizedBox(width: 10),
            Expanded(child: _ScoreTile(
              label: 'Skipped', value: '${widget.result.unattemptedCount}',
              color: AppColors.warning, icon: Icons.remove_circle_outline)),
          ]).animate(delay: 150.ms).fadeIn(),

          const SizedBox(height: 14),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (pct / 100).clamp(0.0, 1.0),
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 4),
          Text('${pct.toStringAsFixed(1)}% accuracy',
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),

          // ── Class ranking ────────────────────────────────
          const SizedBox(height: 16),
          if (_rankLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  SizedBox(width: 14, height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                  SizedBox(width: 8),
                  Text('Checking rankings…',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ]),
              ),
            )
          else if (_rank != null && _total != null)
            _ResultRankCard(rank: _rank!, total: _total!, topName: _topName)
                .animate(delay: 200.ms).fadeIn()
          else
            // Rankings not yet published by admin
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
                  'Class rankings will be visible after your teacher releases them.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                )),
              ]),
            ),
        ],
      ),
    );
  }
}

// ── Rank card for results section ─────────────────────────────
class _ResultRankCard extends StatelessWidget {
  final int rank, total;
  final String? topName;
  const _ResultRankCard(
      {required this.rank, required this.total, this.topName});

  @override
  Widget build(BuildContext context) {
    final medals = ['🥇', '🥈', '🥉'];
    final isTop3 = rank <= 3;
    final medal = isTop3 ? medals[rank - 1] : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isTop3 ? const Color(0xFFFFF8E1) : AppColors.primarySurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isTop3
                ? const Color(0xFFFFB300).withOpacity(0.4)
                : AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          if (medal != null) ...[
            Text(medal, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                isTop3 ? 'You ranked #$rank in your class!' : 'Your Class Rank',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w800,
                    color: isTop3 ? const Color(0xFF7B4F00) : AppColors.primary),
              ),
              Text('#$rank of $total students (first attempt only)',
                  style: TextStyle(
                      fontSize: 11,
                      color: isTop3
                          ? const Color(0xFF7B4F00).withOpacity(0.7)
                          : AppColors.textSecondary)),
            ]),
          ),
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: isTop3
                  ? const Color(0xFFFFB300).withOpacity(0.25)
                  : AppColors.primary.withOpacity(0.1),
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
                      fontSize: rank > 99 ? 11 : 15,
                      fontWeight: FontWeight.w900,
                      color: isTop3 ? const Color(0xFF7B4F00) : AppColors.primary)),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: total > 1 ? 1 - (rank - 1) / (total - 1) : 1.0,
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
        if (topName != null && rank != 1) ...[
          const SizedBox(height: 8),
          Row(children: [
            const Text('🥇 Top scorer: ', style: TextStyle(fontSize: 11)),
            Expanded(
              child: Text(topName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.accent)),
            ),
          ]),
        ],
      ]),
    );
  }
}

// ── Shared helper widgets ─────────────────────────────────────
class _ScoreTile extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _ScoreTile(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.neuSurface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppColors.neuRaisedSoft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(height: 4),
            // FittedBox shrinks the value text if the tile is too narrow
            // to prevent overflow without truncating.
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: color)),
            ),
            Text(label,
                style: const TextStyle(
                    fontSize: 9.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      );
}

class _RankBadge extends StatelessWidget {
  final int rank;
  const _RankBadge(this.rank);

  @override
  Widget build(BuildContext context) {
    // Rank colour based on actual rank (true rank after tie resolution)
    final Color color;
    if (rank == 1) {
      color = AppColors.accent;            // gold for all rank-1 ties
    } else if (rank == 2) {
      color = AppColors.textSecondary;     // silver
    } else if (rank == 3) {
      color = const Color(0xFFB45309);     // bronze
    } else {
      color = AppColors.neuBackground;
    }
    final bool isTop3 = rank <= 3;
    return Container(
      width: 24, height: 24,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child: Text('$rank',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: isTop3 ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message, sub;
  const _EmptyState(
      {required this.icon, required this.message, required this.sub});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 56, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(sub,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textHint)),
        ]),
      );
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: SkeletonCard(height: 90),
        ),
      );
}
