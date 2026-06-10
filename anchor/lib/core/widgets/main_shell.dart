import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../design/anchor_theme.dart';
import '../router/app_router.dart';

/// Anchor MainShell — matches Stitch design exactly.
/// Floating pill bottom nav with lime active dot indicator.
class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    return Scaffold(
      backgroundColor: AnchorTheme.background,
      extendBody: true,
      body: child,
      bottomNavigationBar: _FloatingNav(currentPath: path),
    );
  }
}

// ─── Floating Pill Nav ────────────────────────────────────────────────────
class _FloatingNav extends StatelessWidget {
  final String currentPath;
  const _FloatingNav({required this.currentPath});

  static const _items = [
    _NavItem(icon: Icons.wb_sunny_outlined,         label: 'Brief',    route: Routes.morningBrief),
    _NavItem(icon: Icons.hourglass_empty_outlined,  label: 'Clock',    route: Routes.independenceClock),
    _NavItem(icon: Icons.monitor_outlined,          label: 'Mirror',   route: Routes.screenMirror),
    _NavItem(icon: Icons.check_circle_outline,      label: 'Tasks',    route: Routes.taskCenter),
    _NavItem(icon: Icons.show_chart,                label: 'Progress', route: Routes.lifeProgress),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AnchorTheme.navHorizMargin,
        0,
        AnchorTheme.navHorizMargin,
        AnchorTheme.navBottomOffset + MediaQuery.of(context).padding.bottom,
      ),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: AnchorTheme.cardFloat,
          borderRadius: BorderRadius.circular(AnchorTheme.radiusNav),
          border: Border.all(color: AnchorTheme.cardBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _items.map((item) {
            final isActive = currentPath == item.route;
            return _NavTile(item: item, isActive: isActive);
          }).toList(),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  const _NavItem({required this.icon, required this.label, required this.route});
}

class _NavTile extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  const _NavTile({required this.item, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(item.route),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        height: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: 22,
              color: isActive ? AnchorTheme.accent : AnchorTheme.textMuted,
            ).animate(
              target: isActive ? 1.0 : 0.0,
            ).scale(
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.15, 1.15),
              duration: 100.ms,
              curve: Curves.easeOut,
            ).then().scale(
              begin: const Offset(1.15, 1.15),
              end: const Offset(1.0, 1.0),
              duration: 100.ms,
              curve: Curves.easeIn,
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AnchorTheme.accent : AnchorTheme.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            // Active dot — 4px lime, 4px below label
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 4 : 0,
              height: isActive ? 4 : 0,
              decoration: const BoxDecoration(
                color: AnchorTheme.accent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
