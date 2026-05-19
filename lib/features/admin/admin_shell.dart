import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/adaptive_nav.dart';

// Full nav list — shown on desktop/tablet side rail and in mobile drawer
final _adminNavItems = [
  const NavItem(label: 'Dashboard',     icon: Icons.calendar_today_outlined,  selectedIcon: Icons.calendar_today,    route: Routes.adminDashboard),
  const NavItem(label: 'Students',      icon: Icons.bar_chart_outlined,        selectedIcon: Icons.bar_chart,         route: Routes.adminStudentActivity),
  const NavItem(label: 'Exam Engine',   icon: Icons.quiz_outlined,             selectedIcon: Icons.quiz,              route: Routes.adminExamEngine),
  const NavItem(label: 'Notes',         icon: Icons.folder_outlined,           selectedIcon: Icons.folder,            route: Routes.adminNotesLinks),
  const NavItem(label: 'Notify',        icon: Icons.campaign_outlined,         selectedIcon: Icons.campaign_rounded,  route: Routes.adminNotifications),
  const NavItem(label: 'Database',      icon: Icons.people_outline,            selectedIcon: Icons.people,            route: Routes.adminDatabase),
  const NavItem(label: 'PYQ Upload',    icon: Icons.upload_file_outlined,      selectedIcon: Icons.upload_file,       route: Routes.adminPyqUpload),
  const NavItem(label: 'Credits',       icon: Icons.token_outlined,            selectedIcon: Icons.token,             route: Routes.adminCredits),
  const NavItem(label: 'Batches',       icon: Icons.groups_outlined,           selectedIcon: Icons.groups,            route: Routes.adminBatches),
  const NavItem(label: 'AI Config',     icon: Icons.api_outlined,              selectedIcon: Icons.api,               route: Routes.adminAiSettings),
  const NavItem(label: 'Developer',     icon: Icons.code_outlined,             selectedIcon: Icons.code,              route: Routes.adminDeveloper),
];

// Mobile bottom nav: first 4 items + More
final _adminBottomItems = _adminNavItems.take(4).toList()
  ..add(const NavItem(label: 'More', icon: Icons.grid_view_outlined,
      selectedIcon: Icons.grid_view_rounded, route: ''));

class AdminShell extends ConsumerWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    int selected = _adminNavItems.indexWhere((i) => location.startsWith(i.route));
    if (selected < 0) selected = 0;

    final user = ref.watch(authProvider).value;
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 600;

    final onLogout = () async {
      await ref.read(authProvider.notifier).logout();
      if (context.mounted) context.go(Routes.login);
    };

    // ── Mobile: AppBar + Drawer + bottom nav ─────────────────
    if (isMobile) {
      // Find which bottom item is selected
      int bottomIdx = _adminBottomItems.indexWhere(
          (i) => i.route.isNotEmpty && location.startsWith(i.route));
      if (bottomIdx < 0) bottomIdx = 0;

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          final exit = await showDialog<bool>(
            context: context,
            builder: (dx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(children: [
                Icon(Icons.exit_to_app_rounded, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text('Exit PRAEPARATIO?'),
              ]),
              content: const Text('Are you sure you want to exit?',
                  style: TextStyle(color: AppColors.textSecondary)),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dx, false), child: const Text('Stay')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                  onPressed: () => Navigator.pop(dx, true),
                  child: const Text('Exit'),
                ),
              ],
            ),
          );
          if (exit == true) SystemNavigator.pop();
        },
        child: Scaffold(
          backgroundColor: AppColors.neuBackground,
          appBar: AppBar(
            title: Text(_adminNavItems[selected].label,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            backgroundColor: AppColors.neuBackground,
            automaticallyImplyLeading: false,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.admin_panel_settings, size: 16, color: AppColors.primary),
                ]),
              ),
              Builder(builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              )),
            ],
          ),
          drawer: _AdminDrawerWidget(
            items: _adminNavItems,
            selectedIndex: selected,
            user: user,
            onSelected: (i) => context.go(_adminNavItems[i].route),
            onLogout: onLogout,
          ),
          body: child,
          bottomNavigationBar: _adminBottomNav(context, location),
        ),
      );
    }

    // ── Tablet/Desktop: side rail ─────────────────────────────
    return AdaptiveNavigationScaffold(
      body: child,
      items: _adminNavItems,
      selectedIndex: selected,
      title: _adminNavItems[selected].label,
      onDestinationSelected: (i) => context.go(_adminNavItems[i].route),
      headerContent: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(child: Text('P',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22))),
          ),
          const SizedBox(height: 4),
          const Text('ADMIN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800,
              color: AppColors.primary, letterSpacing: 2)),
        ],
      ),
      footerContent: _LogoutButton(onLogout: onLogout),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.admin_panel_settings, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(user?.name ?? 'Admin',
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                      color: AppColors.primary)),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _adminBottomNav(BuildContext context, String location) {
    return Container(
      color: AppColors.neuBackground,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.neuSurface,
              borderRadius: BorderRadius.circular(22),
              boxShadow: AppColors.neuRaisedStrong,
            ),
            child: Row(
              children: _adminBottomItems.map((item) {
                final isSel = item.route.isNotEmpty && location.startsWith(item.route);
                final isMore = item.route.isEmpty;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      if (isMore) {
                        // Bottom sheet with remaining nav items
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (_) => _AdminMoreSheet(
                            items: _adminNavItems.skip(4).toList(),
                            currentLocation: location,
                            onSelect: (route) {
                              Navigator.pop(context);
                              context.go(route);
                            },
                          ),
                        );
                      } else {
                        context.go(item.route);
                      }
                    },
                    child: _AdminNavBarItem(
                      icon: isSel ? item.selectedIcon : item.icon,
                      label: item.label,
                      isSelected: isSel,
                      isMore: isMore,
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
}

class _AdminNavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isMore;
  const _AdminNavBarItem({required this.icon, required this.label,
      required this.isSelected, this.isMore = false});

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.textHint;
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
      const SizedBox(height: 2),
      Text(label,
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: color),
          maxLines: 1, overflow: TextOverflow.ellipsis),
    ]);
  }
}

// ── Bottom sheet shown when admin taps "More" on mobile ───────────────────────
class _AdminMoreSheet extends StatelessWidget {
  final List<NavItem> items;
  final String currentLocation;
  final ValueChanged<String> onSelect;
  const _AdminMoreSheet({required this.items, required this.currentLocation, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.neuBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.neuRaisedStrong,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Icon(Icons.grid_view_rounded, size: 16, color: AppColors.textSecondary),
              SizedBox(width: 8),
              Text('More Options', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
            ]),
          ),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            childAspectRatio: 1.4,
            children: items.map((item) {
              final isSel = item.route.isNotEmpty && currentLocation.startsWith(item.route);
              return GestureDetector(
                onTap: () { HapticFeedback.lightImpact(); onSelect(item.route); },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSel ? AppColors.primarySurface : AppColors.neuSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSel ? AppColors.primary.withOpacity(0.3) : AppColors.border,
                    ),
                    boxShadow: AppColors.neuRaisedSoft,
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(isSel ? item.selectedIcon : item.icon, size: 22,
                        color: isSel ? AppColors.primary : AppColors.textSecondary),
                    const SizedBox(height: 5),
                    Text(item.label,
                        style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w700,
                            color: isSel ? AppColors.primary : AppColors.textSecondary),
                        textAlign: TextAlign.center,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ]),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _AdminDrawerWidget extends StatelessWidget {
  final List<NavItem> items;
  final int selectedIndex;
  final dynamic user;
  final ValueChanged<int> onSelected;
  final VoidCallback onLogout;
  const _AdminDrawerWidget({required this.items, required this.selectedIndex,
      required this.user, required this.onSelected, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.neuBackground,
      width: 280,
      child: SafeArea(
        child: Column(children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
            child: Row(children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Text('P',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20))),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('PRAEPARATIO',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
                Text(user?.name ?? 'Admin',
                    style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
              ]),
            ]),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final item = items[i];
                final isSel = i == selectedIndex;
                return Container(
                  margin: const EdgeInsets.only(bottom: 2),
                  decoration: BoxDecoration(
                    color: isSel ? AppColors.primarySurface : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    dense: true,
                    leading: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: isSel ? AppColors.primary.withOpacity(0.12) : AppColors.neuSurface,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isSel ? null : AppColors.neuRaisedSoft,
                      ),
                      child: Icon(isSel ? item.selectedIcon : item.icon,
                          size: 18, color: isSel ? AppColors.primary : AppColors.textSecondary),
                    ),
                    title: Text(item.label,
                        style: TextStyle(fontSize: 13.5,
                            fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                            color: isSel ? AppColors.primary : AppColors.textPrimary)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onTap: () { Navigator.pop(context); onSelected(i); },
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.all(12),
            child: _LogoutButton(onLogout: onLogout),
          ),
        ]),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;
  const _LogoutButton({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (dx) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dx), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                onPressed: () { Navigator.pop(dx); onLogout(); },
                child: const Text('Logout'),
              ),
            ],
          ),
        );
      },
      icon: const Icon(Icons.logout, size: 18, color: AppColors.textSecondary),
      label: const Text('Logout', style: TextStyle(color: AppColors.textSecondary)),
    );
  }
}
