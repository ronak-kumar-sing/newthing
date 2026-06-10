import 'package:drift/drift.dart';

/// Daily journal entries: check-ins, reflections, and mood logs.
class JournalEntries extends Table {
  /// Entry ID (UUID v4).
  TextColumn get id => text()();

  /// Date of the entry.
  DateTimeColumn get date => dateTime()();

  /// Sleep quality rating (1-5).
  IntColumn get sleepRating => integer().nullable()();

  /// Energy level rating (1-5).
  IntColumn get energyRating => integer().nullable()();

  /// Focus level rating (1-5).
  IntColumn get focusRating => integer().nullable()();

  /// Mood rating (1-5).
  IntColumn get moodRating => integer().nullable()();

  /// Free-form daily reflection text.
  TextColumn get reflection => text().nullable()();

  /// One-word or one-sentence mood description.
  TextColumn get moodNote => text().nullable()();

  /// Intention set for the day.
  TextColumn get dailyIntention => text().nullable()();

  /// End-of-day "what made today harder" answer.
  TextColumn get endOfDayNote => text().nullable()();

  /// Screen time total in minutes.
  IntColumn get screenTimeMinutes => integer().nullable()();

  /// Productive time in minutes.
  IntColumn get productiveTimeMinutes => integer().nullable()();

  /// Distracted time in minutes.
  IntColumn get distractedTimeMinutes => integer().nullable()();

  /// Tasks completed count for the day.
  IntColumn get tasksCompleted => integer().withDefault(const Constant(0))();

  /// Whether weekly reflection was generated.
  BoolColumn get weeklyReflectionGenerated => boolean().withDefault(const Constant(false))();

  /// Weekly reflection text (only for Sunday entries).
  TextColumn get weeklyReflection => text().nullable()();

  /// When the entry was created.
  DateTimeColumn get createdAt => dateTime().withDefault(Constant(DateTime.now()))();

  @override
  Set<Column> get primaryKey => {id};
}
