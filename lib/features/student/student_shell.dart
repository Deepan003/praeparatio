import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/neu_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/exam_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/toast_service.dart';
import '../../widgets/adaptive_nav.dart';
import '../../widgets/animated_logo.dart';
import '../../widgets/neu_widgets.dart';
import '../../widgets/notification_bell.dart';
import '../../widgets/stat_card.dart';
import '../student/notifications/notification_screen.dart';
import '../../models/developer_info_model.dart';
import '../../providers/developer_provider.dart';
import '../maintenance/maintenance_screen.dart';
import 'developer/developer_modal.dart';

final _allNavItems = [
  const NavItem(label: 'Home',    icon: Icons.home_outlined,          selectedIcon: Icons.home_rounded,          route: Routes.studentDashboard),
  const NavItem(label: 'Tests',   icon: Icons.quiz_outlined,          selectedIcon: Icons.quiz_rounded,          route: Routes.studentOnlineTests),
  const NavItem(label: 'Results', icon: Icons.assignment_outlined,    selectedIcon: Icons.assignment_rounded,    route: Routes.studentOfflineResults),
  const NavItem(label: 'PYQs',    icon: Icons.history_edu_outlined,   selectedIcon: Icons.history_edu,           route: Routes.studentPyq),
  const NavItem(label: 'Cards',   icon: Icons.style_outlined,         selectedIcon: Icons.style_rounded,         route: Routes.studentFlashcards),
  const NavItem(label: 'Glossary',icon: Icons.auto_stories_outlined,  selectedIcon: Icons.auto_stories,          route: Routes.studentGlossary),
  const NavItem(label: 'Bio Lab', icon: Icons.science_outlined,       selectedIcon: Icons.science_rounded,       route: Routes.studentBioLab),
  const NavItem(label: 'Games',   icon: Icons.sports_esports_outlined,selectedIcon: Icons.sports_esports_rounded,route: Routes.studentGames),
  const NavItem(label: 'Notes',   icon: Icons.folder_outlined,        selectedIcon: Icons.folder_rounded,        route: Routes.studentNotes),
  const NavItem(label: 'Chat',    icon: Icons.chat_bubble_outline,    selectedIcon: Icons.chat_bubble_rounded,   route: Routes.studentChatbot),
  const NavItem(label: 'History', icon: Icons.history_outlined,       selectedIcon: Icons.history_rounded,       route: Routes.studentHistory),
];

class StudentShell extends ConsumerStatefulWidget {
  final Widget child;
  const StudentShell({super.key, required this.child});

  @override
  ConsumerState<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends ConsumerState<StudentShell> {
  RealtimeChannel? _examsChannel;
  RealtimeChannel? _resultsChannel;

  @override
  void initState() {
    super.initState();
    // Subscribe to exams table changes — instantly refresh list when
    // admin publishes a new exam or changes visibility.
    _examsChannel = Supabase.instance.client
        .channel('exams_realtime')
        .onPostgresChanges(
          event:    PostgresChangeEvent.all,
          schema:   'public',
          table:    'exams',
          callback: (payload) {
            if (!mounted) return;
            // Refresh the exam list for all students instantly
            ref.invalidate(batchExamsProvider);
            ref.invalidate(allExamsProvider);

            // Show toast when an exam goes LIVE.
            // oldRecord may be empty if REPLICA IDENTITY isn't FULL,
            // so we check newRecord.is_published and only skip explicit
            // unpublish events (where new value is false).
            try {
              final newRow = payload.newRecord;
              final nowPublished = newRow['is_published'] == true;
              // oldRecord can be {} if replication identity not set — treat
              // missing old value as "was not published" so we show the toast
              final oldRow = payload.oldRecord;
              final wasPublished = oldRow.isNotEmpty
                  ? oldRow['is_published'] == true
                  : false;
              if (nowPublished && !wasPublished) {
                final title = (newRow['title'] as String?) ?? 'New Exam';
                ToastService.instance.showExamPublished(title);
              }
            } catch (_) {}
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _examsChannel?.unsubscribe();
    _resultsChannel?.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;
    final location = GoRouterState.of(context).matchedLocation;
    final width = MediaQuery.sizeOf(context).width;
    final isMobile  = width < 600;
    final isTablet  = width >= 600 && width < 1000;
    final isDesktop = width >= 1000;
    
    final devInfoAsync = ref.watch(developerInfoProvider);
    final isDevEnabled = devInfoAsync.value?.isEnabled == true;
    final isMaintenance = devInfoAsync.value?.isMaintenance == true;

    // Maintenance mode: block students after login, login screen stays open
    if (isMaintenance) {
      return MaintenanceScreen(
        onAdminTap: () => context.go('/admin'),
        onLogout: () => ref.read(authProvider.notifier).logout(),
      );
    }

    final bottomItems = _allNavItems.take(4).toList();
    if (isDevEnabled) {
      bottomItems.add(const NavItem(label: 'Dev', icon: Icons.code_rounded, selectedIcon: Icons.code_rounded, route: 'dev'));
    } else {
      bottomItems.add(const NavItem(label: 'More', icon: Icons.grid_view_outlined, selectedIcon: Icons.grid_view_rounded, route: ''));
    }

    int allIdx = _allNavItems.indexWhere(
        (i) => i.route.isNotEmpty && location.startsWith(i.route));
    if (allIdx < 0) allIdx = 0;
    final title = _allNavItems[allIdx].label;

    if (isMobile) {
      int bottomIdx = bottomItems.indexWhere(
          (i) => i.route.isNotEmpty && location.startsWith(i.route));
      if (bottomIdx < 0) bottomIdx = 0;

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          // If GoRouter has a page on the stack, pop it (e.g. result screen, detail page)
          if (GoRouter.of(context).canPop()) {
            GoRouter.of(context).pop();
            return;
          }
          // If on a tab other than Home, go to Home
          if (allIdx > 0) {
            context.go(Routes.studentDashboard);
            return;
          }
          // On Home with nothing to pop — show exit dialog
          final exit = await _showExitDialog(context);
          if (exit == true && context.mounted) SystemNavigator.pop();
        },
        child: Scaffold(
          backgroundColor: context.neu.bg,
          appBar: _appBar(title, user, isMobile: true),
          drawer: _drawer(context, ref, user, allIdx),
          body: widget.child,
          bottomNavigationBar: _bottomNav(context, location, bottomItems, devInfoAsync),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.neu.bg,
      body: Row(children: [
        _SideRail(
          items: _allNavItems,
          selected: allIdx,
          extended: isDesktop,
          user: user,
          onSelect: (i) => context.go(_allNavItems[i].route),
          onLogout: () => _confirmLogout(ref, context),
        ),
        VerticalDivider(width: 1, color: context.neu.border),
        Expanded(child: Scaffold(
          backgroundColor: context.neu.bg,
          appBar: _appBar(title, user, isMobile: false),
          body: DefaultTextStyle.merge(
            style: TextStyle(color: context.neu.textPrimary),
            child: widget.child,
          ),
        )),
      ]),
    );
  }

  PreferredSizeWidget _appBar(String title, dynamic user, {required bool isMobile}) =>
      AppBar(
        title: Text(title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        backgroundColor: null, // uses theme AppBarTheme background
        automaticallyImplyLeading: false,
        actions: [
          // Notification bell — always visible for students
          Builder(builder: (ctx) => NotificationBell(
            onTap: () => showNotificationSheet(ctx),
          )),
          const SizedBox(width: 4),
          if (isMobile)
            Builder(builder: (ctx) => NeuIconButton(
              icon: Icons.menu_rounded,
              onPressed: () => Scaffold.of(ctx).openDrawer(),
              size: 40,
            ))
          else ...[
            Consumer(builder: (ctx, ref, _) {
              final devAsync = ref.watch(developerInfoProvider);
              if (devAsync.value?.isEnabled == true) {
                return NeuIconButton(
                  icon: Icons.code_rounded,
                  onPressed: () => showDeveloperModal(context, devAsync.value!),
                  size: 40,
                );
              }
              return const SizedBox.shrink();
            }),
            const SizedBox(width: 12),
            Builder(builder: (ctx) => _avatarBubble(user?.name ?? '', ctx)),
          ],
          const SizedBox(width: 12),
        ],
      );

  Widget _coinBadge(int coins, BuildContext ctx) => Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: ctx.neu.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: ctx.neu.raisedSoft,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Text('🪙', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          Text('$coins',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent)),
        ]),
      );

  Widget _avatarBubble(String name, BuildContext ctx) => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ctx.neu.surface,
          boxShadow: ctx.neu.raisedSoft,
        ),
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'S',
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: AppColors.primary),
          ),
        ),
      );

  Widget _bottomNav(BuildContext context, String location, List<NavItem> bottomItems, AsyncValue<DeveloperInfoModel> devInfoAsync) {
    final neu = context.neu;
    return Container(
      color: neu.bg,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              color: neu.surface,
              borderRadius: BorderRadius.circular(22),
              boxShadow: neu.raisedStrong,
            ),
            child: Row(
              children: bottomItems.map((item) {
                final isSel = item.route.isNotEmpty &&
                    location.startsWith(item.route) && item.route != 'dev';
                final isMore = item.route.isEmpty;
                final isDev = item.route == 'dev';

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      if (isMore) {
                        Scaffold.of(context).openDrawer();
                      } else if (isDev) {
                        if (devInfoAsync.value != null) {
                          showDeveloperModal(context, devInfoAsync.value!);
                        }
                      } else {
                        context.go(item.route);
                      }
                    },
                    child: _NavBarItem(
                      icon: isSel ? item.selectedIcon : item.icon,
                      isSelected: isSel,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _drawer(BuildContext context, WidgetRef ref,
      dynamic user, int selectedIdx) {
    final neu = context.neu;

    // Fix "@ @test": if username already has leading @, don't add another
    final uname = user?.username ?? '';
    final displayUsername = uname.startsWith('@') ? uname : '@$uname';

    return Drawer(
      backgroundColor: neu.bg,
      elevation: 0,
      child: Column(children: [
        // ── Compact header — name, batch, pill row ──
        Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          padding: const EdgeInsets.fromLTRB(16, 46, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user?.name ?? 'Student',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white),
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(user?.batch ?? '',
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.75))),
              const SizedBox(height: 8),
              // PrepCoins + @username + Class in one pill row
              Wrap(spacing: 6, runSpacing: 4, children: [
                if (user != null) ...[
                  _HeaderPill('🪙 ${user.prepcoins}', Colors.amber.shade300),
                  _HeaderPill(displayUsername, Colors.white.withOpacity(0.85)),
                  _HeaderPill('Class ${user.studentClass.toUpperCase()}', Colors.white.withOpacity(0.85)),
                ],
              ]),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            itemCount: _allNavItems.length,
            itemBuilder: (_, i) {
              final item = _allNavItems[i];
              final isSel = i == selectedIdx;
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  context.go(item.route);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 1),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    // No background box — just a left accent bar for selected
                    border: isSel ? Border(
                      left: BorderSide(color: AppColors.primary, width: 3),
                    ) : null,
                  ),
                  child: Row(children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: isSel
                            ? AppColors.primary.withOpacity(0.10)
                            : neu.surface,
                        borderRadius: BorderRadius.circular(9),
                        boxShadow: isSel ? null : neu.raisedSoft,
                      ),
                      child: Center(
                        child: item.route == Routes.studentBioLab
                            ? _BioLabNavIcon(selected: isSel, size: 15)
                            : Icon(
                                isSel ? item.selectedIcon : item.icon,
                                size: 15,
                                color: isSel ? AppColors.primary : neu.textSecondary,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(item.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSel ? FontWeight.w800 : FontWeight.w400,
                          color: isSel ? AppColors.primary : neu.textPrimary,
                        )),
                  ]),
                ),
              );
            },
          ),
        ),

        Divider(height: 1, color: neu.border),
        // Sign out — compact, uses theme-aware colors
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
              _confirmLogout(ref, context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: neu.errorSurface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                const SizedBox(width: 8),
                const Text('Sign Out',
                    style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700, fontSize: 14)),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Future<bool?> _showExitDialog(BuildContext context) => showDialog<bool>(
        context: context,
        builder: (dx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [
            Icon(Icons.exit_to_app_rounded, color: AppColors.primary, size: 22),
            SizedBox(width: 10),
            Text('Exit PRAEPARATIO?'),
          ]),
          content: const Text(
            'Are you sure you want to exit the app?',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dx, false),
              child: const Text('Stay'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () => Navigator.pop(dx, true),
              child: const Text('Exit'),
            ),
          ],
        ),
      );

  void _confirmLogout(WidgetRef ref, BuildContext context) {
    showDialog(
      context: context,
      builder: (dx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(dx);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go(Routes.login);
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

// ── Bottom nav item ────────────────────────────────────────────
class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  const _NavBarItem({required this.icon, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final neu = context.neu;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primarySurface : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Icon(
              icon,
              size: 22,
              color: isSelected ? AppColors.primary : neu.textHint,
            ),
          ),
          // Selected dot indicator at bottom
          if (isSelected)
            Positioned(
              bottom: 5,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Desktop side rail ──────────────────────────────────────────
class _SideRail extends StatelessWidget {
  final List<NavItem> items;
  final int selected;
  final bool extended;
  final dynamic user;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;

  const _SideRail({
    required this.items,
    required this.selected,
    required this.extended,
    required this.user,
    required this.onSelect,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final neu = context.neu;
    final w = extended ? 210.0 : 72.0;
    return Container(
      width: w,
      color: neu.bg,
      child: Column(children: [
        // Logo
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 14),
          child: Column(children: [
            Container(
              width: extended ? 60 : 48,
              height: extended ? 60 : 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: neu.surface,
                boxShadow: neu.raisedSoft,
              ),
              child: Center(
                child: AnimatedLogo(
                    size: extended ? 46 : 36,
                    autoRotate: true,
                    interactive: false),
              ),
            ),
            if (extended) ...[
              const SizedBox(height: 6),
              const Text('PRAEPARATIO',
                  style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      letterSpacing: 2)),
            ],
          ]),
        ),
        Divider(height: 1, color: neu.border),

        // Nav items
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final item = items[i];
              final isSel = i == selected;
              return Tooltip(
                message: extended ? '' : item.label,
                child: GestureDetector(
                  onTap: () => onSelect(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 2),
                    padding: EdgeInsets.symmetric(
                      horizontal: extended ? 12 : 0,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSel
                          ? AppColors.primarySurface
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: isSel ? neu.inset : null,
                    ),
                    child: Row(
                      mainAxisAlignment: extended
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.center,
                      children: [
                        if (extended) const SizedBox(width: 4),
                        item.route == Routes.studentBioLab
                            ? _BioLabNavIcon(selected: isSel, size: 20)
                            : Icon(
                                isSel ? item.selectedIcon : item.icon,
                                size: 20,
                                color: isSel
                                    ? AppColors.primary
                                    : neu.textSecondary,
                              ),
                        if (extended) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(item.label,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSel
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                  color: isSel
                                      ? AppColors.primary
                                      : neu.textSecondary,
                                )),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        Divider(height: 1, color: neu.border),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(children: [
            GestureDetector(
              onTap: onLogout,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.errorSurface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: neu.raisedSoft,
                ),
                child: Row(
                  mainAxisAlignment: extended
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout_rounded,
                        color: AppColors.error, size: 17),
                    if (extended) ...[
                      const SizedBox(width: 8),
                      const Text('Sign Out',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.error)),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
          ]),
        ),
      ]),
    );
  }

  Widget _coinBadge(int coins, BuildContext ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: ctx.neu.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: ctx.neu.raisedSoft,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Text('🪙', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          Text('$coins',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent)),
        ]),
      );
}


// Small inline pill used in drawer header row
Widget _HeaderPill(String label, Color textColor) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.14),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: textColor)),
);

Widget _ProfileChip(String label, IconData icon, Color color) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: color.withOpacity(0.10),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: color.withOpacity(0.25)),
  ),
  child: Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 11, color: color),
    const SizedBox(width: 4),
    Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
  ]),
);

// ── Animated Bio Lab icon — cycles teal↔green when idle, primary when active ──
class _BioLabNavIcon extends StatefulWidget {
  final bool selected;
  final double size;
  const _BioLabNavIcon({required this.selected, this.size = 20});

  @override
  State<_BioLabNavIcon> createState() => _BioLabNavIconState();
}

class _BioLabNavIconState extends State<_BioLabNavIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selected) {
      return Icon(Icons.science_rounded, size: widget.size, color: AppColors.primary);
    }
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final color = Color.lerp(
          const Color(0xFF26A69A), // bio-teal
          const Color(0xFF66BB6A), // bio-green
          _ctrl.value,
        ) ?? const Color(0xFF26A69A);
        return Icon(Icons.science_rounded, size: widget.size, color: color);
      },
    );
  }
}
