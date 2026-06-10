import 'package:drift/drift.dart';

/// Screen time tracking sessions.
class ScreenTimeSessions extends Table {
  /// Session ID (UUID v4).
  TextColumn get id => text()();

  /// Date of the session.
  DateTimeColumn get date => dateTime()();

  /// App name or window title.
  TextColumn get appName => text()();

  /// Category: productive, neutral, distracted.
  TextColumn get category => text().withDefault(const Constant('neutral'))();

  /// Start time.
  DateTimeColumn get startTime => dateTime()();

  /// End time (null if still active).
  DateTimeColumn get endTime => dateTime().nullable()();

  /// Duration in seconds (computed when ended).
  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// App category mappings (user-defined labels).
class AppCategories extends Table {
  /// App name or bundle ID.
  TextColumn get appName => text()();

  /// Category: productive, neutral, distracted.
  TextColumn get category => text()();

  @override
  Set<Column> get primaryKey => {appName};
}
