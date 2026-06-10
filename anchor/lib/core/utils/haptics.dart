import 'package:flutter/services.dart';

/// Haptic feedback utilities for consistent mobile UX.
class Haptics {
  Haptics._();

  static void light() => HapticFeedback.lightImpact();
  static void medium() => HapticFeedback.mediumImpact();
  static void heavy() => HapticFeedback.heavyImpact();
  static void selection() => HapticFeedback.selectionClick();
  static void vibrate() => HapticFeedback.vibrate();
}
