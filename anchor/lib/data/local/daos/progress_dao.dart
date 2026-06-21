import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/progress_table.dart';

part 'progress_dao.g.dart';

/// Data Access Object for progress tracking.
@DriftAccessor(tables: [ProgressDimensions, ProgressValues])
class ProgressDao extends DatabaseAccessor<AnchorDatabase> with _$ProgressDaoMixin {
  ProgressDao(super.db);

  /// Get all dimensions ordered by sort order.
  Future<List<ProgressDimension>> getAllDimensions() {
    return (select(progressDimensions)
      ..orderBy([(d) => OrderingTerm(expression: d.sortOrder)]))
        .get();
  }

  /// Insert or update a dimension.
  Future<void> upsertDimension(ProgressDimensionsCompanion dimension) {
    return into(progressDimensions).insertOnConflictUpdate(dimension);
  }

  /// Delete a dimension and its values.
  Future<void> deleteDimension(String dimensionId) async {
    await (delete(progressValues)
      ..where((v) => v.dimensionId.equals(dimensionId))).go();
    await (delete(progressDimensions)
      ..where((d) => d.id.equals(dimensionId))).go();
  }

  /// Record a value for a dimension on a specific date.
  Future<void> recordValue(String dimensionId, DateTime date, double value) async {
    final existing = await (select(progressValues)
      ..where((v) => v.dimensionId.equals(dimensionId))
      ..where((v) => v.date.equals(date)))
        .getSingleOrNull();

    if (existing != null) {
      await (update(progressValues)
        ..where((v) => v.id.equals(existing.id)))
          .write(ProgressValuesCompanion(value: Value(value)));
    } else {
      await into(progressValues).insert(ProgressValuesCompanion(
        id: Value('pv_${dimensionId}_${date.millisecondsSinceEpoch}'),
        dimensionId: Value(dimensionId),
        date: Value(date),
        value: Value(value),
      ));
    }
  }

  /// Get values for a dimension in a date range.
  Future<List<ProgressValue>> getValuesForRange(String dimensionId, DateTime start, DateTime end) {
    return (select(progressValues)
      ..where((v) => v.dimensionId.equals(dimensionId))
      ..where((v) => v.date.isBetweenValues(start, end))
      ..orderBy([(v) => OrderingTerm(expression: v.date)]))
        .get();
  }

  /// Get all progress values (across all dimensions) in a date range.
  Future<List<ProgressValue>> getAllValuesForRange(DateTime start, DateTime end) {
    return (select(progressValues)
      ..where((v) => v.date.isBetweenValues(start, end))
      ..orderBy([(v) => OrderingTerm(expression: v.date)]))
        .get();
  }

  /// Get weekly total for a dimension.
  Future<double> getWeeklyTotal(String dimensionId, DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 7));
    return (select(progressValues)
      ..where((v) => v.dimensionId.equals(dimensionId))
      ..where((v) => v.date.isBetweenValues(weekStart, weekEnd)))
        .get()
        .then((values) => values.fold<double>(0.0, (sum, v) => sum + v.value));
  }

  /// Get today's value for a dimension.
  Future<double> getTodayValue(String dimensionId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final value = await (select(progressValues)
      ..where((v) => v.dimensionId.equals(dimensionId))
      ..where((v) => v.date.equals(today)))
        .getSingleOrNull();
    return value?.value ?? 0.0;
  }

  /// Watch all dimensions (reactive).
  Stream<List<ProgressDimension>> watchDimensions() {
    return (select(progressDimensions)
      ..orderBy([(d) => OrderingTerm(expression: d.sortOrder)]))
        .watch();
  }
}
