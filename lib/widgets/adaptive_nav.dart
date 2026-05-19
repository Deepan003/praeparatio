import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';

class NavItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;

  const NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.route,
  });
}

/// Adaptive scaffold:
/// • Desktop/Tablet: side rail (collapsed icon-only on tablet, expanded with labels on desktop)
/// • Mobile: AppBar + Drawer — no bottom nav (7 items is too many for a bottom bar)
class AdaptiveNavigationScaffold extends StatelessWidget {
  final Widget body;
  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final String title;
  final List<Widget>? actions;
  final Widget? headerContent;
  final Widget? footerContent;
  final FloatingActionButton? fab;

  const AdaptiveNavigationScaffold({
    super.key,
    required this.body,
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.title,
    this.actions,
    this.headerContent,
    this.footerContent,
    this.fab,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= AppConstants.desktopBreakpoint;
    final isTablet =
        width >= AppConstants.tabletBreakpoint && !isDesktop;

    // ── Desktop / Tablet — side rail ────────────────────────
    if (isDesktop || isTablet) {
      return Scaffold(
        body: Row(children: [
          _SideRail(
            items: items,
            selectedIndex: selectedIndex,
            onSelected: onDestinationSelected,
            extended: isDesktop,
            headerContent: headerContent,
            footerContent: footerContent,
          ),
          const VerticalDivider(
              width: 1, thickness: 1, color: AppColors.border),
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                title: Text(title),
                actions: actions,
                automaticallyImplyLeading: false,
              ),
              body: body,
              floatingActionButton: fab,
            ),
          ),
        ]),
      );
    }

    // ── Mobile — Drawer-based navigation ────────────────────
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
              TextButton(
                  onPressed: () => Navigator.pop(dx, false),
                  child: const Text('Stay')),
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
          title: Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800)),
          backgroundColor: AppColors.neuSurface,
          // Hamburger auto-shown via drawer
          actions: [
            if (actions != null) ...actions!,
          ],
        ),
        drawer: _AdminDrawer(
          items: items,
          selectedIndex: selectedIndex,
          onSelected: (i) {
            Navigator.pop(context); // close drawer
            onDestinationSelected(i);
          },
          headerContent: headerContent,
          footerContent: footerContent,
        ),
        body: body,
        floatingActionButton: fab,
      ),
    );
  }
}

// ── Mobile drawer ─────────────────────────────────────────────
class _AdminDrawer extends StatelessWidget {
  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Widget? headerContent;
  final Widget? footerContent;

  const _AdminDrawer({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.headerContent,
    this.footerContent,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.neuBackground,
      width: 280,
      child: SafeArea(
        child: Column(children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('P',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 20)),
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PRAEPARATIO',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 1)),
                  Text('Admin Panel',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ]),
          ),

          // Nav items
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
                        color: isSel
                            ? AppColors.primary.withOpacity(0.12)
                            : AppColors.neuSurface,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isSel ? null : AppColors.neuRaisedSoft,
                      ),
                      child: Icon(
                        isSel ? item.selectedIcon : item.icon,
                        size: 18,
                        color: isSel
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                    title: Text(item.label,
                        style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                            color: isSel
                                ? AppColors.primary
                                : AppColors.textPrimary)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    onTap: () => onSelected(i),
                  ),
                );
              },
            ),
          ),

          // Footer
          if (footerContent != null) ...[
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(12),
              child: footerContent!,
            ),
          ],
        ]),
      ),
    );
  }
}

// ── Desktop/Tablet side rail ──────────────────────────────────
class _SideRail extends StatelessWidget {
  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool extended;
  final Widget? headerContent;
  final Widget? footerContent;

  const _SideRail({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.extended,
    this.headerContent,
    this.footerContent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: extended ? 220 : 72,
      color: AppColors.neuSurface,
      child: Column(children: [
        const SizedBox(height: 16),
        if (headerContent != null) ...[
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: headerContent!),
          const SizedBox(height: 8),
        ],
        Expanded(
          child: NavigationRail(
            extended: extended,
            selectedIndex: selectedIndex,
            onDestinationSelected: onSelected,
            minWidth: 72,
            minExtendedWidth: 220,
            destinations: items.map((item) => NavigationRailDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: Text(item.label),
                )).toList(),
          ),
        ),
        if (footerContent != null) ...[
          const Divider(height: 1, color: AppColors.border),
          Padding(
              padding: const EdgeInsets.all(12), child: footerContent!),
          const SizedBox(height: 8),
        ],
      ]),
    );
  }
}
