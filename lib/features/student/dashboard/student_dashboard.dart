import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
// fl_chart provides both LineChart and BarChart
import '../../../core/constants/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/badge_model.dart';
import '../../../models/exam_model.dart';
import '../../../models/exam_result_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/exam_provider.dart';
import '../../../providers/student_provider.dart';

import '../../../models/offline_test_model.dart';
import '../../../services/badge_service.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/badge_widget.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/neu_refresh.dart';
import '../../../widgets/onboarding_tour.dart';
import '../../../widgets/skeleton.dart';
import '../../../widgets/stat_card.dart';

// Live stream — updates the dashboard instantly when teacher enters marks.
final _offlineDashProvider =
    StreamProvider.family<List<OfflineTestModel>, String>((ref, batch) {
  return SupabaseService.instance.streamOfflineTestsByBatch(batch);
});

class StudentDashboard extends ConsumerWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authProvider);
    return userAsync.when(
      loading: () => const SkeletonDashboard(),
      error: (_, __) => const _ErrorState(),
      data: (user) => user == null
          ? const _ErrorState()
          : _DashboardBody(user: user),
    );
  }
}

class _DashboardBody extends ConsumerStatefulWidget {
  final UserModel user;
  const _DashboardBody({required this.user});
  @override
  ConsumerState<_DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends ConsumerState<_DashboardBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).refreshCurrentUser();
      // Show 3-slide onboarding tour on first ever login
      maybeShowTour(context);
      // Badge check on app open (retroactive on first time)
      BadgeService.instance.checkAndAward(ref, context, isRetroactive: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final resultsAsync = ref.watch(studentResultsProvider(user.id));
    final batchExamsAsync = ref.watch(batchExamsProvider(user.batch));
    final batchStudentsAsync = ref.watch(batchStudentsProvider(user.batch));
    final offlineAsync = ref.watch(_offlineDashProvider(user.batch));
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 600;

    return NeuRefreshIndicator(
      onRefresh: () async {
        await ref.read(authProvider.notifier).refreshCurrentUser();
        ref.invalidate(studentResultsProvider(user.id));
        ref.invalidate(batchExamsProvider(user.batch));
        ref.invalidate(_offlineDashProvider(user.batch));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome banner
            _WelcomeBanner(user: user)
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: -0.1),
            SizedBox(height: isMobile ? 16 : 24),

            // Stats row
            resultsAsync.when(
              loading: () => Row(children: List.generate(3, (i) => Expanded(
                child: Padding(padding: EdgeInsets.only(right: i < 2 ? 10 : 0),
                    child: const SkeletonCard(height: 88))))),
              error: (_, __) => const SizedBox.shrink(),
              data: (results) => _StatsRow(results: results, isMobile: isMobile),
            ),
            SizedBox(height: isMobile ? 16 : 24),

            // Main content area
            if (isMobile)
              _MobileContent(
                user: user,
                resultsAsync: resultsAsync,
                batchExamsAsync: batchExamsAsync,
                batchStudentsAsync: batchStudentsAsync,
                offlineAsync: offlineAsync,
              )
            else
              _DesktopContent(
                user: user,
                resultsAsync: resultsAsync,
                batchExamsAsync: batchExamsAsync,
                batchStudentsAsync: batchStudentsAsync,
                offlineAsync: offlineAsync,
              ),
          ],
        ),
      ),
    );
  }
}

// ── Welcome banner ─────────────────────────────────────────────
class _WelcomeBanner extends StatelessWidget {
  final UserModel user;
  const _WelcomeBanner({required this.user});

  @override
  Widget build(BuildContext context) {
    final h = DateTime.now().hour;
    final greeting = h < 12 ? 'Good morning' : h < 17 ? 'Good afternoon' : 'Good evening';
    final greetIcon = h < 12 ? Icons.wb_sunny_outlined
        : h < 17 ? Icons.light_mode_outlined
        : Icons.nights_stay_outlined;

    return GradientCard(
      gradient: AppColors.primaryGradient,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(greetIcon, size: 13, color: Colors.white.withOpacity(0.75)),
                  const SizedBox(width: 5),
                  Text(greeting,
                      style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.white.withOpacity(0.75),
                          fontWeight: FontWeight.w500)),
                ]),
                const SizedBox(height: 5),
                Text(user.name.split(' ').first,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.1,
                        letterSpacing: -0.3),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 10),
                Row(children: [
                  _BannerTag(user.batch),
                  const SizedBox(width: 6),
                  _BannerTag('Class ${user.studentClass}'),
                ]),
                const SizedBox(height: 8),
                _FeeStatusBadge(user: user),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // PrepCoins badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: Colors.white.withOpacity(0.2), width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on_rounded,
                    color: Colors.amber, size: 26),
                const SizedBox(height: 3),
                Text('${user.prepcoins}',
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Colors.white)),
                Text('PrepCoins',
                    style: TextStyle(
                        fontSize: 9,
                        color: Colors.white.withOpacity(0.65),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerTag extends StatelessWidget {
  final String text;
  const _BannerTag(this.text);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text,
            style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
      );
}

class _FeeStatusBadge extends StatelessWidget {
  final UserModel user;
  const _FeeStatusBadge({required this.user});

  @override
  Widget build(BuildContext context) {
    final status = user.currentMonthFeeStatus;
    final now = DateTime.now();
    final currentKey = DateFormat('yyyy-MM').format(now);
    final inDb = user.monthlyPayments.containsKey(currentKey) ||
        user.feeExemptMonths.contains(currentKey);

    final Color dotColor = !inDb
        ? Colors.grey.shade400
        : status == 'paid'
            ? Colors.greenAccent
            : status == 'exempt'
                ? Colors.lightBlueAccent
                : Colors.redAccent;

    final String symbol = !inDb ? '·' : status == 'paid' ? '✦' : status == 'exempt' ? '◎' : '×';

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _FeeCalendarSheet(user: user),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: dotColor.withOpacity(0.22),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: dotColor.withOpacity(0.5), width: 1),
          boxShadow: [
            BoxShadow(color: dotColor.withOpacity(0.45), blurRadius: 8, spreadRadius: 0),
          ],
        ),
        child: Text(symbol,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: dotColor,
                height: 1)),
      ),
    );
  }
}

class _FeeCalendarSheet extends StatelessWidget {
  final UserModel user;
  const _FeeCalendarSheet({required this.user});

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentYear = now.year;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF0F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 36, height: 3.5,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.12),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              const Icon(Icons.grid_view_rounded, size: 15, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text('$currentYear  ·  Monthly Overview',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ]),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(6, (i) {
                final month = i + 1;
                final key = DateFormat('yyyy-MM').format(DateTime(currentYear, month));
                final inDb = user.monthlyPayments.containsKey(key) ||
                    user.feeExemptMonths.contains(key);
                final status = user.feeStatusFor(key);
                final isCurrentMonth = month == now.month;
                final Color color;
                final String symbol;
                if (!inDb) {
                  color = Colors.grey.shade400;
                  symbol = '·';
                } else if (status == 'paid') {
                  color = Colors.green;
                  symbol = '✦';
                } else if (status == 'exempt') {
                  color = const Color(0xFF2196F3);
                  symbol = '◎';
                } else {
                  color = Colors.red;
                  symbol = '×';
                }
                return Expanded(child: _MonthCell(
                  label: _monthNames[i],
                  symbol: symbol,
                  color: color,
                  isCurrent: isCurrentMonth,
                  dim: !inDb,
                ));
              }),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(6, (i) {
                final month = i + 7;
                final key = DateFormat('yyyy-MM').format(DateTime(currentYear, month));
                final inDb = user.monthlyPayments.containsKey(key) ||
                    user.feeExemptMonths.contains(key);
                final status = user.feeStatusFor(key);
                final isCurrentMonth = month == now.month;
                final Color color;
                final String symbol;
                if (!inDb) {
                  color = Colors.grey.shade400;
                  symbol = '·';
                } else if (status == 'paid') {
                  color = Colors.green;
                  symbol = '✦';
                } else if (status == 'exempt') {
                  color = const Color(0xFF2196F3);
                  symbol = '◎';
                } else {
                  color = Colors.red;
                  symbol = '×';
                }
                return Expanded(child: _MonthCell(
                  label: _monthNames[i + 6],
                  symbol: symbol,
                  color: color,
                  isCurrent: isCurrentMonth,
                  dim: !inDb,
                ));
              }),
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _FeeLegendItem(Colors.green, '✦'),
                SizedBox(width: 12),
                _FeeLegendItem(Colors.red, '×'),
                SizedBox(width: 12),
                _FeeLegendItem(Color(0xFF2196F3), '◎'),
                SizedBox(width: 12),
                _FeeLegendItem(Colors.grey, '○'),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _MonthCell extends StatelessWidget {
  final String label;
  final String symbol;
  final Color color;
  final bool isCurrent;
  final bool dim;
  const _MonthCell({
    required this.label,
    required this.symbol,
    required this.color,
    required this.isCurrent,
    this.dim = false,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: dim ? Colors.transparent : color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: dim
                ? Colors.grey.withOpacity(0.15)
                : isCurrent
                    ? color
                    : color.withOpacity(0.25),
            width: isCurrent && !dim ? 1.5 : 0.8,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(symbol,
                style: TextStyle(
                    fontSize: dim ? 16 : 13,
                    color: dim ? Colors.grey.shade300 : color,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: isCurrent && !dim ? FontWeight.w900 : FontWeight.w600,
                    color: dim ? Colors.grey.shade400 : color)),
          ],
        ),
      );
}

class _FeeLegendItem extends StatelessWidget {
  final Color color;
  final String symbol;
  const _FeeLegendItem(this.color, this.symbol);

  @override
  Widget build(BuildContext context) => Text(symbol,
      style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w900));
}


// ── Stats row — first attempts only ───────────────────────────
class _StatsRow extends StatelessWidget {
  final List<ExamResultModel> results;
  final bool isMobile;
  const _StatsRow({required this.results, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final attempted = results.length; // first attempts only
    final avgScore = results.isEmpty ? 0.0
        : results.map((r) => r.percentage).reduce((a, b) => a + b) / results.length;
    final bestScore = results.isEmpty ? 0.0
        : results.map((r) => r.percentage).reduce((a, b) => a > b ? a : b);

    return Row(
      children: [
        Expanded(child: _StatMiniCard(
          'Exams (1st)',
          '$attempted',
          Icons.quiz_rounded,
          AppColors.primary,
          0,
          tooltip: 'Number of online exams you have attempted at least once.\nOnly first-attempt scores are recorded officially.',
        )),
        const SizedBox(width: 10),
        Expanded(child: _StatMiniCard(
          'Avg Score',
          '${avgScore.toStringAsFixed(0)}%',
          Icons.show_chart_rounded,
          AppColors.info,
          1,
          tooltip: 'Average score across all your first attempts.\nThis is your official performance metric.',
        )),
        const SizedBox(width: 10),
        Expanded(child: _StatMiniCard(
          'Best Score',
          '${bestScore.toStringAsFixed(0)}%',
          Icons.emoji_events_rounded,
          AppColors.success,
          2,
          tooltip: 'Your highest first-attempt score.\nRetake scores do not count here.',
        )),
      ],
    );
  }
}

class _StatMiniCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final int delay;
  final String? tooltip;
  const _StatMiniCard(this.label, this.value, this.icon, this.color, this.delay,
      {this.tooltip});

  @override
  Widget build(BuildContext context) {
    Widget card = SolidCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            if (tooltip != null) ...[
              const Spacer(),
              Tooltip(
                message: tooltip!,
                preferBelow: false,
                textStyle: const TextStyle(fontSize: 11, color: Colors.white),
                child: const Icon(Icons.info_outline_rounded,
                    size: 13, color: AppColors.textHint),
              ),
            ],
          ]),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
          Text(label,
              style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
    return card.animate(delay: (delay * 60).ms).fadeIn(duration: 300.ms)
        .slideY(begin: 0.2, curve: Curves.easeOut);
  }
}

// ── Mobile-specific layout ─────────────────────────────────────
class _MobileContent extends StatelessWidget {
  final UserModel user;
  final AsyncValue<List<ExamResultModel>> resultsAsync;
  final AsyncValue<List<ExamModel>> batchExamsAsync;
  final AsyncValue<List<UserModel>> batchStudentsAsync;
  final AsyncValue<List<OfflineTestModel>> offlineAsync;

  const _MobileContent({
    required this.user,
    required this.resultsAsync,
    required this.batchExamsAsync,
    required this.batchStudentsAsync,
    required this.offlineAsync,
  });

  @override
  Widget build(BuildContext context) => Column(
        children: [
          const _QuickAccess(isMobile: true),
          const SizedBox(height: 16),
          // Online first-attempt performance graph
          resultsAsync.when(
            loading: () => const SkeletonCard(height: 220),
            error: (_, __) => const SizedBox.shrink(),
            data: (r) => r.isEmpty ? const SizedBox.shrink()
                : _PerformanceChart(results: r, title: 'Online Exams (1st Attempt)'),
          ),
          const SizedBox(height: 16),
          // Offline marks graph
          offlineAsync.when(
            loading: () => const SkeletonCard(height: 180),
            error: (_, __) => const SizedBox.shrink(),
            data: (tests) => _OfflineChart(tests: tests, userId: user.id),
          ),
          const SizedBox(height: 16),
          batchExamsAsync.when(
            loading: () => const SkeletonCard(height: 130),
            error: (_, __) => const SizedBox.shrink(),
            data: (exams) => _UpcomingTests(exams: exams),
          ),
          const SizedBox(height: 16),
          _BadgesSection(user: user),
        ],
      );
}

// ── Desktop layout ─────────────────────────────────────────────
class _DesktopContent extends StatelessWidget {
  final UserModel user;
  final AsyncValue<List<ExamResultModel>> resultsAsync;
  final AsyncValue<List<ExamModel>> batchExamsAsync;
  final AsyncValue<List<UserModel>> batchStudentsAsync;
  final AsyncValue<List<OfflineTestModel>> offlineAsync;

  const _DesktopContent({
    required this.user,
    required this.resultsAsync,
    required this.batchExamsAsync,
    required this.batchStudentsAsync,
    required this.offlineAsync,
  });

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Column(children: [
              const _QuickAccess(isMobile: false),
              const SizedBox(height: 20),
              resultsAsync.when(
                loading: () => const SkeletonCard(height: 220),
                error: (_, __) => const SizedBox.shrink(),
                data: (r) => r.isEmpty ? const SizedBox.shrink()
                    : _PerformanceChart(results: r, title: 'Online Exams (1st Attempt)'),
              ),
              const SizedBox(height: 20),
              offlineAsync.when(
                loading: () => const SkeletonCard(height: 180),
                error: (_, __) => const SizedBox.shrink(),
                data: (tests) => _OfflineChart(tests: tests, userId: user.id),
              ),
            ]),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 4,
            child: Column(children: [
              batchExamsAsync.when(
                loading: () => const SkeletonCard(height: 160),
                error: (_, __) => const SizedBox.shrink(),
                data: (exams) => _UpcomingTests(exams: exams),
              ),
              const SizedBox(height: 20),
              _BadgesSection(user: user),
            ]),
          ),
        ],
      );
}

// ── Quick access grid ─────────────────────────────────────────
class _QuickAccess extends StatelessWidget {
  final bool isMobile;
  const _QuickAccess({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final items = [
      const _QItem('Online Tests',  Icons.quiz_rounded,          AppColors.primaryGradient,  Routes.studentOnlineTests),
      const _QItem('PYQ',           Icons.history_edu_rounded,   AppColors.aquaGradient,     Routes.studentPyq),
      const _QItem('Flashcards',    Icons.style_rounded,         AppColors.successGradient,  Routes.studentFlashcards),
      const _QItem('Glossary',      Icons.auto_stories_rounded,  AppColors.accentGradient,   Routes.studentGlossary),
      const _QItem('Bio Lab',       Icons.science_rounded,       AppColors.warmGradient,     Routes.studentBioLab),
      const _QItem('Games',         Icons.sports_esports_rounded,LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFD946EF)]), Routes.studentGames),
    ];

    return SolidCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Access',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 14),
          LayoutBuilder(builder: (ctx, constraints) {
            // 2 columns on very small screens (<320px), 3 on everything else
            final cols = constraints.maxWidth < 300 ? 2 : 3;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.05,
              ),
              itemCount: items.length,
              itemBuilder: (_, i) => _QuickTile(item: items[i], index: i),
            );
          }),
        ],
      ),
    );
  }
}

class _QItem {
  final String label;
  final IconData icon;
  final Gradient gradient;
  final String route;
  const _QItem(this.label, this.icon, this.gradient, this.route);
}

class _QuickTile extends StatefulWidget {
  final _QItem item;
  final int index;
  const _QuickTile({required this.item, required this.index});

  @override
  State<_QuickTile> createState() => _QuickTileState();
}

class _QuickTileState extends State<_QuickTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 150));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) { setState(() => _pressed = true); _ctrl.forward(); },
      onTapUp: (_) {
        setState(() => _pressed = false);
        _ctrl.reverse();
        HapticFeedback.lightImpact();
        context.go(widget.item.route);
      },
      onTapCancel: () { setState(() => _pressed = false); _ctrl.reverse(); },
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Transform.scale(
          scale: 1.0 - _ctrl.value * 0.04,
          child: Container(
            decoration: BoxDecoration(
              gradient: widget.item.gradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12 + _ctrl.value * 0.04),
                  blurRadius: 12 + _ctrl.value * 4,
                  offset: Offset(0, 4 + _ctrl.value * 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.item.icon, color: Colors.white, size: 26),
                const SizedBox(height: 7),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(widget.item.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: (widget.index * 50).ms).fadeIn(duration: 300.ms)
        .scale(begin: const Offset(0.85, 0.85), curve: Curves.easeOut);
  }
}

// ── Online performance chart ──────────────────────────────────
class _PerformanceChart extends StatelessWidget {
  final List<ExamResultModel> results;
  final String title;
  const _PerformanceChart({required this.results, this.title = 'Performance'});

  @override
  Widget build(BuildContext context) {
    final data = results.reversed.take(10).toList().reversed.toList();
    final spots = data.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.percentage as double))
        .toList();

    return SolidCard(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text(title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800))),
            InfoChip('Last ${data.length}', AppColors.primary),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: LineChart(LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.35,
                  color: AppColors.primary,
                  barWidth: 3,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (_, __, ___, i) => FlDotCirclePainter(
                      radius: 5,
                      color: AppColors.primary,
                      strokeWidth: 2.5,
                      strokeColor: Colors.white,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.18),
                        AppColors.primary.withOpacity(0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  getTitlesWidget: (v, _) => Text('${v.toInt()}%',
                      style: const TextStyle(fontSize: 10,
                          color: AppColors.textHint)),
                )),
                bottomTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => const FlLine(
                    color: AppColors.border, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              minY: 0, maxY: 100,
            )),
          ),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn(duration: 400.ms);
  }
}

// ── Offline marks bar chart ───────────────────────────────────
class _OfflineChart extends StatelessWidget {
  final List<OfflineTestModel> tests;
  final String userId;
  const _OfflineChart({required this.tests, required this.userId});

  @override
  Widget build(BuildContext context) {
    final scored = tests
        .where((t) => t.studentMarks.containsKey(userId) &&
            t.studentMarks[userId] != null)
        .toList();

    if (scored.isEmpty) return const SizedBox.shrink();

    return SolidCard(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Expanded(child: Text('Offline Test Marks',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800))),
            InfoChip('${scored.length} tests', AppColors.bioGreen),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            height: 130,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: scored.asMap().entries.map((e) {
                  final t = e.value;
                  final score = t.studentMarks[userId]!;
                  final pct = t.fullMarks > 0 ? score / t.fullMarks * 100 : 0.0;
                  final color = pct >= 70
                      ? AppColors.success
                      : pct >= 40
                          ? AppColors.warning
                          : AppColors.error;
                  return BarChartGroupData(x: e.key, barRods: [
                    BarChartRodData(
                      toY: pct,
                      color: color,
                      width: 16,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ]);
                }).toList(),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true, reservedSize: 32,
                    getTitlesWidget: (v, _) => Text('${v.toInt()}%',
                        style: const TextStyle(fontSize: 9, color: AppColors.textHint)),
                  )),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true, reservedSize: 28,
                    getTitlesWidget: (v, _) {
                      final idx = v.toInt();
                      if (idx >= scored.length) return const SizedBox.shrink();
                      final name = scored[idx].name;
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          name.length > 8 ? '${name.substring(0, 7)}…' : name,
                          style: const TextStyle(fontSize: 8, color: AppColors.textSecondary),
                        ),
                      );
                    },
                  )),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) =>
                        const FlLine(color: AppColors.border, strokeWidth: 1)),
                borderData: FlBorderData(show: false),
                minY: 0, maxY: 100,
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: 250.ms).fadeIn(duration: 400.ms);
  }
}

// ── Upcoming tests ────────────────────────────────────────────
class _UpcomingTests extends StatelessWidget {
  final List<dynamic> exams;
  const _UpcomingTests({required this.exams});

  @override
  Widget build(BuildContext context) {
    final visible = exams.take(4).toList();
    return SolidCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Expanded(child: Text('Active Tests',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800))),
            TextButton(
              onPressed: () => context.go(Routes.studentOnlineTests),
              child: const Text('See all'),
            ),
          ]),
          if (visible.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('No active tests',
                  style: TextStyle(color: AppColors.textHint))),
            )
          else
            ...visible.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(child: Text('📝',
                        style: TextStyle(fontSize: 18))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.value.title,
                          style: const TextStyle(fontSize: 13,
                              fontWeight: FontWeight.w700),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('${e.value.durationMinutes} min · ${e.value.difficulty}',
                          style: const TextStyle(fontSize: 11,
                              color: AppColors.textSecondary)),
                    ],
                  )),
                  if ((e.value.expRequired as int) > 0)
                    InfoChip('🪙 ${e.value.expRequired}', AppColors.accent),
                ],
              ).animate(delay: (e.key * 40).ms).fadeIn(duration: 200.ms),
            )),
        ],
      ),
    );
  }
}

// ── Badges section ────────────────────────────────────────────
class _BadgesSection extends StatelessWidget {
  final UserModel user;
  const _BadgesSection({required this.user});

  @override
  Widget build(BuildContext context) {
    final recent = user.earnedBadgeIds.take(6).toList();
    return SolidCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Badges (${user.earnedBadgeIds.length})',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          if (recent.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('Complete challenges to earn badges!',
                    style: TextStyle(color: AppColors.textHint, fontSize: 13),
                    textAlign: TextAlign.center),
              ),
            )
          else
            Wrap(
              spacing: 10, runSpacing: 10,
              children: recent.map((id) {
                final badge = BadgeDefinitions.findById(id);
                if (badge == null) return const SizedBox.shrink();
                return BadgeWidget(badge: badge, earned: true);
              }).toList(),
            ),
        ],
      ),
    ).animate(delay: 300.ms).fadeIn(duration: 400.ms);
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();
  @override
  Widget build(BuildContext context) => const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.error_outline, size: 60, color: AppColors.textHint),
          SizedBox(height: 12),
          Text('Something went wrong', style: TextStyle(color: AppColors.textSecondary)),
        ]),
      );
}
