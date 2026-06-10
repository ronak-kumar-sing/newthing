import 'dart:ui';
import 'package:flutter/material.dart';
import '../design/anchor_theme.dart';

enum GlassVariant {
  surface,
  hero,
  inset,
  floating,
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final GlassVariant variant;
  final EdgeInsets? padding;
  final double borderRadius;
  final bool hasAccent;
  final double? width;
  final double? height;

  const GlassCard({
    super.key,
    required this.child,
    this.variant = GlassVariant.surface,
    this.padding,
    this.borderRadius = 16.0,
    this.hasAccent = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    Color surfaceColor;
    switch (variant) {
      case GlassVariant.surface:
        surfaceColor = AnchorTheme.cardSurface;
        break;
      case GlassVariant.hero:
        surfaceColor = AnchorTheme.cardHero;
        break;
      case GlassVariant.inset:
        surfaceColor = AnchorTheme.cardInset;
        break;
      case GlassVariant.floating:
        surfaceColor = AnchorTheme.cardFloat;
        break;
    }

    Widget content = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border(
          top: BorderSide(color: AnchorTheme.rimTop, width: 1),
          left: BorderSide(color: AnchorTheme.rimSide, width: 1),
          right: BorderSide(color: AnchorTheme.rimSide, width: 1),
          bottom: BorderSide(color: AnchorTheme.rimBottom, width: 1),
        ),
      ),
      child: hasAccent
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 3,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AnchorTheme.accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: child),
              ],
            )
          : child,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AnchorTheme.glassBlur,
          sigmaY: AnchorTheme.glassBlur,
        ),
        child: content,
      ),
    );
  }
}
