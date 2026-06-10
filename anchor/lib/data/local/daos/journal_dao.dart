import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/journal_table.dart';

part 'journal_dao.g.dart';

/// Data Access Object for journal entries.
@DriftAccessor(tables: [JournalEntries])
class JournalDao extends DatabaseAccessor<AnchorDatabase> with _$JournalDaoMixin {
  JournalDao(super.db);

  /// Get today's entry, or null if not exists.
  Future<JournalEntry?> getTodayEntry() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return (select(journalEntries)
      ..where((e) => e.date.isBetweenValues(start, end)))
        .getSingleOrNull();
  }

  /// Get entry for a specific date.
  Future<JournalEntry?> getEntryForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (select(journalEntries)
      ..where((e) => e.date.isBetweenValues(start, end)))
        .getSingleOrNull();
  }

  /// Get entries for a date range.
  Future<List<JournalEntry>> getEntriesForRange(DateTime start, DateTime end) {
    return (select(journalEntries)
      ..where((e) => e.date.isBetweenValues(start, end))
      ..orderBy([(e) => OrderingTerm(expression: e.date, mode: OrderingMode.desc)]))
        .get();
  }

  /// Upsert a journal entry.
  Future<void> upsertEntry(JournalEntriesCompanion entry) {
    return into(journalEntries).insertOnConflictUpdate(entry);
  }

  /// Update check-in ratings for today.
  Future<void> updateCheckIn({
    int? sleepRating,
    int? energyRating,
    int? focusRating,
    int? moodRating,
  }) async {
    final today = DateTime.now();
    final existing = await getTodayEntry();

    if (existing != null) {
      await (update(journalEntries)
        ..where((e) => e.id.equals(existing.id)))
          .write(JournalEntriesCompanion(
        sleepRating: sleepRating != null ? Value(sleepRating) : const Value.absent(),
        energyRating: energyRating != null ? Value(energyRating) : const Value.absent(),
        focusRating: focusRating != null ? Value(focusRating) : const Value.absent(),
        moodRating: moodRating != null ? Value(moodRating) : const Value.absent(),
      ));
    } else {
      await into(journalEntries).insert(JournalEntriesCompanion(
        id: Value('journal_${today.millisecondsSinceEpoch}'),
        date: Value(DateTime(today.year, today.month, today.day)),
        sleepRating: sleepRating != null ? Value(sleepRating) : const Value.absent(),
        energyRating: energyRating != null ? Value(energyRating) : const Value.absent(),
        focusRating: focusRating != null ? Value(focusRating) : const Value.absent(),
        moodRating: moodRating != null ? Value(moodRating) : const Value.absent(),
      ));
    }
  }

  /// Get streak count for a specific habit/behavior.
  /// Checks consecutive days where a condition is met.
  Future<int> getStreak(bool Function(JournalEntry) condition) async {
    final entries = await (select(journalEntries)
      ..orderBy([(e) => OrderingTerm(expression: e.date, mode: OrderingMode.desc)]))
        .get();

    int streak = 0;
    final now = DateTime.now();

    for (int i = 0; i < entries.length; i++) {
      final entryDate = DateTime(
        entries[i].date.year,
        entries[i].date.month,
        entries[i].date.day,
      );
      final expectedDate = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: i));

      if (entryDate == expectedDate && condition(entries[i])) {
        streak++;
      } else if (i == 0 && entryDate != expectedDate) {
        // Today hasn't been checked in yet, skip
        continue;
      } else {
        break;
      }
    }

    return streak;
  }
}
