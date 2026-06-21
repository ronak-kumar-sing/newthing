import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design/anchor_theme.dart';
import '../../../core/platform/native_bridge.dart';
import '../../../providers/journey_config_provider.dart';
import '../models/streak_day.dart';
import '../models/streak_widget_data.dart';
import 'streak_calculator.dart';

/// Provider that reactively listens to streak data and updates the native streak widget.
final widgetSyncProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<List<StreakDay>>>(streakDaysProvider, (prev, next) {
    final days = next.valueOrNull;
    if (days != null && days.isNotEmpty) {
      final totalDays = days.length;
      final completedDays = days.where((d) => d.isCompleted).length;
      final daysLeft = math.max(0, totalDays - completedDays);
      final percentage = totalDays > 0
          ? ((completedDays / totalDays) * 100.0).clamp(0.0, 100.0)
          : 0.0;

      final currentStreak = calculateCurrentStreak(days);
      final last7 = last7Days(days);

      final widgetData = StreakWidgetData(
        habitName: "Focus Goal",
        currentStreak: currentStreak,
        targetDays: totalDays,
        daysLeft: daysLeft,
        percentage: percentage,
        last7Days: last7,
        accentColorHex: AnchorTheme.accent.toHex(),
      );

      WidgetSyncService.syncStreakData(widgetData);
    }
  }, fireImmediately: true);
});

class WidgetSyncService {
  WidgetSyncService._();

  /// Syncs streak data to native widgets
  static Future<void> syncStreakData(StreakWidgetData data) async {
    if (kIsWeb) return;
    try {
      final jsonStr = jsonEncode(data.toJson());
      await NativeBridge.widgetSyncChannel.invokeMethod('syncStreakData', {
        'data': jsonStr,
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to sync streak widget data: ${e.message}');
    }
  }

  /// Request to pin the streak widget to the home screen
  static Future<bool> pinStreakWidget() async {
    if (kIsWeb) return false;
    try {
      final result = await NativeBridge.widgetSyncChannel.invokeMethod('pinStreakWidget');
      return result == true;
    } on PlatformException catch (e) {
      debugPrint('Failed to pin streak widget: $e');
      return false;
    }
  }
}
