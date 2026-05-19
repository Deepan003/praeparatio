import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/ncert_chapters.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/pyq_model.dart';
import '../../../models/question_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/bookmark_provider.dart';
import '../../../providers/pyq_provider.dart';
import '../../../services/haptic_service.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/skeleton.dart';
import '../../../widgets/exam_start_dialog.dart';
import '../../../widgets/glass_card.dart';
import '../cbt/cbt_portal.dart';

List<QuestionModel> _pyqToQuestions(List<PYQModel> pyq) => pyq.map((p) => QuestionModel(
  id: p.id, text: p.question, optionA: p.optionA, optionB: p.optionB,
  optionC: p.optionC, optionD: p.optionD, correctOption: p.correctOption,
  imageUrl: p.imageUrl, explanation: p.explanation, chapter: p.chapter,
  difficulty: 'NEET Level',
)).toList();

class PYQScreen extends ConsumerStatefulWidget {
  const PYQScreen({super.key});

  @override
  ConsumerState<PYQScreen> createState() => _PYQScreenState();
}

class _PYQScreenState extends ConsumerState<PYQScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.neuSurface,
          child: TabBar(
            controller: _tabs,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: 'Chapterwise'),
              Tab(text: 'Yearwise'),
              Tab(text: 'Custom Test'),
              Tab(icon: Icon(Icons.bookmark_rounded, size: 16), text: 'Saved'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: const [
              _ChapterwiseTab(),
              _YearwiseTab(),
              _CustomTestTab(),
              _BookmarksTab(),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// CHAPTERWISE TAB
// ─────────────────────────────────────────────
class _ChapterwiseTab extends ConsumerStatefulWidget {
  const _ChapterwiseTab();
  @override
  ConsumerState<_ChapterwiseTab> createState() => _ChapterwiseTabState();
}

class _ChapterwiseTabState extends ConsumerState<_ChapterwiseTab> {
  String? _classFilter; // null = not yet initialised

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;
    final studentClass = user?.studentClass ?? '11';
    // Class-11 students are locked to '11'; class-12/neet see everything
    final isLocked = studentClass == '11';
    _classFilter ??= isLocked ? '11' : 'all';

    final chaptersAsync = ref.watch(pyqChaptersProvider);
    final allAsync = ref.watch(allPYQProvider);

    return Column(
      children: [
        // Class filter bar — hidden for Class 11 students (they only see their class)
        if (!isLocked)
          Container(
          color: AppColors.neuSurface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              for (final f in [('all', 'All'), ('11', 'Class 11'), ('12', 'Class 12')])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _classFilter = f.$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: _classFilter == f.$1 ? AppColors.primary : AppColors.neuBackground,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: _classFilter == f.$1 ? AppColors.primary : AppColors.border),
                      ),
                      child: Text(f.$2,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _classFilter == f.$1 ? Colors.white : AppColors.textSecondary)),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: chaptersAsync.when(
            loading: () => const SkeletonGrid(),
            error: (e, _) => _EmptyState(
                icon: Icons.error_outline,
                message: 'No PYQ data. Ask your admin to upload a CSV.'),
            data: (allChapters) {
              if (allChapters.isEmpty) {
                return _EmptyState(
                    icon: Icons.history_edu_outlined,
                    message: 'No PYQ uploaded yet.\nAsk your admin to upload questions.');
              }

              return allAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox.shrink(),
                data: (allPyq) {
                  final countMap = <String, int>{};
                  final yearMap = <String, Set<String>>{};
                  for (final q in allPyq) {
                    countMap[q.chapter] = (countMap[q.chapter] ?? 0) + 1;
                    yearMap.putIfAbsent(q.chapter, () => {}).add(q.year);
                  }
                  final maxCount = countMap.values.fold(0, (a, b) => a > b ? a : b);

                  // Filter by class, then sort: Class 11 ch1,ch2... then Class 12
                  var chapters = allChapters.where((ch) {
                    if (_classFilter == 'all') return true;
                    return NcertChapters.classFor(ch) == _classFilter;
                  }).toList();
                  // Safety: class-11 students never see class-12 chapters
                  if (isLocked) {
                    chapters = chapters
                        .where((ch) => NcertChapters.classFor(ch) == '11')
                        .toList();
                  }

                  chapters.sort((a, b) {
                    final ca = NcertChapters.classFor(a);
                    final cb = NcertChapters.classFor(b);
                    if (ca != cb) return ca.compareTo(cb);
                    return NcertChapters.chapterNumber(a)
                        .compareTo(NcertChapters.chapterNumber(b));
                  });

                  return GridView.builder(
                    padding: const EdgeInsets.all(14),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 260,
                      childAspectRatio: 1.4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: chapters.length,
                    itemBuilder: (_, i) {
                      final ch = chapters[i];
                      final count = countMap[ch] ?? 0;
                      final years = yearMap[ch]?.toList()?..sort();
                      final cls = NcertChapters.classFor(ch);
                      return _ChapterTile(
                        chapter: ch,
                        count: count,
                        maxCount: maxCount,
                        years: years ?? [],
                        cls: cls,
                        onTap: () { HapticFeedback.lightImpact(); _showChapterDetail(context, ch); },
                      ).animate(delay: (i * 30).ms)
                          .fadeIn(duration: 220.ms)
                          .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOut);
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

  void _showChapterDetail(BuildContext context, String chapter) {
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
      builder: (_) => _PYQBrowsePage(
        title: chapter,
        subtitle: 'Chapterwise · ${NcertChapters.classFor(chapter) == '11' ? 'Class 11' : 'Class 12'}',
        provider: pyqByChapterProvider(chapter),
        groupByYear: true,
      ),
    ));
  }
}

// Compact grid tile — flashcard-style layout
class _ChapterTile extends StatelessWidget {
  final String chapter;
  final int count;
  final int maxCount;
  final List<String> years;
  final String cls;
  final VoidCallback onTap;

  const _ChapterTile({
    required this.chapter,
    required this.count,
    required this.maxCount,
    required this.years,
    required this.cls,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final clsColor = cls == '11' ? AppColors.batch11 : AppColors.batch12;
    final chNum = NcertChapters.chapterNumber(chapter);

    return SolidCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        children: [
          // Coloured top — like flashcard
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    clsColor.withOpacity(0.15),
                    clsColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Ch $chNum',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: clsColor.withOpacity(0.6))),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: clsColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text('Class $cls',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: clsColor)),
                  ),
                ],
              ),
            ),
          ),
          // Info bottom — like flashcard
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(chapter,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: AppColors.textPrimary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text('$count questions',
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ),
          // Micro-progress bar: question density relative to busiest chapter
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
            child: SizedBox(
              height: 4,
              child: LinearProgressIndicator(
                value: maxCount > 0 ? count / maxCount : 0.0,
                backgroundColor: clsColor.withOpacity(0.10),
                valueColor: AlwaysStoppedAnimation<Color>(clsColor.withOpacity(0.65)),
                minHeight: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Year tile — color-coded by recency: newer = warmer/brighter
class _YearTile extends StatelessWidget {
  final String year;
  final int count;
  final VoidCallback onBrowse;
  final VoidCallback onTest;

  const _YearTile({
    required this.year,
    required this.count,
    required this.onBrowse,
    required this.onTest,
  });

  static const _currentYear = 2026;

  LinearGradient _recencyGradient() {
    final y = int.tryParse(year) ?? 2020;
    final age = _currentYear - y;
    if (age <= 1) {
      return const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF3CAC)],
          begin: Alignment.topLeft, end: Alignment.bottomRight);
    } else if (age <= 2) {
      return const LinearGradient(
          colors: [Color(0xFFFFBE0B), Color(0xFFFF6B35)],
          begin: Alignment.topLeft, end: Alignment.bottomRight);
    } else if (age <= 4) {
      return const LinearGradient(
          colors: [Color(0xFF06D6A0), Color(0xFF118AB2)],
          begin: Alignment.topLeft, end: Alignment.bottomRight);
    } else if (age <= 6) {
      return AppColors.primaryGradient;
    } else if (age <= 9) {
      return const LinearGradient(
          colors: [Color(0xFF5E60CE), Color(0xFF48CAE4)],
          begin: Alignment.topLeft, end: Alignment.bottomRight);
    } else {
      return const LinearGradient(
          colors: [Color(0xFF6C757D), Color(0xFF495057)],
          begin: Alignment.topLeft, end: Alignment.bottomRight);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _recencyGradient();
    return SolidCard(
      padding: EdgeInsets.zero,
      onTap: onBrowse,
      child: Column(
        children: [
          // Gradient top — color reflects how recent the year is
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$year',
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1)),
                  Text('NEET',
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1)),
                ],
              ),
            ),
          ),
          // Info bottom
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 7, 10, 8),
            child: Row(children: [
              Expanded(
                child: Text('$count Qs',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary)),
              ),
              GestureDetector(
                onTap: onTest,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      size: 13, color: Colors.white),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _PyqQuestionTile extends StatefulWidget {
  final PYQModel q;
  const _PyqQuestionTile({required this.q});

  @override
  State<_PyqQuestionTile> createState() => _PyqQuestionTileState();
}

class _PyqQuestionTileState extends State<_PyqQuestionTile> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.neuBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.q.question,
              overflow: TextOverflow.clip,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.5)),
          const SizedBox(height: 8),
          // 2-column grid — Expanded ensures text never overflows horizontally
          ...[ ['A', 'B'], ['C', 'D'] ].map((pair) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: pair.map((opt) {
                final isCorrect = _revealed &&
                    opt.toUpperCase() == widget.q.correctOption.toUpperCase();
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: opt == pair.first ? 4 : 0),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCorrect ? AppColors.successSurface : AppColors.neuSurface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: isCorrect ? AppColors.success : AppColors.border),
                    ),
                    child: Text(
                      '$opt. ${widget.q.optionText(opt)}',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 11,
                          height: 1.4,
                          color: isCorrect ? AppColors.success : AppColors.textPrimary,
                          fontWeight: isCorrect ? FontWeight.w700 : FontWeight.w400),
                    ),
                  ),
                );
              }).toList(),
            ),
          )),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => setState(() => _revealed = !_revealed),
            style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero),
            child: Text(
              _revealed ? 'Hide Answer' : 'Show Answer',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// YEARWISE TAB
// ─────────────────────────────────────────────
class _YearwiseTab extends ConsumerWidget {
  const _YearwiseTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final yearsAsync = ref.watch(pyqYearsProvider);
    final allAsync = ref.watch(allPYQProvider);

    return yearsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _EmptyState(
          icon: Icons.error_outline,
          message: 'No PYQ data available.'),
      data: (years) {
        if (years.isEmpty) {
          return _EmptyState(
              icon: Icons.history_edu_outlined,
              message: 'No PYQ uploaded yet.');
        }

        return allAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox.shrink(),
          data: (allPyq) {
            final countMap = <String, int>{};
            for (final q in allPyq) {
              countMap[q.year] = (countMap[q.year] ?? 0) + 1;
            }

            return GridView.builder(
              padding: const EdgeInsets.all(14),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 1.4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: years.length,
              itemBuilder: (_, i) {
                final year = years[i];
                final count = countMap[year] ?? 0;
                final qs = allPyq.where((q) => q.year == year).toList();

                return _YearTile(
                  year: year,
                  count: count,
                  onBrowse: () => _showYearDetail(context, ref, year),
                  onTest: () async {
                    final dur = (qs.length * 60 / 60).ceil();
                    final ok = await showExamStartDialog(context,
                        title: 'NEET $year', questionCount: qs.length,
                        durationMinutes: dur, isPYQ: true);
                    if (!ok || !context.mounted) return;
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => CBTPortal(
                        examId: 'pyq_year_$year',
                        questions: _pyqToQuestions(qs),
                        durationMinutes: dur,
                      ),
                    ));
                  },
                ).animate(delay: (i * 40).ms)
                    .fadeIn(duration: 200.ms)
                    .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOut);
              },
            );
          },
        );
      },
    );
  }

  void _showYearDetail(BuildContext context, WidgetRef ref, String year) {
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
      builder: (_) => _PYQBrowsePage(
        title: 'NEET $year',
        subtitle: 'Yearwise · All chapters',
        provider: pyqByYearProvider(year),
        groupByYear: false,
      ),
    ));
  }
}

// ─────────────────────────────────────────────
// PYQ BROWSE PAGE — full-screen, replaces bottom sheets
// ─────────────────────────────────────────────
class _PYQBrowsePage extends ConsumerStatefulWidget {
  final String title;
  final String subtitle;
  final ProviderListenable<AsyncValue<List<PYQModel>>> provider;
  final bool groupByYear; // true = chapter view (group by year), false = year view (group by chapter)

  const _PYQBrowsePage({
    required this.title,
    required this.subtitle,
    required this.provider,
    required this.groupByYear,
  });

  @override
  ConsumerState<_PYQBrowsePage> createState() => _PYQBrowsePageState();
}

class _PYQBrowsePageState extends ConsumerState<_PYQBrowsePage> {
  String _search = '';
  String _activeFilter = 'all'; // 'all' or year/chapter value

  @override
  Widget build(BuildContext context) {
    final pyqAsync = ref.watch(widget.provider);

    return Scaffold(
      backgroundColor: AppColors.neuBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            Text(widget.subtitle,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
      body: pyqAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text('Could not load questions\n$e',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary)),
        ])),
        data: (allQs) {
          // Group
          final groupMap = <String, List<PYQModel>>{};
          for (final q in allQs) {
            final key = widget.groupByYear ? '${q.year}' : q.chapter;
            groupMap.putIfAbsent(key, () => []).add(q);
          }
          final groups = groupMap.keys.toList()
            ..sort((a, b) => widget.groupByYear
                ? (int.tryParse(b.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0).compareTo((int.tryParse(a.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)) // year: newest first
                : a.compareTo(b));                      // chapter: alphabetical

          // Filter chips values
          final filterValues = ['all', ...groups];

          // Apply search
          var displayQs = _activeFilter == 'all'
              ? allQs
              : groupMap[_activeFilter] ?? [];

          if (_search.isNotEmpty) {
            displayQs = displayQs
                .where((q) =>
                    q.question.toLowerCase().contains(_search.toLowerCase()))
                .toList();
          }

          // Re-group filtered questions
          final displayGroups = <String, List<PYQModel>>{};
          for (final q in displayQs) {
            final key = widget.groupByYear ? '${q.year}' : q.chapter;
            displayGroups.putIfAbsent(key, () => []).add(q);
          }
          final displayGroupKeys = displayGroups.keys.toList()
            ..sort((a, b) => widget.groupByYear
                ? (int.tryParse(b.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0).compareTo((int.tryParse(a.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0))
                : a.compareTo(b));

          return Column(
            children: [
              // ── Toolbar ─────────────────────────────────────
              Container(
                color: AppColors.neuSurface,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats row + Take Test button
                    Row(children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${allQs.length} questions  ·  ${groups.length} ${widget.groupByYear ? 'years' : 'chapters'}',
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow_rounded, size: 18),
                        label: const Text('Take Test'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          final qs = _activeFilter == 'all' ? allQs : (groupMap[_activeFilter] ?? []);
                          if (qs.isEmpty) return;
                          final dur = (qs.length * 60 / 60).ceil();
                          final ok = await showExamStartDialog(context,
                              title: widget.title, questionCount: qs.length,
                              durationMinutes: dur, isPYQ: true);
                          if (!ok || !context.mounted) return;
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => CBTPortal(
                              examId: 'pyq_browse_${widget.title.replaceAll(' ', '_')}',
                              questions: _pyqToQuestions(qs),
                              durationMinutes: dur,
                            ),
                          ));
                        },
                      ),
                    ]),
                    const SizedBox(height: 10),
                    // Search
                    TextField(
                      onChanged: (v) => setState(() => _search = v),
                      decoration: InputDecoration(
                        hintText: 'Search questions…',
                        prefixIcon: const Icon(Icons.search, size: 18),
                        isDense: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                        filled: true,
                        fillColor: AppColors.neuPressedColor,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: filterValues.map((v) {
                          final isAll = v == 'all';
                          final label = isAll
                              ? 'All'
                              : widget.groupByYear
                                  ? v
                                  : 'Ch ${NcertChapters.chapterNumber(v)}';
                          final count = isAll ? allQs.length : (groupMap[v]?.length ?? 0);
                          final sel = _activeFilter == v;
                          return GestureDetector(
                            onTap: () => setState(() => _activeFilter = v),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              margin: const EdgeInsets.only(right: 6, bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: sel ? AppColors.primary : AppColors.neuBackground,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: sel ? AppColors.primary : AppColors.border),
                              ),
                              child: Text('$label ($count)',
                                  style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: sel ? Colors.white : AppColors.textSecondary)),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // ── Question list ────────────────────────────────
              Expanded(
                child: displayGroupKeys.isEmpty
                    ? const Center(
                        child: Text('No questions match',
                            style: TextStyle(color: AppColors.textHint)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: displayGroupKeys.length,
                        itemBuilder: (_, i) {
                          final key = displayGroupKeys[i];
                          final qs = displayGroups[key]!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Group header
                              Container(
                                margin: EdgeInsets.only(bottom: 10, top: i > 0 ? 20 : 0),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 9),
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(children: [
                                  Text(
                                    widget.groupByYear
                                        ? 'NEET $key'
                                        : key,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        fontSize: 13),
                                  ),
                                  const Spacer(),
                                  Text('${qs.length} Qs',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white.withOpacity(0.8))),
                                  const SizedBox(width: 10),
                                  // Take test for this group only
                                  GestureDetector(
                                    onTap: () async {
                                      final dur = (qs.length * 60 / 60).ceil();
                                      final grpTitle = widget.groupByYear ? 'NEET $key' : key;
                                      final ok = await showExamStartDialog(context,
                                          title: grpTitle, questionCount: qs.length,
                                          durationMinutes: dur, isPYQ: true);
                                      if (!ok || !context.mounted) return;
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (_) => CBTPortal(
                                          examId: 'pyq_grp_$key',
                                          questions: _pyqToQuestions(qs),
                                          durationMinutes: dur,
                                        ),
                                      ));
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                        Icon(Icons.play_arrow_rounded, size: 14, color: Colors.white),
                                        SizedBox(width: 3),
                                        Text('Test', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
                                      ]),
                                    ),
                                  ),
                                ]),
                              ),
                              // Questions
                              ...qs.asMap().entries.map((e) =>
                                _PYQQuestionCard(
                                  q: e.value,
                                  number: e.key + 1,
                                  isBookmarked: ref.watch(bookmarkProvider).contains(e.value.id),
                                  onToggleBookmark: () => ref.read(bookmarkProvider.notifier).toggle(e.value.id),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Heuristic difficulty tagger ───────────────────────────────
// No DB column needed — infers from question text patterns.
({String label, Color color}) _difficultyOf(String text) {
  final t = text.toLowerCase();
  // Hard markers: negation questions, multi-statement matching, "except/not/incorrect"
  final hardPatterns = ['except', 'not correct', 'incorrect', 'false statement',
      'which of the following is not', 'identify the incorrect', 'wrongly matched',
      'wrongly paired', 'mismatch', 'does not'];
  if (hardPatterns.any((p) => t.contains(p))) {
    return (label: 'Hard', color: const Color(0xFFE53935));
  }
  // Medium markers: multi-select, assertion-reason, match-the-following
  final medPatterns = ['assertion', 'reason', 'match the following', 'column i',
      'column ii', 'both a and r', 'which of the following statements',
      'select the correct'];
  if (medPatterns.any((p) => t.contains(p))) {
    return (label: 'Medium', color: const Color(0xFFFF8F00));
  }
  return (label: 'Easy', color: const Color(0xFF43A047));
}

// ── Full PYQ question card with bookmark + answer reveal ──────
class _PYQQuestionCard extends StatefulWidget {
  final PYQModel q;
  final int number;
  final bool isBookmarked;
  final VoidCallback onToggleBookmark;

  const _PYQQuestionCard({
    required this.q,
    required this.number,
    required this.isBookmarked,
    required this.onToggleBookmark,
  });

  @override
  State<_PYQQuestionCard> createState() => _PYQQuestionCardState();
}

class _PYQQuestionCardState extends State<_PYQQuestionCard> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final diff = _difficultyOf(widget.q.question);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.neuSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.neuRaisedSoft,
        border: widget.isBookmarked
            ? Border.all(color: AppColors.accent, width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Number badge
                Container(
                  width: 26, height: 26,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Center(
                    child: Text('${widget.number}',
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w800,
                            color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 6),
                // Difficulty pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: diff.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: diff.color.withOpacity(0.3)),
                  ),
                  child: Text(diff.label,
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: diff.color)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(widget.q.question,
                      style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          height: 1.55,
                          color: AppColors.textPrimary)),
                ),
                IconButton(
                  icon: Icon(
                    widget.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: widget.isBookmarked ? AppColors.accent : AppColors.textHint,
                    size: 20,
                  ),
                  onPressed: () {
                    HapticService.selection();
                    widget.onToggleBookmark();
                  },
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          if (widget.q.imageUrl != null && widget.q.imageUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: widget.q.imageUrl!,
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
            ),
          const SizedBox(height: 10),
          // Options
          AnimatedSize(
           duration: const Duration(milliseconds: 280),
           curve: Curves.easeOutCubic,
           child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              children: ['A', 'B', 'C', 'D'].map((opt) {
                final isCorrect = _revealed && opt.toUpperCase() == widget.q.correctOption.toUpperCase();
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? AppColors.successSurface
                        : AppColors.neuBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCorrect ? AppColors.success : AppColors.border,
                      width: isCorrect ? 1.5 : 1,
                    ),
                  ),
                  child: Row(children: [
                    Container(
                      width: 22, height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCorrect ? AppColors.success : AppColors.neuSurface,
                        border: Border.all(
                            color: isCorrect ? AppColors.success : AppColors.border),
                      ),
                      child: Center(
                        child: Text(opt,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: isCorrect ? Colors.white : AppColors.textSecondary)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(widget.q.optionText(opt),
                          style: TextStyle(
                              fontSize: 12.5,
                              height: 1.4,
                              color: isCorrect ? AppColors.success : AppColors.textPrimary,
                              fontWeight: isCorrect ? FontWeight.w600 : FontWeight.w400)),
                    ),
                    if (isCorrect) const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                  ]),
                );
              }).toList(),
            ),
           ),
          ),
          // Answer / Explanation row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
            child: Row(children: [
              TextButton.icon(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() => _revealed = !_revealed);
                },
                icon: Icon(_revealed ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 15),
                label: Text(_revealed ? 'Hide Answer' : 'Show Answer',
                    style: const TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
              ),
              if (widget.q.explanation != null && _revealed) ...[
                const Spacer(),
                Flexible(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.infoSurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Icon(Icons.lightbulb_outline, size: 13, color: AppColors.info),
                        const SizedBox(width: 5),
                        Expanded(child: Text(widget.q.explanation!,
                            style: const TextStyle(fontSize: 11, color: AppColors.info, height: 1.4))),
                      ]),
                    ),
                  ),
                ),
              ],
            ]),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CUSTOM TEST TAB
// ─────────────────────────────────────────────
class _CustomTestTab extends ConsumerStatefulWidget {
  const _CustomTestTab();

  @override
  ConsumerState<_CustomTestTab> createState() => _CustomTestTabState();
}

class _CustomTestTabState extends ConsumerState<_CustomTestTab> {
  // Mode: 'chapter' or 'year'
  String _mode = 'chapter';
  final Set<String> _selChapters = {};
  final Set<String> _selYears = {};
  int? _questionCount;
  bool _building = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;
    final studentClass = user?.studentClass ?? '11';
    final chaptersAsync = ref.watch(pyqChaptersProvider);
    final yearsAsync = ref.watch(pyqYearsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Custom PYQ Test',
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text(
              'Select chapters or years, choose question count, and take a timed test.',
              style: TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 24),

          // Mode toggle
          Row(children: [
            _ModeBtn('By Chapter', _mode == 'chapter',
                () => setState(() { _mode = 'chapter'; _selYears.clear(); })),
            const SizedBox(width: 10),
            _ModeBtn('By Year', _mode == 'year',
                () => setState(() { _mode = 'year'; _selChapters.clear(); })),
          ]),
          const SizedBox(height: 20),

          // Chapter selector
          if (_mode == 'chapter')
            chaptersAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
              data: (allChapters) {
                // Class-11 students only see Class-11 chapters
                final chapters = studentClass == '11'
                    ? allChapters.where((ch) => NcertChapters.classFor(ch) == '11').toList()
                    : allChapters;
                return SolidCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text('Select Chapters',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15)),
                        ),
                        if (_selChapters.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('${_selChapters.length} selected',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                          ),
                        TextButton(
                          onPressed: () => setState(() {
                            if (_selChapters.length == chapters.length) {
                              _selChapters.clear();
                            } else {
                              _selChapters.addAll(chapters);
                            }
                          }),
                          child: Text(
                              _selChapters.length == chapters.length
                                  ? 'Clear All'
                                  : 'Select All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: chapters
                          .map((ch) => FilterChip(
                                label: Text(ch,
                                    style: const TextStyle(fontSize: 11)),
                                selected: _selChapters.contains(ch),
                                onSelected: (v) => setState(() =>
                                    v ? _selChapters.add(ch) : _selChapters.remove(ch)),
                                selectedColor: AppColors.primarySurface,
                                checkmarkColor: AppColors.primary,
                              ))
                          .toList(),
                    ),
                  ],
                ),
              );  // SolidCard
              },  // data: block
            ),    // chaptersAsync.when

          // Year selector (max 2)
          if (_mode == 'year')
            yearsAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
              data: (years) => SolidCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Expanded(child: Text('Select Years (max 2)',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
                      if (_selYears.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('${_selYears.length} selected',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                        ),
                    ]),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: years
                          .map((yr) => FilterChip(
                                label: Text('$yr',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700)),
                                selected: _selYears.contains(yr),
                                onSelected: (v) {
                                  if (v && _selYears.length >= AppConstants.maxPyqYearsSelectable) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                            content: Text('Max 2 years')));
                                    return;
                                  }
                                  setState(() =>
                                      v ? _selYears.add(yr) : _selYears.remove(yr));
                                },
                                selectedColor: AppColors.primarySurface,
                                checkmarkColor: AppColors.primary,
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Question count selector
          if (_selChapters.isNotEmpty || _selYears.isNotEmpty)
            _QuestionCountSelector(
              mode: _mode,
              selChapters: _selChapters.toList(),
              selYears: _selYears.toList(),
              onCountSelected: (c) => setState(() => _questionCount = c),
              selectedCount: _questionCount,
            ),

          const SizedBox(height: 24),

          // Start button
          if ((_selChapters.isNotEmpty || _selYears.isNotEmpty) &&
              _questionCount != null)
            GradientButton(
              label: _building ? 'Building...' : 'Start Custom Test',
              icon: Icons.play_arrow,
              isLoading: _building,
              width: double.infinity,
              onPressed: _startCustomTest,
            ),
        ],
      ),
    );
  }

  Future<void> _startCustomTest() async {
    setState(() => _building = true);
    List<PYQModel> pool = [];
    if (_mode == 'chapter') {
      pool = await SupabaseService.instance
          .getPYQByChapters(_selChapters.toList());
    } else {
      pool = await SupabaseService.instance
          .getPYQByYears(_selYears.toList());
    }

    // Shuffle and limit
    pool.shuffle();
    final pyqList = pool.take(_questionCount ?? pool.length).toList();
    final questions = _pyqToQuestions(pyqList);

    setState(() => _building = false);

    if (!mounted) return;
    final dur = (questions.length * 60 / 60).ceil();
    final ok = await showExamStartDialog(context,
        title: 'Custom PYQ Test',
        questionCount: questions.length,
        durationMinutes: dur,
        isPYQ: true);
    if (!ok || !mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CBTPortal(
          examId: 'pyq_custom_${DateTime.now().millisecondsSinceEpoch}',
          questions: questions,
          durationMinutes: dur,
        ),
      ),
    );
  }
}

class _QuestionCountSelector extends ConsumerWidget {
  final String mode;
  final List<String> selChapters;
  final List<String> selYears;
  final ValueChanged<int> onCountSelected;
  final int? selectedCount;

  const _QuestionCountSelector({
    required this.mode,
    required this.selChapters,
    required this.selYears,
    required this.onCountSelected,
    this.selectedCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(pyqByChaptersProvider(selChapters));
    final yearsAsync = ref.watch(pyqByYearsProvider(selYears));

    final future = mode == 'chapter' ? chaptersAsync : yearsAsync;

    return future.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (questions) {
        final total = questions.length;
        if (total == 0) {
          return const Text(
            'No questions available for this selection.',
            style: TextStyle(color: AppColors.warning),
          );
        }

        // Offer sensible options
        final opts = <int>[];
        for (final n in [10, 20, 30, 45, total]) {
          if (n <= total && !opts.contains(n)) opts.add(n);
        }

        return SolidCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Question Count  ($total available)',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: opts
                    .map((n) => ChipButton(
                          label: n == total ? 'All ($n)' : '$n',
                          selected: selectedCount == n,
                          onTap: () => onCountSelected(n),
                        ))
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget _EmptyState({required IconData icon, required String message}) =>
    Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 60, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary, height: 1.6),
            ),
          ],
        ),
      ),
    );

// ─────────────────────────────────────────────
// BOOKMARKS TAB
// ─────────────────────────────────────────────
class _BookmarksTab extends ConsumerWidget {
  const _BookmarksTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarked = ref.watch(bookmarkProvider);
    final allAsync = ref.watch(allPYQProvider);

    if (bookmarked.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: AppColors.neuSurface,
                shape: BoxShape.circle,
                boxShadow: AppColors.neuRaisedSoft,
              ),
              child: const Icon(Icons.bookmark_border_rounded, size: 34, color: AppColors.textHint),
            ).animate().scale(begin: const Offset(0.7, 0.7), duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: 16),
            const Text('No Saved Questions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            const Text(
              'Tap the bookmark icon on any question\nwhile browsing to save it here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textHint, height: 1.6),
            ),
          ]),
        ),
      );
    }

    return allAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (_, __) => const Center(child: Text('Could not load questions')),
      data: (all) {
        final saved = all.where((q) => bookmarked.contains(q.id)).toList();
        if (saved.isEmpty) {
          return const Center(child: Text('Bookmarked questions not found',
              style: TextStyle(color: AppColors.textHint)));
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 32),
          itemCount: saved.length,
          itemBuilder: (_, i) {
            final q = saved[i];
            return _PYQQuestionCard(
              q: q,
              number: i + 1,
              isBookmarked: true,
              onToggleBookmark: () => ref.read(bookmarkProvider.notifier).toggle(q.id),
            ).animate(delay: (i * 20).ms).fadeIn(duration: 200.ms).slideY(begin: 0.05);
          },
        );
      },
    );
  }
}

Widget _ModeBtn(String label, bool selected, VoidCallback onTap) =>
    GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.primaryGradient : null,
          color: selected ? null : AppColors.neuBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color:
                  selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.textSecondary),
        ),
      ),
    );

