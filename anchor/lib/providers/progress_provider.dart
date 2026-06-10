import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/database.dart';
import '../models/progress_model.dart';
import 'database_provider.dart';

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
