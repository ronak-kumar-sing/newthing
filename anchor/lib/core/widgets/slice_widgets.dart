import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../design/anchor_theme.dart';

// ─────────────────────────────────────────────────────────────────
// Anchor Shared Widgets — matches Stitch "Anchor High-Performance"
// Pure tonal dark, #161616 cards, 1px #252525 border, 20px radius
// NO glassmorphism / backdrop blur
// ─────────────────────────────────────────────────────────────────

/// Standard dark card — #161616 bg, 1px #252525 border, 20px radius.
class CleanCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double borderRadius;
  final Color? color;
  final Color? borderColor;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const CleanCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = AnchorTheme.radiusCard,
    this.color,
    this.borderColor,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AnchorTheme.cardPadding),
      decoration: BoxDecoration(
        color: color ?? AnchorTheme.cardBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? AnchorTheme.cardBorder,
          width: 1,
        ),
        gradient: gradient,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: container,
      );
    }
    return container;
  }
}

/// Card with a colored left accent strip (3px wide).
class AccentCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double borderRadius;
  final Color accentColor;

  const AccentCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = AnchorTheme.radiusCard,
    this.accentColor = AnchorTheme.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AnchorTheme.cardBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AnchorTheme.cardBorder, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 3,
              color: accentColor,
            ),
            Expanded(
              child: Padding(
                padding: padding ?? const EdgeInsets.all(AnchorTheme.cardPadding),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lime pill button (primary CTA).
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isOutlined;
  final double? height;

  const PrimaryButton(
    this.text,
    this.onPressed, {
    super.key,
    this.icon,
    this.isOutlined = false,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AnchorTheme.radiusBtn);
    if (isOutlined) {
      return SizedBox(
        height: height,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AnchorTheme.accent,
            side: const BorderSide(color: AnchorTheme.accent, width: 1),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: radius),
            textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          child: icon != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 16),
                    const SizedBox(width: 6),
                    Text(text),
                  ],
                )
              : Text(text),
        ),
      );
    }
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AnchorTheme.accent,
          foregroundColor: AnchorTheme.onAccent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        child: icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16, color: AnchorTheme.onAccent),
                  const SizedBox(width: 6),
                  Text(text),
                ],
              )
            : Text(text),
      ),
    );
  }
}

/// Section header — UPPERCASE 12px/700, 0.05em tracking, muted color + dot.
class SectionHeader extends StatelessWidget {
  final String label;
  final Color? color;
  final bool isMobile;

  const SectionHeader({
    super.key,
    required this.label,
    this.color,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: color ?? AnchorTheme.textMuted,
      ),
    );
  }
}

/// Status pill/badge — 6px radius, colored bg.
class StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const StatusPill({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AnchorTheme.radiusTag),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Pill progress bar — lime fill on dark track.
class AnchorProgressBar extends StatelessWidget {
  final double progress; // 0.0 – 1.0
  final double height;
  final Color? trackColor;
  final Color? fillColor;

  const AnchorProgressBar({
    super.key,
    required this.progress,
    this.height = 6,
    this.trackColor,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        return Stack(
          children: [
            Container(
              width: w,
              height: height,
              decoration: BoxDecoration(
                color: trackColor ?? AnchorTheme.trackBg,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              width: (w * progress.clamp(0.0, 1.0)).toDouble(),
              height: height,
              decoration: BoxDecoration(
                color: fillColor ?? AnchorTheme.trackFill,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Animated counter.
class AnimatedCounter extends StatelessWidget {
  final int value;
  final String? prefix;
  final String? suffix;
  final TextStyle? style;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.prefix,
    this.suffix,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, val, _) {
        return Text(
          '${prefix ?? ''}$val${suffix ?? ''}',
          style: style ??
              GoogleFonts.inter(
                fontSize: 72,
                fontWeight: FontWeight.w900,
                letterSpacing: -2,
                color: AnchorTheme.accent,
              ),
        );
      },
    );
  }
}

/// Fade + slide entrance using flutter_animate
class FadeSlideIn extends StatelessWidget {
  final Widget child;
  final double delaySeconds;

  const FadeSlideIn({super.key, required this.child, this.delaySeconds = 0});

  @override
  Widget build(BuildContext context) {
    return child.animate(delay: (delaySeconds * 1000).ms)
        .fade(duration: 500.ms, curve: Curves.easeOut)
        .slideY(begin: 0.1, duration: 500.ms, curve: Curves.easeOutCubic);
  }
}

/// 1-5 rating row with tappable pill buttons.
class RatingRow extends StatelessWidget {
  final String label;
  final int max;
  final int? selectedValue;
  final ValueChanged<int>? onSelected;
  final bool isMobile;

  const RatingRow({
    super.key,
    required this.label,
    required this.max,
    this.selectedValue,
    this.onSelected,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AnchorTheme.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Row(
            children: List.generate(max, (i) {
              final v = i + 1;
              final active = selectedValue == v;
              return Expanded(
                child: GestureDetector(
                  onTap: onSelected != null ? () => onSelected!(v) : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 6),
                    height: 32,
                    decoration: BoxDecoration(
                      color: active
                          ? AnchorTheme.accent.withOpacity(0.15)
                          : AnchorTheme.cardInset,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: active ? AnchorTheme.accent : AnchorTheme.cardBorder,
                        width: active ? 1.5 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$v',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                          color: active ? AnchorTheme.accent : AnchorTheme.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

/// Stat pill for dashboard overview.
class StatPill extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const StatPill({
    super.key,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AnchorTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AnchorTheme.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$count',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AnchorTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
