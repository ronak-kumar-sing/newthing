import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../design/anchor_theme.dart';

/// A desktop side navigation rail custom-styled for Anchor's dark OLED look.
///
/// Uses the same iconography and active-state philosophy as the mobile floating
/// nav, but laid out vertically with labels for pointer/tap targets.
class DesktopNavRail extends StatelessWidget {
  final List<DesktopNavItem> items;
  final String currentPath;
  final VoidCallback? onSettingsTap;
  final double width;

  const DesktopNavRail({
    super.key,
    required this.items,
    required this.currentPath,
    this.onSettingsTap,
    this.width = 220,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AnchorTheme.backgroundDeep,
        border: Border(
          right: BorderSide(color: AnchorTheme.cardBorder, width: 1),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Wordmark
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AnchorTheme.accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.anchor_rounded,
                      color: AnchorTheme.onAccent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'ANCHOR',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AnchorTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Nav items
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: items
                      .map(
                        (item) => _NavRailTile(
                          item: item,
                          isActive: currentPath == item.route,
                          onTap: () => context.go(item.route),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            // Settings
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: _NavRailTile(
                item: const DesktopNavItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  route: '/settings',
                ),
                isActive: currentPath == '/settings',
                onTap: onSettingsTap ?? () => context.go('/settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Data class for a single desktop navigation item.
class DesktopNavItem {
  final IconData icon;
  final String label;
  final String route;

  const DesktopNavItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

class _NavRailTile extends StatefulWidget {
  final DesktopNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavRailTile({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavRailTile> createState() => _NavRailTileState();
}

class _NavRailTileState extends State<_NavRailTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isActive
        ? AnchorTheme.accent.withOpacity(0.1)
        : _hovering
            ? AnchorTheme.cardBg.withOpacity(0.6)
            : Colors.transparent;
    final iconColor = widget.isActive
        ? AnchorTheme.accent
        : _hovering
            ? AnchorTheme.textPrimary
            : AnchorTheme.textMuted;
    final textColor = widget.isActive
        ? AnchorTheme.accent
        : _hovering
            ? AnchorTheme.textPrimary
            : AnchorTheme.textMuted;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: 150.ms,
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(widget.item.icon, size: 22, color: iconColor),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.item.label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight:
                        widget.isActive ? FontWeight.w600 : FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              if (widget.isActive)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AnchorTheme.accent,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
