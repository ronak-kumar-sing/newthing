import 'package:flutter/material.dart';

/// Anchor design tokens — exactly matching Stitch project 6593935091737035770
/// Theme: "Anchor High-Performance" — Minimalist-Brutalism
/// Total black OLED base, lime accent, Inter typography
class AnchorTheme {
  AnchorTheme._();

  // ─── OLED Backgrounds ───
  static const Color background       = Color(0xFF131313); // true base
  static const Color backgroundDeep   = Color(0xFF0A0A0A); // deepest
  static const Color cardBg           = Color(0xFF161616); // card base
  static const Color cardBgHigh       = Color(0xFF252525); // elevated card
  static const Color cardInset        = Color(0xFF0E0E0E); // inset / inputs
  static const Color cardFloat        = Color(0xFF111111); // floating nav

  // ─── Surfaces (Stitch named-colors) ───
  static const Color surfaceContainer    = Color(0xFF201F1F);
  static const Color surfaceContainerHigh = Color(0xFF2A2A2A);
  static const Color surfaceContainerLow  = Color(0xFF1C1B1B);
  static const Color surfaceBright        = Color(0xFF3A3939);
  static const Color surfaceVariant       = Color(0xFF353534);

  // ─── Card Borders ───
  static const Color cardBorder     = Color(0xFF252525); // every card border
  static const Color outlineVariant = Color(0xFF444934);
  static const Color outline        = Color(0xFF8E937A);

  // ─── Accent (Lime) ───
  static const Color accent           = Color(0xFFC6F52C); // primary lime
  static const Color accentDim        = Color(0xFFAAD600); // primary-fixed-dim
  static const Color accentContainer  = Color(0xFFC4F32A); // primary-container
  static const Color onAccent         = Color(0xFF283500); // text on lime

  // ─── Typography ───
  static const Color textPrimary   = Color(0xFFE5E2E1); // on-surface
  static const Color textSecondary = Color(0xFFC4C9AE); // on-surface-variant
  static const Color textMuted     = Color(0xFF8E937A); // outline

  // ─── Status ───
  static const Color statusGreen  = Color(0xFF69F0AE);
  static const Color statusRed    = Color(0xFFFF5252);
  static const Color statusOrange = Color(0xFFFF9800);
  static const Color statusBlue   = Color(0xFF42A5F5);
  static const Color statusError  = Color(0xFFFFB4AB);

  // ─── Progress/Chart ───
  static const Color trackBg   = Color(0xFF2A2A2A);
  static const Color trackFill = Color(0xFFC6F52C);
  static const Color chartBar  = Color(0xFF2A2A2A);
  static const Color chartActive = Color(0xFFC6F52C);

  // ─── Legacy compat (used by older screens) ───
  @Deprecated('Use background')
  static const Color bg = background;
  static const Color primary = accent;
  static const Color rimTop    = cardBorder;
  static const Color rimSide   = cardBorder;
  static const Color rimBottom = cardBorder;
  static const Color cardSurface = cardBg;
  static const Color cardHero    = cardBgHigh;
  static const double glassBlur  = 0; // no blur in Stitch design

  // ─── Spacing (Stitch spacing tokens) ───
  static const double containerPadding = 20;
  static const double stackGap        = 16;
  static const double sectionGap      = 32;
  static const double cardPadding     = 24;
  static const double navBottomOffset = 16;
  static const double navHorizMargin  = 20;

  // ─── Radii ───
  static const double radiusCard   = 20;   // containers/cards
  static const double radiusNav    = 24;   // floating nav pill
  static const double radiusBtn    = 999;  // pill buttons
  static const double radiusTag    = 6;    // status pills
  static const double radiusInput  = 12;   // input fields
}
