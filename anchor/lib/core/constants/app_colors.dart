import 'package:flutter/material.dart';
import '../design/anchor_theme.dart';

/// AppColors — delegates entirely to AnchorTheme.
/// Keeps backward-compatible references so existing screens compile.
class AppColors {
  AppColors._();

  // Core
  static const Color bg           = AnchorTheme.background;
  static const Color background   = AnchorTheme.background;
  static const Color surface      = AnchorTheme.cardBg;
  static const Color card         = AnchorTheme.cardBg;
  static const Color cardHigh     = AnchorTheme.cardBgHigh;

  // Accent
  static const Color primary      = AnchorTheme.accent;
  static const Color primaryDim   = AnchorTheme.accentDim;
  static const Color accent       = AnchorTheme.accent;

  // Text
  static const Color textPrimary   = AnchorTheme.textPrimary;
  static const Color textSecondary = AnchorTheme.textSecondary;
  static const Color textMuted     = AnchorTheme.textMuted;
  static const Color textDisabled  = AnchorTheme.outline;

  // Border
  static const Color border        = AnchorTheme.cardBorder;

  // Status
  static const Color error    = AnchorTheme.statusRed;
  static const Color alert    = AnchorTheme.statusRed;
  static const Color warning  = AnchorTheme.statusOrange;
  static const Color info     = AnchorTheme.statusBlue;
  static const Color success  = AnchorTheme.statusGreen;

  // Extra surface
  static const Color surfaceRaised = AnchorTheme.cardBgHigh;

  // Track
  static const Color trackBg   = AnchorTheme.trackBg;
  static const Color trackFill = AnchorTheme.trackFill;
}
