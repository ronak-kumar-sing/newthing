/// A progress dimension definition.
class ProgressDimensionModel {
  final String id;
  final String name;
  final double weeklyTarget;
  final String unit;
  final bool isAutomatic;
  final String colorHex;
  final int sortOrder;

  const ProgressDimensionModel({
    required this.id,
    required this.name,
    this.weeklyTarget = 0.0,
    this.unit = 'count',
    this.isAutomatic = false,
    this.colorHex = '#5B8DEF',
    this.sortOrder = 0,
  });
}

/// A daily progress value.
class ProgressValueModel {
  final String id;
  final String dimensionId;
  final DateTime date;
  final double value;

  const ProgressValueModel({
    required this.id,
    required this.dimensionId,
    required this.date,
    this.value = 0.0,
  });
}

/// Weekly summary for a dimension.
class WeeklyProgress {
  final String dimensionId;
  final String dimensionName;
  final double currentWeekTotal;
  final double lastWeekTotal;
  final double weeklyTarget;
  final String colorHex;
  final String unit;
  final int streak;

  const WeeklyProgress({
    required this.dimensionId,
    required this.dimensionName,
    required this.currentWeekTotal,
    required this.lastWeekTotal,
    required this.weeklyTarget,
    this.colorHex = '#5B8DEF',
    this.unit = 'count',
    this.streak = 0,
  });

  /// Progress percentage (0.0 - 1.0+).
  double get progressPercent {
    if (weeklyTarget == 0) return 0;
    return currentWeekTotal / weeklyTarget;
  }

  /// Whether the weekly target is met.
  bool get isTargetMet => currentWeekTotal >= weeklyTarget;

  /// Trend compared to last week.
  ProgressTrend get trend {
    if (lastWeekTotal == 0) return ProgressTrend.neutral;
    final change = currentWeekTotal - lastWeekTotal;
    if (change > 0) return ProgressTrend.up;
    if (change < 0) return ProgressTrend.down;
    return ProgressTrend.neutral;
  }
}

enum ProgressTrend { up, down, neutral }
