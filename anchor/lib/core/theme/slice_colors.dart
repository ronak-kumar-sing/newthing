import 'package:flutter/material.dart';

/// Slice-Inspired Color Palette — Dark-first glossy aesthetic.
/// Primary: Magenta + Purple gradients. Accent: Lime + Cyan.
class SliceColors {
  SliceColors._();

  // ─── Primary Brand ───
  static const Color primaryMagenta = Color(0xFFCC00CC);
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color primaryLime = Color(0xFFCCFF00);
  static const Color primaryCyan = Color(0xFF00D4FF);

  // ─── Dark Backgrounds (primary theme) ───
  static const Color bgDark = Color(0xFF0A0A0F);
  static const Color bgDarkElevated = Color(0xFF12121A);
  static const Color bgDarkSurface = Color(0xFF1A1A26);
  static const Color bgDarkCard = Color(0xFF222233);

  // ─── Light Backgrounds (secondary) ───
  static const Color bgLight = Color(0xFFF8F9FA);
  static const Color bgLightSurface = Color(0xFFFFFFFF);

  // ─── Glossy Surface Fills ───
  static const Color glassDark = Color(0x18FFFFFF);
  static const Color glassDarkBorder = Color(0x20FFFFFF);
  static const Color glassLight = Color(0x40FFFFFF);
  static const Color glassBorder = Color(0x30FFFFFF);
  static const Color glassHighlight = Color(0x60FFFFFF);

  // ─── Text ───
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0A0B8);
  static const Color textMuted = Color(0xFF6B6B80);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textOnLight = Color(0xFF1A1A2E);

  // ─── Semantic ───
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // ─── Glossy Effects ───
  static const Color sheenTop = Color(0x50FFFFFF);
  static const Color sheenBottom = Color(0x08FFFFFF);
  static const Color reflection = Color(0x15FFFFFF);
  static const Color edgeGlow = Color(0x40CC00CC);

  // ─── Gradient Presets ───
  static const Gradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFFCC00CC), Color(0xFF0A0A0F)],
  );

  static const Gradient creditGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4C1D95), Color(0xFF7C3AED), Color(0xFF0A0A0F)],
  );

  static const Gradient glowGradient = RadialGradient(
    center: Alignment.topCenter,
    radius: 0.8,
    colors: [Color(0x307C3AED), Color(0x000A0A0F)],
  );

  static const Gradient buttonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFCC00CC),
      Color(0xFF7C3AED),
      Color(0xFF7C3AED),
    ],
  );

  // ─── Backward compatibility aliases (maps old AppColors names) ───
  static const Color bg = bgDark;
  static const Color surface = bgDarkElevated;
  static const Color surfaceRaised = bgDarkSurface;
  static const Color card = bgDarkCard;
  static const Color border = glassDarkBorder;
  static const Color divider = Color(0xFF1A1A2E);
  static const Color primary = primaryMagenta;
  static const Color primaryLight = primaryCyan;
  static const Color primaryDark = primaryPurple;
  static const Color productive = success;
  static const Color productiveDim = Color(0xFF16A34A);
  static const Color neutral = warning;
  static const Color distracted = error;
  static const Color distractedDim = Color(0xFFDC2626);
  static const Color countdown = primaryCyan;
  static const Color countdownAccent = Color(0xFF0891B2);
  static const Color signal = success;
  static const Color signalDim = Color(0xFF16A34A);
  static const Color amber = warning;
  static const Color alert = error;
  static const Color alertDim = Color(0xFFDC2626);
  static const Color ice = primaryCyan;
  static const Color iceDim = Color(0xFF0891B2);
  static const Color violet = Color(0xFFA78BFA);
  static const Color violetDim = Color(0xFF8B5CF6);
  static const Color trackBg = Color(0xFF1A1A2E);
  static const Color trackFill = success;
  static const Color textDisabled = Color(0xFF475569);

  static Color forStatus(String status) {
    switch (status) {
      case 'good':
      case 'productive':
        return success;
      case 'fair':
      case 'warning':
        return warning;
      case 'bad':
      case 'danger':
        return error;
      case 'info':
      case 'neutral':
        return primaryCyan;
      default:
        return textSecondary;
    }
  }
}
