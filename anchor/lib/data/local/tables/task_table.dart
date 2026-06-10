import 'package:drift/drift.dart';

/// Tasks synced from Todoist and created locally.
class Tasks extends Table {
  /// Unique task ID (UUID v4).
  TextColumn get id => text()();

  /// Task title.
  TextColumn get title => text()();

  /// Optional description.
  TextColumn get description => text().nullable()();

  /// Due date (if any).
  DateTimeColumn get dueDate => dateTime().nullable()();

  /// Priority: 1=High, 2=Medium, 3=Low, 4=Normal (Todoist style).
  IntColumn get priority => integer().withDefault(const Constant(4))();

  /// Label: Academic, Personal, Project, Habit, Placement.
  TextColumn get label => text().nullable()();

  /// Project name the task belongs to.
  TextColumn get projectName => text().nullable()();

  /// Todoist project ID (for syncing).
  TextColumn get todoistProjectId => text().nullable()();

  /// Whether the task is completed.
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  /// When the task was completed (null if not completed).
  DateTimeColumn get completedAt => dateTime().nullable()();

  /// When the task was created.
  DateTimeColumn get createdAt => dateTime().withDefault(Constant(DateTime.now()))();

  /// Whether this task is a recurring habit.
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();

  /// Recurring schedule string (e.g., "every day").
  TextColumn get recurringSchedule => text().nullable()();

  /// Source: 'local' or 'todoist'.
  TextColumn get source => text().withDefault(const Constant('local'))();

  /// Todoist task ID for syncing.
  TextColumn get todoistId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
