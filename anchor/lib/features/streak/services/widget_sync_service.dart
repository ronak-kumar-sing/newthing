import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design/anchor_theme.dart';
import '../../../core/platform/native_bridge.dart';
import '../../../data/local/database.dart';
import '../../../modules/independence_clock/independence_clock_screen.dart';
import '../../../providers/task_provider.dart';
import '../models/streak_day.dart';
import '../models/streak_widget_data.dart';

/// Provider that reactively listens to data changes and updates native widgets.
final widgetSyncProvider = Provider<void>((ref) {
  // Listen to streakDaysProvider for checking consecutive completed focus checkins
  ref.listen<AsyncValue<List<StreakDay>>>(streakDaysProvider, (prev, next) {
    final days = next.valueOrNull;
    if (days != null && days.isNotEmpty) {
      final completedDays = days.where((d) => d.isCompleted).length;
      const targetDays = 365;
      final daysLeft = math.max(0, targetDays - completedDays);
      final percentage = ((completedDays / targetDays) * 100.0).clamp(0.0, 100.0);

      // Calculate current streak
      int currentStreak = 0;
      final today = DateTime.now();
      final todayKey = DateTime(today.year, today.month, today.day);

      final dateMap = {
        for (var d in days)
          DateTime(d.date.year, d.date.month, d.date.day): d
      };

      for (int i = 0; i <= 365; i++) {
        final checkDate = todayKey.subtract(Duration(days: i));
        final day = dateMap[checkDate];
        if (day != null && day.isCompleted) {
          currentStreak++;
        } else if (i == 0) {
          // If today hasn't been completed, check yesterday to keep streak active
          continue;
        } else {
          break;
        }
      }

      // Generate last 7 days status list
      final List<bool> last7 = [];
      for (int i = 6; i >= 0; i--) {
        final checkDate = todayKey.subtract(Duration(days: i));
        final day = dateMap[checkDate];
        last7.add(day?.isCompleted ?? false);
      }

      final widgetData = StreakWidgetData(
        habitName: "Focus Goal",
        currentStreak: currentStreak,
        targetDays: targetDays,
        daysLeft: daysLeft,
        percentage: percentage,
        last7Days: last7,
        accentColorHex: AnchorTheme.accent.toHex(),
      );

      WidgetSyncService.syncStreakData(widgetData);
    }
  }, fireImmediately: true);

  // Listen to activeTasksProvider for task lists
  ref.listen<AsyncValue<List<Task>>>(activeTasksProvider, (prev, next) {
    final tasks = next.valueOrNull;
    if (tasks != null) {
      final taskList = tasks.map((t) => TaskWidgetData(
        id: t.id,
        title: t.title,
        isCompleted: t.isCompleted,
        category: t.label ?? "General",
      )).toList();
      WidgetSyncService.syncTaskData(taskList);
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

  /// Syncs today's tasks to native widgets
  static Future<void> syncTaskData(List<TaskWidgetData> tasks) async {
    if (kIsWeb) return;
    try {
      final jsonList = tasks.map((t) => t.toJson()).toList();
      final jsonStr = jsonEncode(jsonList);
      await NativeBridge.widgetSyncChannel.invokeMethod('syncTaskData', {
        'tasks': jsonStr,
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to sync tasks widget data: ${e.message}');
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

  /// Request to pin the tasks widget to the home screen.
  static Future<bool> pinTasksWidget() async {
    if (kIsWeb) return false;
    try {
      final result = await NativeBridge.widgetSyncChannel.invokeMethod('pinTasksWidget');
      return result == true;
    } on PlatformException catch (e) {
      debugPrint('Failed to pin tasks widget: $e');
      return false;
    }
  }
}
