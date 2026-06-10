import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/screen_time_table.dart';

part 'screen_time_dao.g.dart';

/// Data Access Object for screen time tracking.
@DriftAccessor(tables: [ScreenTimeSessions, AppCategories])
class ScreenTimeDao extends DatabaseAccessor<AnchorDatabase> with _$ScreenTimeDaoMixin {
  ScreenTimeDao(super.db);

  /// Start a new session.
  Future<void> startSession(String appName, DateTime startTime) async {
    final category = await getAppCategory(appName);
    await into(screenTimeSessions).insert(ScreenTimeSessionsCompanion(
      id: Value('st_${DateTime.now().millisecondsSinceEpoch}'),
      date: Value(DateTime.now()),
      appName: Value(appName),
      category: Value(category ?? 'neutral'),
      startTime: Value(startTime),
    ));
  }

  /// End the current active session.
  Future<void> endSession(String appName, DateTime endTime) async {
    final active = await getActiveSession(appName);
    if (active == null) return;

    final duration = endTime.difference(active.startTime);
    await (update(screenTimeSessions)
      ..where((s) => s.id.equals(active.id)))
        .write(ScreenTimeSessionsCompanion(
      endTime: Value(endTime),
      durationSeconds: Value(duration.inSeconds),
    ));
  }

  /// Get the currently active session for an app.
  Future<ScreenTimeSession?> getActiveSession(String appName) {
    return (select(screenTimeSessions)
      ..where((s) => s.appName.equals(appName))
      ..where((s) => s.endTime.isNull())
      ..orderBy([(s) => OrderingTerm(expression: s.startTime, mode: OrderingMode.desc)]))
        .getSingleOrNull();
  }

  /// Get all sessions for today.
  Future<List<ScreenTimeSession>> getTodaySessions() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return (select(screenTimeSessions)
      ..where((s) => s.date.isBetweenValues(start, end))
      ..orderBy([(s) => OrderingTerm(expression: s.startTime)]))
        .get();
  }

  /// Get total screen time for today in minutes.
  Future<int> getTodayTotalMinutes() async {
    final sessions = await getTodaySessions();
    return sessions.fold<int>(0, (sum, s) => sum + (s.durationSeconds ~/ 60));
  }

  /// Get time by category for today.
  Future<Map<String, int>> getTodayCategoryMinutes() async {
    final sessions = await getTodaySessions();
    final result = <String, int>{};
    for (final session in sessions) {
      final minutes = session.durationSeconds ~/ 60;
      result[session.category] = (result[session.category] ?? 0) + minutes;
    }
    return result;
  }

  /// Set app category.
  Future<void> setAppCategory(String appName, String category) {
    return into(appCategories).insertOnConflictUpdate(
      AppCategoriesCompanion(
        appName: Value(appName),
        category: Value(category),
      ),
    );
  }

  /// Get app category.
  Future<String?> getAppCategory(String appName) async {
    final cat = await (select(appCategories)
      ..where((c) => c.appName.equals(appName)))
        .getSingleOrNull();
    return cat?.category;
  }

  /// Get all category mappings.
  Future<Map<String, String>> getAllCategories() async {
    final cats = await select(appCategories).get();
    return {for (final c in cats) c.appName: c.category};
  }

  /// Get weekly screen time totals.
  Future<Map<DateTime, int>> getWeeklyMinutes() async {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));

    final sessions = await (select(screenTimeSessions)
      ..where((s) => s.date.isBiggerOrEqualValue(weekStart))
      ..orderBy([(s) => OrderingTerm(expression: s.date)]))
        .get();

    final result = <DateTime, int>{};
    for (final session in sessions) {
      final day = DateTime(session.date.year, session.date.month, session.date.day);
      result[day] = (result[day] ?? 0) + (session.durationSeconds ~/ 60);
    }
    return result;
  }
}
