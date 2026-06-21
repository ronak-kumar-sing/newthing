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

  /// Ensures a single journal entry exists for today, creating one with a
  /// deterministic id if needed. This prevents multiple cards from creating
  /// separate rows for the same day.
  Future<JournalEntry> ensureTodayEntry() async {
    final existing = await getTodayEntry();
    if (existing != null) return existing;

    final today = DateTime.now();
    final dateOnly = DateTime(today.year, today.month, today.day);
    final id = 'journal_${dateOnly.toUtc().toIso8601String().split('T').first}';

    await into(journalEntries).insert(
      JournalEntriesCompanion(
        id: Value(id),
        date: Value(dateOnly),
      ),
      mode: InsertMode.insertOrIgnore,
    );

    return getTodayEntry().then((e) => e!);
  }

  /// Update check-in ratings for today.
  Future<void> updateCheckIn({
    int? sleepRating,
    int? energyRating,
    int? focusRating,
    int? moodRating,
  }) async {
    final existing = await ensureTodayEntry();

    await (update(journalEntries)
      ..where((e) => e.id.equals(existing.id)))
        .write(JournalEntriesCompanion(
      sleepRating: sleepRating != null ? Value(sleepRating) : const Value.absent(),
      energyRating: energyRating != null ? Value(energyRating) : const Value.absent(),
      focusRating: focusRating != null ? Value(focusRating) : const Value.absent(),
      moodRating: moodRating != null ? Value(moodRating) : const Value.absent(),
    ));
  }

  /// Update today's daily intention text.
  Future<void> updateIntention(String text) async {
    final existing = await ensureTodayEntry();

    await (update(journalEntries)
      ..where((e) => e.id.equals(existing.id)))
        .write(JournalEntriesCompanion(
      dailyIntention: Value(text),
    ));
  }

  /// Get streak count for a specific habit/behavior.
  /// Checks consecutive days where a condition is met, walking backwards day by day.
  Future<int> getStreak(bool Function(JournalEntry) condition) async {
    int streak = 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (int i = 0; i < 365; i++) {
      final expectedDate = today.subtract(Duration(days: i));
      final entry = await getEntryForDate(expectedDate);

      if (entry != null && condition(entry)) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }
}
