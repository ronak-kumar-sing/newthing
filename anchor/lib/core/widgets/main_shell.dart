import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../router/app_router.dart';

/// Clean white navigation shell.
/// Desktop: white sidebar. Mobile: standard white bottom nav.
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.path;
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: isMobile
          ? child
          : Row(
              children: [
                _Sidebar(currentRoute: currentRoute),
                Expanded(
                  child: Container(
                    color: AppColors.bg,
                    child: child,
                  ),
                ),
              ],
            ),
      bottomNavigationBar: isMobile ? _BottomNav(currentRoute: currentRoute) : null,
    );
  }
}

// ─── Desktop Sidebar ───
class _Sidebar extends StatelessWidget {
  final String currentRoute;

  const _Sidebar({required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(
          right: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          // Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'ANCHOR',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 6, bottom: 24),
            child: Text(
              'Your Life. Owned.',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 12),
          _NavItem(index: '01', label: 'Brief', route: Routes.morningBrief, isActive: currentRoute == Routes.morningBrief),
          _NavItem(index: '02', label: 'Clock', route: Routes.independenceClock, isActive: currentRoute == Routes.independenceClock),
          _NavItem(index: '03', label: 'Mirror', route: Routes.screenMirror, isActive: currentRoute == Routes.screenMirror),
          _NavItem(index: '04', label: 'Tasks', route: Routes.taskCenter, isActive: currentRoute == Routes.taskCenter),
          _NavItem(index: '05', label: 'Progress', route: Routes.lifeProgress, isActive: currentRoute == Routes.lifeProgress),
          _NavItem(index: '06', label: 'Coach', route: Routes.aiCoach, isActive: currentRoute == Routes.aiCoach),
          _NavItem(index: '07', label: 'Digest', route: Routes.whatsappDigest, isActive: currentRoute == Routes.whatsappDigest),
          _NavItem(index: '08', label: 'Focus', route: Routes.focusMode, isActive: currentRoute == Routes.focusMode),
          _NavItem(index: '09', label: 'Placement', route: Routes.placementTracker, isActive: currentRoute == Routes.placementTracker),
          const Spacer(),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 8),
          _NavItem(index: '00', label: 'Settings', route: Routes.settings, isActive: currentRoute == Routes.settings),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─── Mobile Bottom Nav ───
class _BottomNav extends StatelessWidget {
  final String currentRoute;

  const _BottomNav({required this.currentRoute});

  static const _items = [
    (icon: Icons.wb_sunny_outlined, label: 'Brief', route: Routes.morningBrief),
    (icon: Icons.timer_outlined, label: 'Clock', route: Routes.independenceClock),
    (icon: Icons.check_circle_outline, label: 'Tasks', route: Routes.taskCenter),
    (icon: Icons.trending_up_outlined, label: 'Progress', route: Routes.lifeProgress),
    (icon: Icons.chat_bubble_outline, label: 'Coach', route: Routes.aiCoach),
    (icon: Icons.more_horiz, label: 'More', route: null),
  ];

  @override
  Widget build(BuildContext context) {
    final idx = _items.indexWhere((i) => i.route == currentRoute);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: idx >= 0 ? idx : 0,
          onTap: (index) {
            final item = _items[index];
            if (item.route != null) {
              context.go(item.route!);
            } else {
              _showMoreMenu(context);
            }
          },
          backgroundColor: AppColors.bg,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w400,
          ),
          items: _items.map((item) {
            return BottomNavigationBarItem(
              icon: Icon(item.icon, size: 22),
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textDisabled,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              _MoreItem(icon: Icons.monitor_outlined, label: 'Screen Mirror', route: Routes.screenMirror),
              _MoreItem(icon: Icons.message_outlined, label: 'WhatsApp Digest', route: Routes.whatsappDigest),
              _MoreItem(icon: Icons.center_focus_strong_outlined, label: 'Focus Mode', route: Routes.focusMode),
              _MoreItem(icon: Icons.work_outline, label: 'Placement', route: Routes.placementTracker),
              const Divider(color: AppColors.divider),
              _MoreItem(icon: Icons.settings_outlined, label: 'Settings', route: Routes.settings),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;

  const _MoreItem({required this.icon, required this.label, required this.route});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20, color: AppColors.textSecondary),
      title: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
      dense: true,
    );
  }
}

// ─── Nav Item ───
class _NavItem extends StatelessWidget {
  final String index;
  final String label;
  final String route;
  final bool isActive;

  const _NavItem({
    required this.index,
    required this.label,
    required this.route,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => context.go(route),
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primaryBg : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                if (isActive)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const SizedBox(width: 6),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
