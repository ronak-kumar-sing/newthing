import 'package:drift/drift.dart';

/// Custom progress dimensions tracked by the user.
class ProgressDimensions extends Table {
  /// Dimension ID (UUID v4).
  TextColumn get id => text()();

  /// Name of the dimension (e.g., "Study Hours", "Exercise", "Coding").
  TextColumn get name => text()();

  /// Target value per week.
  RealColumn get weeklyTarget => real().withDefault(const Constant(0.0))();

  /// Unit of measurement (e.g., "hours", "sessions", "pages").
  TextColumn get unit => text().withDefault(const Constant('count'))();

  /// Whether this is an automatic (computed) dimension.
  BoolColumn get isAutomatic => boolean().withDefault(const Constant(false))();

  /// Color hex for the dimension.
  TextColumn get colorHex => text().withDefault(const Constant('#5B8DEF'))();

  /// Order in the UI.
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// When created.
  DateTimeColumn get createdAt => dateTime().withDefault(Constant(DateTime.now()))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Daily values for each progress dimension.
class ProgressValues extends Table {
  /// Value ID (UUID v4).
  TextColumn get id => text()();

  /// Reference to ProgressDimensions.
  TextColumn get dimensionId => text()();

  /// Date of the value.
  DateTimeColumn get date => dateTime()();

  /// Numeric value for that day.
  RealColumn get value => real().withDefault(const Constant(0.0))();

  @override
  Set<Column> get primaryKey => {id};
}
