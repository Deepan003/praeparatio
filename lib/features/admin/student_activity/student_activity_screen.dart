import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/exam_result_model.dart';
import '../../../providers/batch_provider.dart';
import '../../../models/offline_test_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/exam_provider.dart';
import '../../../providers/student_provider.dart';
import '../../../services/csv_service.dart';
import '../../../services/pdf_service.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/download_button.dart';
import '../../../widgets/badge_widget.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/stat_card.dart';

class StudentActivityScreen extends ConsumerStatefulWidget {
  const StudentActivityScreen({super.key});

  @override
  ConsumerState<StudentActivityScreen> createState() =>
      _StudentActivityScreenState();
}

class _StudentActivityScreenState
    extends ConsumerState<StudentActivityScreen> {
  String? _activeBatch;
  UserModel? _selectedStudent;

  @override
  Widget build(BuildContext context) {
    final batchNames = ref.watch(batchNamesProvider);
    _activeBatch ??= batchNames.isNotEmpty ? batchNames.first : AppConstants.batch11;
    final activeBatch = _activeBatch!; // local non-nullable copy for Dart promotion
    final studentsAsync = ref.watch(batchStudentsProvider(activeBatch));
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    // ── Mobile layout ─────────────────────────────────────────
    if (isMobile) {
      // Detail pane: show when student selected
      if (_selectedStudent != null) {
        return _StudentDetail(
          student: _selectedStudent!,
          batch: activeBatch,
          onBack: () => setState(() => _selectedStudent = null),
        );
      }
      // List pane: full-width column (no Row — Row with infinite width crashes)
      return Column(
        children: [
          Container(
            color: AppColors.neuSurface,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Students',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: batchNames
                      .map((b) => ChipButtonInline(
                            label: b,
                            selected: _activeBatch == b,
                            onTap: () => setState(() {
                              _activeBatch = b;
                              _selectedStudent = null;
                            }),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: studentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (students) {
                if (students.isEmpty) {
                  return const Center(
                    child: Text('No students in this batch',
                        style: TextStyle(color: AppColors.textHint)),
                  );
                }
                return ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (_, i) {
                    final s = students[i];
                    return ListTile(
                      selected: _selectedStudent?.id == s.id,
                      selectedTileColor: AppColors.primarySurface,
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primarySurface,
                        child: Text(s.name[0].toUpperCase(),
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700)),
                      ),
                      title: Text(s.name,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: Text('@${s.username}',
                          style: const TextStyle(fontSize: 11)),
                      trailing: const Icon(Icons.chevron_right_rounded,
                          size: 18, color: AppColors.textHint),
                      onTap: () => setState(() => _selectedStudent = s),
                    );
                  },
                );
              },
            ),
          ),
        ],
      );
    }

    // ── Desktop / tablet layout ────────────────────────────
    return Row(
      children: [
        SizedBox(
          width: 280,
          child: Column(
            children: [
              Container(
                color: AppColors.neuSurface,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Students',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: batchNames
                          .map((b) => ChipButtonInline(
                                label: b,
                                selected: _activeBatch == b,
                                onTap: () => setState(() {
                                  _activeBatch = b;
                                  _selectedStudent = null;
                                }),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: studentsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('$e')),
                  data: (students) => ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (_, i) {
                      final s = students[i];
                      return ListTile(
                        selected: _selectedStudent?.id == s.id,
                        selectedTileColor: AppColors.primarySurface,
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primarySurface,
                          child: Text(s.name[0].toUpperCase(),
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700)),
                        ),
                        title: Text(s.name,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: Text('@${s.username}',
                            style: const TextStyle(fontSize: 11)),
                        onTap: () => setState(() => _selectedStudent = s),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: _selectedStudent == null
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_search,
                          size: 60, color: AppColors.textHint),
                      SizedBox(height: 12),
                      Text('Select a student to view their activity',
                          style: TextStyle(color: AppColors.textHint)),
                    ],
                  ),
                )
              : _StudentDetail(
                  student: _selectedStudent!,
                  batch: activeBatch,
                ),
        ),
      ],
    );
  }
}

class ChipButtonInline extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const ChipButtonInline(
      {super.key, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.neuBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: selected ? AppColors.primary : AppColors.border),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? Colors.white
                      : AppColors.textSecondary)),
        ),
      );
}

// ── Student Detail Panel ───────────────────────────────────────
class _StudentDetail extends ConsumerStatefulWidget {
  final UserModel student;
  final String batch;
  final VoidCallback? onBack; // mobile back to list
  const _StudentDetail({required this.student, required this.batch, this.onBack});

  @override
  ConsumerState<_StudentDetail> createState() => _StudentDetailState();
}

class _StudentDetailState extends ConsumerState<_StudentDetail>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  ExamResultModel? _selectedOnlineResult;
  OfflineTestModel? _selectedOfflineTest;
  List<OfflineTestModel> _offlineTests = [];
  bool _offlineLoading = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _loadOffline();
  }

  @override
  void didUpdateWidget(_StudentDetail old) {
    super.didUpdateWidget(old);
    if (old.student.id != widget.student.id) {
      _selectedOnlineResult = null;
      _selectedOfflineTest = null;
      _loadOffline();
    }
  }

  Future<void> _loadOffline() async {
    setState(() => _offlineLoading = true);
    final tests = await SupabaseService.instance
        .getOfflineTestsByBatch(widget.batch);
    setState(() {
      _offlineTests = tests;
      _offlineLoading = false;
      if (tests.isNotEmpty) _selectedOfflineTest = tests.first;
    });
  }

  Future<Uint8List> _csvReport(List<ExamResultModel> online) async =>
      CsvService.exportStudentReport(widget.student, online, _offlineTests);

  Future<Uint8List> _pdfReport(List<ExamResultModel> online) async =>
      PdfService.studentReportPdf(
          student: widget.student,
          onlineResults: online,
          offlineTests: _offlineTests);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync =
        ref.watch(studentResultsProvider(widget.student.id));

    return resultsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (results) {
        // Only online first attempts
        final onlineResults = results
            .where((r) => !r.isInProgress && r.examType == 'online')
            .toList()
          ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

        final attempted = onlineResults.length;
        final avgScore = onlineResults.isEmpty
            ? 0.0
            : onlineResults
                    .map((r) => r.percentage)
                    .reduce((a, b) => a + b) /
                onlineResults.length;

        return Column(
          children: [
            // ── Profile header ─────────────────────────────
            Container(
              color: AppColors.neuSurface,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (widget.onBack != null) ...[
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: widget.onBack,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                  ],
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primarySurface,
                    child: Text(widget.student.name[0].toUpperCase(),
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.student.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w800)),
                        Text(
                            '@${widget.student.username} · ${widget.student.batch}',
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12)),
                        Row(children: [
                          const Icon(Icons.monetization_on_rounded,
                              size: 13, color: AppColors.accent),
                          const SizedBox(width: 3),
                          Text('${widget.student.prepcoins} PrepCoins',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accent)),
                        ]),
                      ],
                    ),
                  ),
                  DownloadButton(
                    label: 'Report',
                    filename: 'Student_${widget.student.name.replaceAll(' ', '_')}',
                    csvBuilder: () => _csvReport(onlineResults),
                    pdfBuilder: () => _pdfReport(onlineResults),
                  ),
                ],
              ),
            ),

            // ── Stats row ───────────────────────────────────
            Container(
              color: AppColors.neuBackground,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(children: [
                _QuickStat(
                    '$attempted', 'Exams', AppColors.primary),
                const SizedBox(width: 10),
                _QuickStat('${avgScore.toStringAsFixed(1)}%',
                    'Avg Score', AppColors.info),
                const SizedBox(width: 10),
                _QuickStat(
                    '${widget.student.prepcoins}', 'Coins', AppColors.accent),
                const SizedBox(width: 10),
                _QuickStat('${_offlineTests.length}',
                    'Offline Tests', AppColors.bioGreen),
              ]),
            ),

            // ── Tabs ────────────────────────────────────────
            Container(
              color: AppColors.neuSurface,
              child: TabBar(
                controller: _tabs,
                tabs: const [
                  Tab(text: 'Online Marks'),
                  Tab(text: 'Test Marks'),
                  Tab(text: 'Badges'),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  // ── Online Marks tab ─────────────────────
                  _OnlineMarksTab(
                    results: onlineResults,
                    selected: _selectedOnlineResult,
                    onSelect: (r) =>
                        setState(() => _selectedOnlineResult = r),
                  ),
                  // ── Offline Test Marks tab ──────────────
                  _OfflineMarksTab(
                    student: widget.student,
                    tests: _offlineTests,
                    loading: _offlineLoading,
                    selected: _selectedOfflineTest,
                    onSelect: (t) =>
                        setState(() => _selectedOfflineTest = t),
                  ),
                  // ── Badges tab ──────────────────────────
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (onlineResults.isNotEmpty) ...[
                          const Text('Performance Trend',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 10),
                          SolidCard(
                            child: SizedBox(
                                height: 180,
                                child: _PerformanceLineChart(
                                    results: onlineResults)),
                          ),
                          const SizedBox(height: 20),
                        ],
                        const Text('Badges',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 10),
                        BadgeGrid(
                            earnedIds: widget.student.earnedBadgeIds,
                            crossAxisCount: 6),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Quick stat tile ──────────────────────────────────────────
class _QuickStat extends StatelessWidget {
  final String value, label;
  final Color color;
  const _QuickStat(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: color)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
}

// ── Online Marks tab ──────────────────────────────────────────
class _OnlineMarksTab extends StatelessWidget {
  final List<ExamResultModel> results;
  final ExamResultModel? selected;
  final ValueChanged<ExamResultModel?> onSelect;
  const _OnlineMarksTab(
      {required this.results, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.quiz_outlined, size: 48, color: AppColors.textHint),
          SizedBox(height: 10),
          Text('No online exams attempted yet',
              style: TextStyle(color: AppColors.textHint)),
        ]),
      );
    }

    final fmt = DateFormat('dd MMM yyyy');
    final r = selected ?? results.first;
    final pct = r.percentage;
    final scoreColor = pct >= 70
        ? AppColors.success
        : pct >= 40
            ? AppColors.warning
            : AppColors.error;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFD8DCF0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1.2),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ExamResultModel>(
                value: r,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primary),
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
                items: results.map((res) => DropdownMenuItem(
                      value: res,
                      child: Text(
                        '${res.examTitle.isEmpty ? "Online Exam" : res.examTitle}  ·  ${fmt.format(res.submittedAt)}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    )).toList(),
                onChanged: onSelect,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Result card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scoreColor.withOpacity(0.3)),
            ),
            child: Row(children: [
              Column(
                children: [
                  Text('${pct.toStringAsFixed(1)}%',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: scoreColor)),
                  Text('Score', style: TextStyle(fontSize: 11, color: scoreColor)),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.examTitle.isEmpty ? 'Online Exam' : r.examTitle,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(fmt.format(r.submittedAt),
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ]),
          ),
          const SizedBox(height: 12),

          // Stats
          Row(children: [
            _StatBox('NEET Score', '${r.neetScore}', AppColors.primary),
            const SizedBox(width: 8),
            _StatBox('Correct', '${r.correctCount}', AppColors.success),
            const SizedBox(width: 8),
            _StatBox('Wrong', '${r.incorrectCount}', AppColors.error),
            const SizedBox(width: 8),
            _StatBox('Skipped', '${r.unattemptedCount}', AppColors.warning),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            _StatBox('Total Qs', '${r.totalQuestions}', AppColors.info),
            const SizedBox(width: 8),
            _StatBox(
                'Time',
                '${r.timeTakenSeconds ~/ 60}m ${r.timeTakenSeconds % 60}s',
                AppColors.textSecondary),
          ]),
        ],
      ),
    );
  }
}

// ── Offline Test Marks tab ────────────────────────────────────
class _OfflineMarksTab extends StatelessWidget {
  final UserModel student;
  final List<OfflineTestModel> tests;
  final bool loading;
  final OfflineTestModel? selected;
  final ValueChanged<OfflineTestModel?> onSelect;
  const _OfflineMarksTab({
    required this.student,
    required this.tests,
    required this.loading,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (tests.isEmpty) {
      return const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.assignment_outlined, size: 48, color: AppColors.textHint),
          SizedBox(height: 10),
          Text('No offline tests added yet',
              style: TextStyle(color: AppColors.textHint)),
        ]),
      );
    }

    final fmt = DateFormat('dd MMM yyyy');
    final t = selected ?? tests.first;
    final score = t.studentMarks[student.id];
    final pct = score != null && t.fullMarks > 0
        ? score / t.fullMarks * 100
        : null;
    final scoreColor = pct == null
        ? AppColors.textHint
        : pct >= 70
            ? AppColors.success
            : pct >= 40
                ? AppColors.warning
                : AppColors.error;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFD8DCF0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1.2),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<OfflineTestModel>(
                value: t,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primary),
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
                items: tests
                    .map((test) => DropdownMenuItem(
                          value: test,
                          child: Text(
                            '${test.name}  ·  ${fmt.format(test.date)}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ))
                    .toList(),
                onChanged: onSelect,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Test result card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scoreColor.withOpacity(0.3)),
            ),
            child: Row(children: [
              Column(
                children: [
                  Text(
                    score != null ? '$score' : '—',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: scoreColor),
                  ),
                  Text('/ ${t.fullMarks}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 14)),
                    Text(fmt.format(t.date),
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary)),
                    if (pct != null)
                      Text('${pct.toStringAsFixed(1)}%',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: scoreColor)),
                    if (score == null)
                      const Text('Not marked / Absent',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // Score bar
          if (score != null && t.fullMarks > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (score / t.fullMarks).clamp(0.0, 1.0),
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 20),
          ],

          // All tests summary
          const Text('All Tests Summary',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ...tests.map((test) {
            final s = test.studentMarks[student.id];
            final p = s != null && test.fullMarks > 0
                ? s / test.fullMarks * 100
                : null;
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.neuSurface,
                borderRadius: BorderRadius.circular(10),
                boxShadow: AppColors.neuRaisedSoft,
              ),
              child: Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(test.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12)),
                      Text(fmt.format(test.date),
                          style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Text(
                  s != null
                      ? '$s / ${test.fullMarks}'
                      : 'Absent',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: p != null
                          ? (p >= 70
                              ? AppColors.success
                              : p >= 40
                                  ? AppColors.warning
                                  : AppColors.error)
                          : AppColors.textHint),
                ),
                if (p != null) ...[
                  const SizedBox(width: 8),
                  Text('${p.toStringAsFixed(0)}%',
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary)),
                ],
              ]),
            );
          }),
        ],
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
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 9.5, color: AppColors.textSecondary)),
          ]),
        ),
      );
}

class _PerformanceLineChart extends StatelessWidget {
  final List<ExamResultModel> results;
  const _PerformanceLineChart({required this.results});

  @override
  Widget build(BuildContext context) {
    final data = results.reversed.take(10).toList().reversed.toList();
    final spots = data
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
              show: true,
              color: AppColors.primary.withOpacity(0.1)),
        ),
      ],
      titlesData: const FlTitlesData(
        leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
        bottomTitles:
            AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles:
            AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppColors.border, strokeWidth: 1)),
      borderData: FlBorderData(show: false),
      minY: 0,
      maxY: 100,
    ));
  }
}
