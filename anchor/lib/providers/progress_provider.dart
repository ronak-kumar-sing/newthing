import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/database.dart';
import '../models/progress_model.dart';
import '../models/life_progress_point.dart';
import 'database_provider.dart';
import 'api_provider.dart' as api_provider;

/// Currently selected dimension ID for charts/details.
final selectedDimensionIdProvider = StateProvider<String?>((ref) => null);

/// All progress dimensions (reactive).
final progressDimensionsProvider = StreamProvider<List<ProgressDimension>>((ref) {
  final dao = ref.watch(progressDaoProvider);
  return dao.watchDimensions();
});

/// Weekly progress summary for all dimensions.
final weeklyProgressProvider = FutureProvider<List<WeeklyProgress>>((ref) async {
  final dao = ref.watch(progressDaoProvider);
  final dimensions = await dao.getAllDimensions();
  final now = DateTime.now();
  final weekStart = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - 1));
  final lastWeekStart = weekStart.subtract(const Duration(days: 7));

  final results = <WeeklyProgress>[];
  for (final dim in dimensions) {
    final currentWeek = await dao.getWeeklyTotal(dim.id, weekStart);
    final lastWeek = await dao.getWeeklyTotal(dim.id, lastWeekStart);

    results.add(WeeklyProgress(
      dimensionId: dim.id,
      dimensionName: dim.name,
      currentWeekTotal: currentWeek,
      lastWeekTotal: lastWeek,
      weeklyTarget: dim.weeklyTarget,
      colorHex: dim.colorHex,
      unit: dim.unit,
    ));
  }

  return results;
});

/// Weekly trend data points for Study, Coding, and Gym.
final lifeTrendDataProvider = FutureProvider<List<LifeProgressPoint>>((ref) async {
  final dao = ref.watch(progressDaoProvider);
  final now = DateTime.now();
  
  // Find Monday of the current week
  final monday = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - 1));
  
  const studyId = 'dim_study_hours';
  const gymId = 'dim_gym_workouts';
  const leetcodeId = 'dim_leetcode';
  
  // Fetch values for the 7 days of the week (Monday to Sunday)
  final studyValues = await dao.getValuesForRange(studyId, monday, monday.add(const Duration(days: 6)));
  final gymValues = await dao.getValuesForRange(gymId, monday, monday.add(const Duration(days: 6)));
  final leetcodeValues = await dao.getValuesForRange(leetcodeId, monday, monday.add(const Duration(days: 6)));
  
  final studyMap = {for (var v in studyValues) _dateKey(v.date): v.value};
  final gymMap = {for (var v in gymValues) _dateKey(v.date): v.value};
  final leetcodeMap = {for (var v in leetcodeValues) _dateKey(v.date): v.value};
  
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final points = <LifeProgressPoint>[];
  
  for (int i = 0; i < 7; i++) {
    final dayDate = monday.add(Duration(days: i));
    final key = _dateKey(dayDate);
    points.add(LifeProgressPoint(
      label: days[i],
      study: studyMap[key] ?? 0.0,
      coding: leetcodeMap[key] ?? 0.0,
      gym: gymMap[key] ?? 0.0,
    ));
  }
  
  return points;
});

String _dateKey(DateTime date) {
  return '${date.year}-${date.month}-${date.day}';
}

// ─── Streak Data ─────────────────────────────────────────────────────────

/// Streak data for a single dimension.
class StreakData {
  final String dimensionId;
  final String dimensionName;
  final int currentStreak;
  final int targetStreak;
  final String colorHex;

  const StreakData({
    required this.dimensionId,
    required this.dimensionName,
    required this.currentStreak,
    required this.targetStreak,
    required this.colorHex,
  });
}

/// Calculates real streak data from the database for all dimensions.
final streakDataProvider = FutureProvider<List<StreakData>>((ref) async {
  final dao = ref.watch(progressDaoProvider);
  final dimensions = await dao.getAllDimensions();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final results = <StreakData>[];

  for (final dim in dimensions) {
    // Look back up to 365 days for streak calculation
    int currentStreak = 0;
    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final values = await dao.getValuesForRange(dim.id, date, date.add(const Duration(hours: 23, minutes: 59)));
      final dayTotal = values.fold<double>(0.0, (sum, v) => sum + v.value);
      if (dayTotal > 0) {
        currentStreak++;
      } else {
        break;
      }
    }

    // Target = weekly target (minimum 7 for a full week streak)
    final target = dim.weeklyTarget.round().clamp(7, 30);

    results.add(StreakData(
      dimensionId: dim.id,
      dimensionName: dim.name,
      currentStreak: currentStreak,
      targetStreak: target,
      colorHex: dim.colorHex,
    ));
  }

  return results;
});

/// Real AI insights from actual data.
class RealInsightData {
  final String studyTrend;
  final String studyTrendDirection;
  final String studyTrendPercent;
  final String gymFocusStatus;
  final String gymFocusSub;
  final int overdueTasksCount;
  final String? aiSummary;

  const RealInsightData({
    required this.studyTrend,
    required this.studyTrendDirection,
    required this.studyTrendPercent,
    required this.gymFocusStatus,
    required this.gymFocusSub,
    required this.overdueTasksCount,
    this.aiSummary,
  });
}

/// Calculates real insight data from the database.
final realInsightProvider = FutureProvider<RealInsightData>((ref) async {
  final dao = ref.watch(progressDaoProvider);
  final taskDao = ref.watch(taskDaoProvider);
  final now = DateTime.now();
  final monday = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - 1));
  final lastMonday = monday.subtract(const Duration(days: 7));

  // Study trend
  final studyThisWeek = await dao.getWeeklyTotal('dim_study_hours', monday);
  final studyLastWeek = await dao.getWeeklyTotal('dim_study_hours', lastMonday);
  String studyDirection = 'flat';
  String studyPercent = '0%';
  if (studyLastWeek > 0) {
    final pct = ((studyThisWeek - studyLastWeek) / studyLastWeek * 100).round();
    studyPercent = '${pct.abs()}%';
    studyDirection = pct > 0 ? 'up' : (pct < 0 ? 'down' : 'flat');
  } else if (studyThisWeek > 0) {
    studyDirection = 'up';
    studyPercent = '100%';
  }

  // Gym focus
  final gymThisWeek = await dao.getWeeklyTotal('dim_gym_workouts', monday);
  final gymLastWeek = await dao.getWeeklyTotal('dim_gym_workouts', lastMonday);
  String gymStatus;
  String gymSub;
  if (gymThisWeek >= 3) {
    gymStatus = 'Active';
    gymSub = '${gymThisWeek.toInt()} sessions this week';
  } else if (gymThisWeek > 0) {
    gymStatus = 'Low';
    gymSub = 'Only ${gymThisWeek.toInt()} session${gymThisWeek > 1 ? 's' : ''} — push harder';
  } else if (gymLastWeek > 0) {
    gymStatus = 'Paused';
    gymSub = 'Light workout advised';
  } else {
    gymStatus = 'Inactive';
    gymSub = 'Start with a light session';
  }

  // Overdue tasks
  final overdueCount = await taskDao.getOverdueTasks().then((list) => list.length);

  // Gemini Integration
  String? aiSummary;
  try {
    final gemini = ref.read(api_provider.geminiApiProvider);
    if (gemini.isConfigured) {
      aiSummary = await gemini.generateWeeklyReflection(weekData: {
        'studyHoursThisWeek': studyThisWeek,
        'studyDirection': studyDirection,
        'gymStatus': gymStatus,
        'gymSub': gymSub,
        'overdueTasks': overdueCount,
      });
    }
  } catch (e) {
    debugPrint('Failed to generate Gemini insight: $e');
  }

  return RealInsightData(
    studyTrend: 'Study Trend',
    studyTrendDirection: studyDirection,
    studyTrendPercent: studyPercent,
    gymFocusStatus: gymStatus,
    gymFocusSub: gymSub,
    overdueTasksCount: overdueCount,
    aiSummary: aiSummary,
  );
});

/// Weekly chart data for a specific week offset (0 = current, 1 = last week, etc.)
final weekOffsetProvider = StateProvider<int>((ref) => 0);

final weeklyChartDataForOffsetProvider = FutureProvider<Map<int, double>>((ref) async {
  final selectedId = ref.watch(selectedDimensionIdProvider);
  if (selectedId == null) return {};
  final offset = ref.watch(weekOffsetProvider);
  final dao = ref.watch(progressDaoProvider);
  final now = DateTime.now();
  final currentMonday = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - 1));
  final targetMonday = currentMonday.subtract(Duration(days: offset * 7));
  final targetSunday = targetMonday.add(const Duration(days: 7));

  final values = await dao.getValuesForRange(selectedId, targetMonday, targetSunday);
  final result = <int, double>{};
  for (final v in values) {
    result[v.date.weekday] = v.value;
  }
  return result;
});
