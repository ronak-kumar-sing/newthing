import 'package:flutter/material.dart';

enum WallpaperType { lockScreen, homeScreen }
enum TextAlignment { top, bottom, center }

class StreakWallpaperConfig {
  final WallpaperType type;
  final double gridScale;
  final Offset gridOffset;
  final bool showText;
  final TextAlignment textAlignment;
  final double overlayOpacity;
  final Color? accentColor;

  const StreakWallpaperConfig({
    required this.type,
    this.gridScale = 1.0,
    this.gridOffset = Offset.zero,
    this.showText = true,
    this.textAlignment = TextAlignment.bottom,
    this.overlayOpacity = 0.5,
    this.accentColor,
  });
}
