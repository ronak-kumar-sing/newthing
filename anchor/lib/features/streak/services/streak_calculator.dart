import '../models/streak_day.dart';

/// Calculates the current consecutive-day streak from a list of [StreakDay].
///
/// Walks backwards from [from] (defaults to today) one day at a time.
/// A day counts toward the streak only if it is present in [days] and
/// [StreakDay.isCompleted] is true. A missing or incomplete day ends the streak.
///
/// This intentionally does NOT skip today: if today has not been completed,
/// the streak is zero, matching a strict daily habit streak.
int calculateCurrentStreak(List<StreakDay> days, {DateTime? from}) {
  if (days.isEmpty) return 0;

  final start = from ?? DateTime.now();
  final today = DateTime(start.year, start.month, start.day);

  final dateMap = {
    for (final d in days)
      DateTime(d.date.year, d.date.month, d.date.day): d,
  };

  int streak = 0;
  for (int i = 0; i < days.length + 7; i++) {
    final checkDate = today.subtract(Duration(days: i));
    final day = dateMap[checkDate];
    if (day != null && day.isCompleted) {
      streak++;
    } else {
      break;
    }
  }

  return streak;
}

/// Returns the completion status for the last 7 days ending at [from].
/// Index 0 is 6 days before [from], index 6 is [from].
List<bool> last7Days(List<StreakDay> days, {DateTime? from}) {
  final start = from ?? DateTime.now();
  final today = DateTime(start.year, start.month, start.day);

  final dateMap = {
    for (final d in days)
      DateTime(d.date.year, d.date.month, d.date.day): d,
  };

  return [
    for (int i = 6; i >= 0; i--)
      dateMap[today.subtract(Duration(days: i))]?.isCompleted ?? false,
  ];
}
