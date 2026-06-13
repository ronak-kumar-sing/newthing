import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/streak/models/streak_day.dart';
import 'database_provider.dart';
import 'settings_provider.dart';

/// Central configuration for the independence journey.
class JourneyConfig {
  final DateTime? goalDate;
  final DateTime? startDate;
  final int totalDays;
  final int daysRemaining;
  final double progress;
  final String label;

  const JourneyConfig({
    this.goalDate,
    this.startDate,
    this.totalDays = 365,
    this.daysRemaining = 365,
    this.progress = 0.0,
    this.label = 'INDEPENDENCE CLOCK',
  });

  /// Whether the user has set a custom start date.
  bool get hasStartDate => startDate != null;
}

/// Computes the journey configuration from settings.
///
/// If the user has set a start date, totalDays is derived from the actual
/// start date → goal date range. Otherwise a 365-day fallback is used and
/// the UI should prompt the user to pick a start date.
final journeyConfigProvider = FutureProvider<JourneyConfig>((ref) async {
  final settings = await ref.watch(settingsProvider.future);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final goalDate = settings.independenceDate;
  final startDate = settings.independenceStartDate;
  final label = settings.independenceLabel ?? 'INDEPENDENCE CLOCK';

  final totalDays = (goalDate != null && startDate != null)
      ? goalDate.difference(startDate).inDays
      : 365;

  final daysRemaining = goalDate != null
      ? goalDate.difference(today).inDays
      : 365;

  final progress = totalDays > 0
      ? (1.0 - (daysRemaining / totalDays)).clamp(0.0, 1.0)
      : 0.0;

  return JourneyConfig(
    goalDate: goalDate,
    startDate: startDate,
    totalDays: totalDays,
    daysRemaining: daysRemaining,
    progress: progress,
    label: label,
  );
});

/// Focus check-in days across the journey window.
///
/// Generates one [StreakDay] per day from the journey start date up to today,
/// using the actual total days from [journeyConfigProvider]. A day is
/// considered completed when the user logged a focus rating >= 3.
final streakDaysProvider = FutureProvider<List<StreakDay>>((ref) async {
  final dao = ref.watch(journalDaoProvider);
  final journey = await ref.watch(journeyConfigProvider.future);

  final startDate = journey.startDate;
  final totalDays = journey.totalDays;
  final endDate = DateTime.now();
  final endKey = DateTime(endDate.year, endDate.month, endDate.day);

  if (startDate == null || totalDays <= 0) return const [];

  final entries = await dao.getEntriesForRange(startDate, endKey);
  final entryMap = {
    for (final e in entries)
      DateTime(e.date.year, e.date.month, e.date.day): e,
  };

  return List<StreakDay>.generate(totalDays, (i) {
    final date = startDate.add(Duration(days: i));
    final dateKey = DateTime(date.year, date.month, date.day);
    final entry = entryMap[dateKey];
    final isCompleted = entry != null && entry.focusRating != null && entry.focusRating! >= 3;
    final intensity = entry?.focusRating != null
        ? (entry!.focusRating! / 5.0).clamp(0.0, 1.0)
        : null;
    return StreakDay(
      date: date,
      isCompleted: isCompleted,
      intensity: intensity,
    );
  });
});
