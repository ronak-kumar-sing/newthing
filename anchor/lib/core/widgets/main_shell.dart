import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../design/anchor_theme.dart';
import '../responsive/responsive_breakpoints.dart';
import 'desktop_nav_rail.dart';
import 'desktop_window_chrome.dart';

/// Shared navigation items used by both mobile floating nav and desktop rail.
const List<DesktopNavItem> kAnchorNavItems = [
  DesktopNavItem(
    icon: Icons.wb_sunny_outlined,
    label: 'Brief',
    route: '/',
  ),
  DesktopNavItem(
    icon: Icons.chat_bubble_outline,
    label: 'WhatsApp',
    route: '/whatsapp',
  ),
  DesktopNavItem(
    icon: Icons.bar_chart_rounded,
    label: 'Progress',
    route: '/progress',
  ),
  DesktopNavItem(
    icon: Icons.timer_outlined,
    label: 'Clock',
    route: '/clock',
  ),
  DesktopNavItem(
    icon: Icons.checklist_rounded,
    label: 'Tasks',
    route: '/tasks',
  ),
];

/// Anchor MainShell — responsive wrapper for mobile and desktop layouts.
///
/// Mobile keeps the original floating pill bottom nav.
/// Desktop shows a custom dark side rail + custom window chrome.
class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;

    return ResponsiveBuilder(
      mobile: (_) => _MobileShell(currentPath: path, child: child),
      tablet: (_) => _MobileShell(currentPath: path, child: child),
      desktop: (_) => _DesktopShell(currentPath: path, child: child),
    );
  }
}

// ─── Mobile Shell (original design, unchanged) ─────────────────────────────
class _MobileShell extends StatelessWidget {
  final String currentPath;
  final Widget child;

  const _MobileShell({required this.currentPath, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnchorTheme.background,
      extendBody: true,
      body: child,
      bottomNavigationBar: _FloatingNav(currentPath: currentPath),
    );
  }
}

// ─── Desktop Shell ─────────────────────────────────────────────────────────
class _DesktopShell extends StatelessWidget {
  final String currentPath;
  final Widget child;

  const _DesktopShell({required this.currentPath, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnchorTheme.backgroundDeep,
      body: Row(
        children: [
          DesktopNavRail(
            items: kAnchorNavItems,
            currentPath: currentPath,
            onSettingsTap: () => context.go('/settings'),
          ),
          Expanded(
            child: Column(
              children: [
                const DesktopWindowChrome(),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Floating Pill Nav (original design, unchanged) ─────────────────────────
class _FloatingNav extends StatelessWidget {
  final String currentPath;
  const _FloatingNav({required this.currentPath});

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
          children: kAnchorNavItems.map((item) {
            final isActive = currentPath == item.route;
            return _NavTile(item: item, isActive: isActive);
          }).toList(),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final DesktopNavItem item;
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
