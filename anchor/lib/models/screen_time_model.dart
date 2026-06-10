/// Screen time summary for a day.
class ScreenTimeSummary {
  final DateTime date;
  final int totalMinutes;
  final int productiveMinutes;
  final int neutralMinutes;
  final int distractedMinutes;
  final Map<String, int> appBreakdown;

  const ScreenTimeSummary({
    required this.date,
    required this.totalMinutes,
    required this.productiveMinutes,
    required this.neutralMinutes,
    required this.distractedMinutes,
    this.appBreakdown = const {},
  });

  /// Productive to total ratio (0.0 - 1.0).
  double get productiveRatio {
    if (totalMinutes == 0) return 0;
    return productiveMinutes / totalMinutes;
  }

  /// Health indicator color key.
  ScreenTimeHealth get health {
    if (productiveRatio >= 0.5) return ScreenTimeHealth.good;
    if (productiveRatio >= 0.3) return ScreenTimeHealth.fair;
    return ScreenTimeHealth.poor;
  }
}

enum ScreenTimeHealth { good, fair, poor }

/// A screen time session.
class ScreenSession {
  final String id;
  final String appName;
  final String category;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationSeconds;

  const ScreenSession({
    required this.id,
    required this.appName,
    required this.category,
    required this.startTime,
    this.endTime,
    this.durationSeconds = 0,
  });
}
