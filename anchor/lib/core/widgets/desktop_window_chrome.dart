import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:window_manager/window_manager.dart';
import '../design/anchor_theme.dart';

/// Custom window chrome for desktop platforms.
///
/// [main.dart] already hides the native title bar on macOS/Windows/Linux, so
/// this widget provides minimize/maximize/close controls and a draggable area.
/// It does nothing on web or mobile.
class DesktopWindowChrome extends StatelessWidget {
  final String title;
  final double height;

  const DesktopWindowChrome({
    super.key,
    this.title = 'Anchor',
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    final shouldRender = !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);
    if (!shouldRender) return const SizedBox.shrink();

    final isMacOS = !kIsWeb && Platform.isMacOS;

    return DragToMoveArea(
      child: Container(
        height: height,
        color: AnchorTheme.backgroundDeep,
        child: Row(
          children: [
            if (isMacOS) ...[
              const SizedBox(width: 16),
              _WindowControls(),
              const SizedBox(width: 16),
              Expanded(
                child: _TitleText(title: title, centered: true),
              ),
              const SizedBox(width: 92), // balance traffic light width
            ] else ...[
              const SizedBox(width: 16),
              Expanded(child: _TitleText(title: title, centered: false)),
              _WindowControls(),
              const SizedBox(width: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _TitleText extends StatelessWidget {
  final String title;
  final bool centered;

  const _TitleText({required this.title, required this.centered});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: centered ? TextAlign.center : TextAlign.left,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AnchorTheme.textSecondary,
      ),
    );
  }
}

class _WindowControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ControlButton(
          icon: Icons.remove_rounded,
          hoverColor: AnchorTheme.surfaceBright,
          onTap: () => windowManager.minimize(),
        ),
        const SizedBox(width: 8),
        _ControlButton(
          icon: Icons.crop_square_outlined,
          hoverColor: AnchorTheme.surfaceBright,
          onTap: () async {
            if (await windowManager.isMaximized()) {
              await windowManager.unmaximize();
            } else {
              await windowManager.maximize();
            }
          },
        ),
        const SizedBox(width: 8),
        _ControlButton(
          icon: Icons.close_rounded,
          hoverColor: AnchorTheme.statusRed.withOpacity(0.8),
          iconColor: AnchorTheme.textPrimary,
          onTap: () => windowManager.close(),
        ),
      ],
    );
  }
}

class _ControlButton extends StatefulWidget {
  final IconData icon;
  final Color hoverColor;
  final Color? iconColor;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.hoverColor,
    required this.onTap,
    this.iconColor,
  });

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _hovering ? widget.hoverColor : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            widget.icon,
            size: 14,
            color: widget.iconColor ?? AnchorTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
