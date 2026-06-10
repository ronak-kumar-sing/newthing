import 'package:flutter/material.dart';

/// ANCHOR — Clean Professional Light Theme Color System.
/// White-first, minimal, professional. No glassmorphism. No neon.
class AppColors {
  AppColors._();

  // ─── Primary Brand ───
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color primaryDark = Color(0xFF6D28D9);
  static const Color primaryBg = Color(0xFFF5F3FF);

  // ─── Backgrounds ───
  static const Color bg = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF9FAFB);
  static const Color surfaceRaised = Color(0xFFF3F4F6);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // ─── Text ───
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textDisabled = Color(0xFFD1D5DB);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─── Semantic ───
  static const Color success = Color(0xFF10B981);
  static const Color successBg = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color error = Color(0xFFEF4444);
  static const Color errorBg = Color(0xFFFEF2F2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoBg = Color(0xFFEFF6FF);

  // ─── Chart / Progress ───
  static const Color trackBg = Color(0xFFE5E7EB);
  static const Color trackFill = Color(0xFF7C3AED);

  // ─── Shadows ───
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);

  // ─── Backward Compatibility ───
  static const Color background = bg;
  static const Color surfaceLight = surfaceRaised;
  static const Color productive = success;
  static const Color productiveDim = Color(0xFF059669);
  static const Color neutral = warning;
  static const Color distracted = error;
  static const Color distractedDim = Color(0xFFDC2626);
  static const Color countdown = info;
  static const Color countdownAccent = Color(0xFF2563EB);
  static const Color signal = success;
  static const Color signalDim = Color(0xFF059669);
  static const Color amber = warning;
  static const Color alert = error;
  static const Color alertDim = Color(0xFFDC2626);
  static const Color ice = info;
  static const Color iceDim = Color(0xFF2563EB);
  static const Color violet = primary;
  static const Color violetDim = primaryDark;
  static const Color progressTrack = trackBg;
  static const Color progressFill = trackFill;
  static const Color moodLow = error;
  static const Color moodMedium = warning;
  static const Color moodHigh = success;

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
        return info;
      default:
        return textSecondary;
    }
  }
}
