// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(4),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _projectNameMeta = const VerificationMeta(
    'projectName',
  );
  @override
  late final GeneratedColumn<String> projectName = GeneratedColumn<String>(
    'project_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _todoistProjectIdMeta = const VerificationMeta(
    'todoistProjectId',
  );
  @override
  late final GeneratedColumn<String> todoistProjectId = GeneratedColumn<String>(
    'todoist_project_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.now()),
  );
  static const VerificationMeta _isRecurringMeta = const VerificationMeta(
    'isRecurring',
  );
  @override
  late final GeneratedColumn<bool> isRecurring = GeneratedColumn<bool>(
    'is_recurring',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_recurring" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _recurringScheduleMeta = const VerificationMeta(
    'recurringSchedule',
  );
  @override
  late final GeneratedColumn<String> recurringSchedule =
      GeneratedColumn<String>(
        'recurring_schedule',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _todoistIdMeta = const VerificationMeta(
    'todoistId',
  );
  @override
  late final GeneratedColumn<String> todoistId = GeneratedColumn<String>(
    'todoist_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    dueDate,
    priority,
    label,
    projectName,
    todoistProjectId,
    isCompleted,
    completedAt,
    createdAt,
    isRecurring,
    recurringSchedule,
    source,
    todoistId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('project_name')) {
      context.handle(
        _projectNameMeta,
        projectName.isAcceptableOrUnknown(
          data['project_name']!,
          _projectNameMeta,
        ),
      );
    }
    if (data.containsKey('todoist_project_id')) {
      context.handle(
        _todoistProjectIdMeta,
        todoistProjectId.isAcceptableOrUnknown(
          data['todoist_project_id']!,
          _todoistProjectIdMeta,
        ),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('is_recurring')) {
      context.handle(
        _isRecurringMeta,
        isRecurring.isAcceptableOrUnknown(
          data['is_recurring']!,
          _isRecurringMeta,
        ),
      );
    }
    if (data.containsKey('recurring_schedule')) {
      context.handle(
        _recurringScheduleMeta,
        recurringSchedule.isAcceptableOrUnknown(
          data['recurring_schedule']!,
          _recurringScheduleMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('todoist_id')) {
      context.handle(
        _todoistIdMeta,
        todoistId.isAcceptableOrUnknown(data['todoist_id']!, _todoistIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      projectName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_name'],
      ),
      todoistProjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}todoist_project_id'],
      ),
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isRecurring: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_recurring'],
      )!,
      recurringSchedule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurring_schedule'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      todoistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}todoist_id'],
      ),
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  /// Unique task ID (UUID v4).
  final String id;

  /// Task title.
  final String title;

  /// Optional description.
  final String? description;

  /// Due date (if any).
  final DateTime? dueDate;

  /// Priority: 1=High, 2=Medium, 3=Low, 4=Normal (Todoist style).
  final int priority;

  /// Label: Academic, Personal, Project, Habit, Placement.
  final String? label;

  /// Project name the task belongs to.
  final String? projectName;

  /// Todoist project ID (for syncing).
  final String? todoistProjectId;

  /// Whether the task is completed.
  final bool isCompleted;

  /// When the task was completed (null if not completed).
  final DateTime? completedAt;

  /// When the task was created.
  final DateTime createdAt;

  /// Whether this task is a recurring habit.
  final bool isRecurring;

  /// Recurring schedule string (e.g., "every day").
  final String? recurringSchedule;

  /// Source: 'local' or 'todoist'.
  final String source;

  /// Todoist task ID for syncing.
  final String? todoistId;
  const Task({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    required this.priority,
    this.label,
    this.projectName,
    this.todoistProjectId,
    required this.isCompleted,
    this.completedAt,
    required this.createdAt,
    required this.isRecurring,
    this.recurringSchedule,
    required this.source,
    this.todoistId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['priority'] = Variable<int>(priority);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    if (!nullToAbsent || projectName != null) {
      map['project_name'] = Variable<String>(projectName);
    }
    if (!nullToAbsent || todoistProjectId != null) {
      map['todoist_project_id'] = Variable<String>(todoistProjectId);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_recurring'] = Variable<bool>(isRecurring);
    if (!nullToAbsent || recurringSchedule != null) {
      map['recurring_schedule'] = Variable<String>(recurringSchedule);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || todoistId != null) {
      map['todoist_id'] = Variable<String>(todoistId);
    }
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      priority: Value(priority),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      projectName: projectName == null && nullToAbsent
          ? const Value.absent()
          : Value(projectName),
      todoistProjectId: todoistProjectId == null && nullToAbsent
          ? const Value.absent()
          : Value(todoistProjectId),
      isCompleted: Value(isCompleted),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      createdAt: Value(createdAt),
      isRecurring: Value(isRecurring),
      recurringSchedule: recurringSchedule == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringSchedule),
      source: Value(source),
      todoistId: todoistId == null && nullToAbsent
          ? const Value.absent()
          : Value(todoistId),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      priority: serializer.fromJson<int>(json['priority']),
      label: serializer.fromJson<String?>(json['label']),
      projectName: serializer.fromJson<String?>(json['projectName']),
      todoistProjectId: serializer.fromJson<String?>(json['todoistProjectId']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isRecurring: serializer.fromJson<bool>(json['isRecurring']),
      recurringSchedule: serializer.fromJson<String?>(
        json['recurringSchedule'],
      ),
      source: serializer.fromJson<String>(json['source']),
      todoistId: serializer.fromJson<String?>(json['todoistId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'priority': serializer.toJson<int>(priority),
      'label': serializer.toJson<String?>(label),
      'projectName': serializer.toJson<String?>(projectName),
      'todoistProjectId': serializer.toJson<String?>(todoistProjectId),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isRecurring': serializer.toJson<bool>(isRecurring),
      'recurringSchedule': serializer.toJson<String?>(recurringSchedule),
      'source': serializer.toJson<String>(source),
      'todoistId': serializer.toJson<String?>(todoistId),
    };
  }

  Task copyWith({
    String? id,
    String? title,
    Value<String?> description = const Value.absent(),
    Value<DateTime?> dueDate = const Value.absent(),
    int? priority,
    Value<String?> label = const Value.absent(),
    Value<String?> projectName = const Value.absent(),
    Value<String?> todoistProjectId = const Value.absent(),
    bool? isCompleted,
    Value<DateTime?> completedAt = const Value.absent(),
    DateTime? createdAt,
    bool? isRecurring,
    Value<String?> recurringSchedule = const Value.absent(),
    String? source,
    Value<String?> todoistId = const Value.absent(),
  }) => Task(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    priority: priority ?? this.priority,
    label: label.present ? label.value : this.label,
    projectName: projectName.present ? projectName.value : this.projectName,
    todoistProjectId: todoistProjectId.present
        ? todoistProjectId.value
        : this.todoistProjectId,
    isCompleted: isCompleted ?? this.isCompleted,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    createdAt: createdAt ?? this.createdAt,
    isRecurring: isRecurring ?? this.isRecurring,
    recurringSchedule: recurringSchedule.present
        ? recurringSchedule.value
        : this.recurringSchedule,
    source: source ?? this.source,
    todoistId: todoistId.present ? todoistId.value : this.todoistId,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      priority: data.priority.present ? data.priority.value : this.priority,
      label: data.label.present ? data.label.value : this.label,
      projectName: data.projectName.present
          ? data.projectName.value
          : this.projectName,
      todoistProjectId: data.todoistProjectId.present
          ? data.todoistProjectId.value
          : this.todoistProjectId,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isRecurring: data.isRecurring.present
          ? data.isRecurring.value
          : this.isRecurring,
      recurringSchedule: data.recurringSchedule.present
          ? data.recurringSchedule.value
          : this.recurringSchedule,
      source: data.source.present ? data.source.value : this.source,
      todoistId: data.todoistId.present ? data.todoistId.value : this.todoistId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dueDate: $dueDate, ')
          ..write('priority: $priority, ')
          ..write('label: $label, ')
          ..write('projectName: $projectName, ')
          ..write('todoistProjectId: $todoistProjectId, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('recurringSchedule: $recurringSchedule, ')
          ..write('source: $source, ')
          ..write('todoistId: $todoistId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    dueDate,
    priority,
    label,
    projectName,
    todoistProjectId,
    isCompleted,
    completedAt,
    createdAt,
    isRecurring,
    recurringSchedule,
    source,
    todoistId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.dueDate == this.dueDate &&
          other.priority == this.priority &&
          other.label == this.label &&
          other.projectName == this.projectName &&
          other.todoistProjectId == this.todoistProjectId &&
          other.isCompleted == this.isCompleted &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt &&
          other.isRecurring == this.isRecurring &&
          other.recurringSchedule == this.recurringSchedule &&
          other.source == this.source &&
          other.todoistId == this.todoistId);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime?> dueDate;
  final Value<int> priority;
  final Value<String?> label;
  final Value<String?> projectName;
  final Value<String?> todoistProjectId;
  final Value<bool> isCompleted;
  final Value<DateTime?> completedAt;
  final Value<DateTime> createdAt;
  final Value<bool> isRecurring;
  final Value<String?> recurringSchedule;
  final Value<String> source;
  final Value<String?> todoistId;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.priority = const Value.absent(),
    this.label = const Value.absent(),
    this.projectName = const Value.absent(),
    this.todoistProjectId = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.recurringSchedule = const Value.absent(),
    this.source = const Value.absent(),
    this.todoistId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.priority = const Value.absent(),
    this.label = const Value.absent(),
    this.projectName = const Value.absent(),
    this.todoistProjectId = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.recurringSchedule = const Value.absent(),
    this.source = const Value.absent(),
    this.todoistId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title);
  static Insertable<Task> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? dueDate,
    Expression<int>? priority,
    Expression<String>? label,
    Expression<String>? projectName,
    Expression<String>? todoistProjectId,
    Expression<bool>? isCompleted,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? createdAt,
    Expression<bool>? isRecurring,
    Expression<String>? recurringSchedule,
    Expression<String>? source,
    Expression<String>? todoistId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (dueDate != null) 'due_date': dueDate,
      if (priority != null) 'priority': priority,
      if (label != null) 'label': label,
      if (projectName != null) 'project_name': projectName,
      if (todoistProjectId != null) 'todoist_project_id': todoistProjectId,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (isRecurring != null) 'is_recurring': isRecurring,
      if (recurringSchedule != null) 'recurring_schedule': recurringSchedule,
      if (source != null) 'source': source,
      if (todoistId != null) 'todoist_id': todoistId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<DateTime?>? dueDate,
    Value<int>? priority,
    Value<String?>? label,
    Value<String?>? projectName,
    Value<String?>? todoistProjectId,
    Value<bool>? isCompleted,
    Value<DateTime?>? completedAt,
    Value<DateTime>? createdAt,
    Value<bool>? isRecurring,
    Value<String?>? recurringSchedule,
    Value<String>? source,
    Value<String?>? todoistId,
    Value<int>? rowid,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      label: label ?? this.label,
      projectName: projectName ?? this.projectName,
      todoistProjectId: todoistProjectId ?? this.todoistProjectId,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringSchedule: recurringSchedule ?? this.recurringSchedule,
      source: source ?? this.source,
      todoistId: todoistId ?? this.todoistId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (projectName.present) {
      map['project_name'] = Variable<String>(projectName.value);
    }
    if (todoistProjectId.present) {
      map['todoist_project_id'] = Variable<String>(todoistProjectId.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isRecurring.present) {
      map['is_recurring'] = Variable<bool>(isRecurring.value);
    }
    if (recurringSchedule.present) {
      map['recurring_schedule'] = Variable<String>(recurringSchedule.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (todoistId.present) {
      map['todoist_id'] = Variable<String>(todoistId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dueDate: $dueDate, ')
          ..write('priority: $priority, ')
          ..write('label: $label, ')
          ..write('projectName: $projectName, ')
          ..write('todoistProjectId: $todoistProjectId, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('recurringSchedule: $recurringSchedule, ')
          ..write('source: $source, ')
          ..write('todoistId: $todoistId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JournalEntriesTable extends JournalEntries
    with TableInfo<$JournalEntriesTable, JournalEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sleepRatingMeta = const VerificationMeta(
    'sleepRating',
  );
  @override
  late final GeneratedColumn<int> sleepRating = GeneratedColumn<int>(
    'sleep_rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _energyRatingMeta = const VerificationMeta(
    'energyRating',
  );
  @override
  late final GeneratedColumn<int> energyRating = GeneratedColumn<int>(
    'energy_rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _focusRatingMeta = const VerificationMeta(
    'focusRating',
  );
  @override
  late final GeneratedColumn<int> focusRating = GeneratedColumn<int>(
    'focus_rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _moodRatingMeta = const VerificationMeta(
    'moodRating',
  );
  @override
  late final GeneratedColumn<int> moodRating = GeneratedColumn<int>(
    'mood_rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reflectionMeta = const VerificationMeta(
    'reflection',
  );
  @override
  late final GeneratedColumn<String> reflection = GeneratedColumn<String>(
    'reflection',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _moodNoteMeta = const VerificationMeta(
    'moodNote',
  );
  @override
  late final GeneratedColumn<String> moodNote = GeneratedColumn<String>(
    'mood_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dailyIntentionMeta = const VerificationMeta(
    'dailyIntention',
  );
  @override
  late final GeneratedColumn<String> dailyIntention = GeneratedColumn<String>(
    'daily_intention',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endOfDayNoteMeta = const VerificationMeta(
    'endOfDayNote',
  );
  @override
  late final GeneratedColumn<String> endOfDayNote = GeneratedColumn<String>(
    'end_of_day_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _screenTimeMinutesMeta = const VerificationMeta(
    'screenTimeMinutes',
  );
  @override
  late final GeneratedColumn<int> screenTimeMinutes = GeneratedColumn<int>(
    'screen_time_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productiveTimeMinutesMeta =
      const VerificationMeta('productiveTimeMinutes');
  @override
  late final GeneratedColumn<int> productiveTimeMinutes = GeneratedColumn<int>(
    'productive_time_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distractedTimeMinutesMeta =
      const VerificationMeta('distractedTimeMinutes');
  @override
  late final GeneratedColumn<int> distractedTimeMinutes = GeneratedColumn<int>(
    'distracted_time_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tasksCompletedMeta = const VerificationMeta(
    'tasksCompleted',
  );
  @override
  late final GeneratedColumn<int> tasksCompleted = GeneratedColumn<int>(
    'tasks_completed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _weeklyReflectionGeneratedMeta =
      const VerificationMeta('weeklyReflectionGenerated');
  @override
  late final GeneratedColumn<bool> weeklyReflectionGenerated =
      GeneratedColumn<bool>(
        'weekly_reflection_generated',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("weekly_reflection_generated" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _weeklyReflectionMeta = const VerificationMeta(
    'weeklyReflection',
  );
  @override
  late final GeneratedColumn<String> weeklyReflection = GeneratedColumn<String>(
    'weekly_reflection',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.now()),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    sleepRating,
    energyRating,
    focusRating,
    moodRating,
    reflection,
    moodNote,
    dailyIntention,
    endOfDayNote,
    screenTimeMinutes,
    productiveTimeMinutes,
    distractedTimeMinutes,
    tasksCompleted,
    weeklyReflectionGenerated,
    weeklyReflection,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<JournalEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('sleep_rating')) {
      context.handle(
        _sleepRatingMeta,
        sleepRating.isAcceptableOrUnknown(
          data['sleep_rating']!,
          _sleepRatingMeta,
        ),
      );
    }
    if (data.containsKey('energy_rating')) {
      context.handle(
        _energyRatingMeta,
        energyRating.isAcceptableOrUnknown(
          data['energy_rating']!,
          _energyRatingMeta,
        ),
      );
    }
    if (data.containsKey('focus_rating')) {
      context.handle(
        _focusRatingMeta,
        focusRating.isAcceptableOrUnknown(
          data['focus_rating']!,
          _focusRatingMeta,
        ),
      );
    }
    if (data.containsKey('mood_rating')) {
      context.handle(
        _moodRatingMeta,
        moodRating.isAcceptableOrUnknown(data['mood_rating']!, _moodRatingMeta),
      );
    }
    if (data.containsKey('reflection')) {
      context.handle(
        _reflectionMeta,
        reflection.isAcceptableOrUnknown(data['reflection']!, _reflectionMeta),
      );
    }
    if (data.containsKey('mood_note')) {
      context.handle(
        _moodNoteMeta,
        moodNote.isAcceptableOrUnknown(data['mood_note']!, _moodNoteMeta),
      );
    }
    if (data.containsKey('daily_intention')) {
      context.handle(
        _dailyIntentionMeta,
        dailyIntention.isAcceptableOrUnknown(
          data['daily_intention']!,
          _dailyIntentionMeta,
        ),
      );
    }
    if (data.containsKey('end_of_day_note')) {
      context.handle(
        _endOfDayNoteMeta,
        endOfDayNote.isAcceptableOrUnknown(
          data['end_of_day_note']!,
          _endOfDayNoteMeta,
        ),
      );
    }
    if (data.containsKey('screen_time_minutes')) {
      context.handle(
        _screenTimeMinutesMeta,
        screenTimeMinutes.isAcceptableOrUnknown(
          data['screen_time_minutes']!,
          _screenTimeMinutesMeta,
        ),
      );
    }
    if (data.containsKey('productive_time_minutes')) {
      context.handle(
        _productiveTimeMinutesMeta,
        productiveTimeMinutes.isAcceptableOrUnknown(
          data['productive_time_minutes']!,
          _productiveTimeMinutesMeta,
        ),
      );
    }
    if (data.containsKey('distracted_time_minutes')) {
      context.handle(
        _distractedTimeMinutesMeta,
        distractedTimeMinutes.isAcceptableOrUnknown(
          data['distracted_time_minutes']!,
          _distractedTimeMinutesMeta,
        ),
      );
    }
    if (data.containsKey('tasks_completed')) {
      context.handle(
        _tasksCompletedMeta,
        tasksCompleted.isAcceptableOrUnknown(
          data['tasks_completed']!,
          _tasksCompletedMeta,
        ),
      );
    }
    if (data.containsKey('weekly_reflection_generated')) {
      context.handle(
        _weeklyReflectionGeneratedMeta,
        weeklyReflectionGenerated.isAcceptableOrUnknown(
          data['weekly_reflection_generated']!,
          _weeklyReflectionGeneratedMeta,
        ),
      );
    }
    if (data.containsKey('weekly_reflection')) {
      context.handle(
        _weeklyReflectionMeta,
        weeklyReflection.isAcceptableOrUnknown(
          data['weekly_reflection']!,
          _weeklyReflectionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JournalEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      sleepRating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sleep_rating'],
      ),
      energyRating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}energy_rating'],
      ),
      focusRating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}focus_rating'],
      ),
      moodRating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mood_rating'],
      ),
      reflection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reflection'],
      ),
      moodNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mood_note'],
      ),
      dailyIntention: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}daily_intention'],
      ),
      endOfDayNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_of_day_note'],
      ),
      screenTimeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}screen_time_minutes'],
      ),
      productiveTimeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}productive_time_minutes'],
      ),
      distractedTimeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}distracted_time_minutes'],
      ),
      tasksCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tasks_completed'],
      )!,
      weeklyReflectionGenerated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}weekly_reflection_generated'],
      )!,
      weeklyReflection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weekly_reflection'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $JournalEntriesTable createAlias(String alias) {
    return $JournalEntriesTable(attachedDatabase, alias);
  }
}

class JournalEntry extends DataClass implements Insertable<JournalEntry> {
  /// Entry ID (UUID v4).
  final String id;

  /// Date of the entry.
  final DateTime date;

  /// Sleep quality rating (1-5).
  final int? sleepRating;

  /// Energy level rating (1-5).
  final int? energyRating;

  /// Focus level rating (1-5).
  final int? focusRating;

  /// Mood rating (1-5).
  final int? moodRating;

  /// Free-form daily reflection text.
  final String? reflection;

  /// One-word or one-sentence mood description.
  final String? moodNote;

  /// Intention set for the day.
  final String? dailyIntention;

  /// End-of-day "what made today harder" answer.
  final String? endOfDayNote;

  /// Screen time total in minutes.
  final int? screenTimeMinutes;

  /// Productive time in minutes.
  final int? productiveTimeMinutes;

  /// Distracted time in minutes.
  final int? distractedTimeMinutes;

  /// Tasks completed count for the day.
  final int tasksCompleted;

  /// Whether weekly reflection was generated.
  final bool weeklyReflectionGenerated;

  /// Weekly reflection text (only for Sunday entries).
  final String? weeklyReflection;

  /// When the entry was created.
  final DateTime createdAt;
  const JournalEntry({
    required this.id,
    required this.date,
    this.sleepRating,
    this.energyRating,
    this.focusRating,
    this.moodRating,
    this.reflection,
    this.moodNote,
    this.dailyIntention,
    this.endOfDayNote,
    this.screenTimeMinutes,
    this.productiveTimeMinutes,
    this.distractedTimeMinutes,
    required this.tasksCompleted,
    required this.weeklyReflectionGenerated,
    this.weeklyReflection,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || sleepRating != null) {
      map['sleep_rating'] = Variable<int>(sleepRating);
    }
    if (!nullToAbsent || energyRating != null) {
      map['energy_rating'] = Variable<int>(energyRating);
    }
    if (!nullToAbsent || focusRating != null) {
      map['focus_rating'] = Variable<int>(focusRating);
    }
    if (!nullToAbsent || moodRating != null) {
      map['mood_rating'] = Variable<int>(moodRating);
    }
    if (!nullToAbsent || reflection != null) {
      map['reflection'] = Variable<String>(reflection);
    }
    if (!nullToAbsent || moodNote != null) {
      map['mood_note'] = Variable<String>(moodNote);
    }
    if (!nullToAbsent || dailyIntention != null) {
      map['daily_intention'] = Variable<String>(dailyIntention);
    }
    if (!nullToAbsent || endOfDayNote != null) {
      map['end_of_day_note'] = Variable<String>(endOfDayNote);
    }
    if (!nullToAbsent || screenTimeMinutes != null) {
      map['screen_time_minutes'] = Variable<int>(screenTimeMinutes);
    }
    if (!nullToAbsent || productiveTimeMinutes != null) {
      map['productive_time_minutes'] = Variable<int>(productiveTimeMinutes);
    }
    if (!nullToAbsent || distractedTimeMinutes != null) {
      map['distracted_time_minutes'] = Variable<int>(distractedTimeMinutes);
    }
    map['tasks_completed'] = Variable<int>(tasksCompleted);
    map['weekly_reflection_generated'] = Variable<bool>(
      weeklyReflectionGenerated,
    );
    if (!nullToAbsent || weeklyReflection != null) {
      map['weekly_reflection'] = Variable<String>(weeklyReflection);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  JournalEntriesCompanion toCompanion(bool nullToAbsent) {
    return JournalEntriesCompanion(
      id: Value(id),
      date: Value(date),
      sleepRating: sleepRating == null && nullToAbsent
          ? const Value.absent()
          : Value(sleepRating),
      energyRating: energyRating == null && nullToAbsent
          ? const Value.absent()
          : Value(energyRating),
      focusRating: focusRating == null && nullToAbsent
          ? const Value.absent()
          : Value(focusRating),
      moodRating: moodRating == null && nullToAbsent
          ? const Value.absent()
          : Value(moodRating),
      reflection: reflection == null && nullToAbsent
          ? const Value.absent()
          : Value(reflection),
      moodNote: moodNote == null && nullToAbsent
          ? const Value.absent()
          : Value(moodNote),
      dailyIntention: dailyIntention == null && nullToAbsent
          ? const Value.absent()
          : Value(dailyIntention),
      endOfDayNote: endOfDayNote == null && nullToAbsent
          ? const Value.absent()
          : Value(endOfDayNote),
      screenTimeMinutes: screenTimeMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(screenTimeMinutes),
      productiveTimeMinutes: productiveTimeMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(productiveTimeMinutes),
      distractedTimeMinutes: distractedTimeMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(distractedTimeMinutes),
      tasksCompleted: Value(tasksCompleted),
      weeklyReflectionGenerated: Value(weeklyReflectionGenerated),
      weeklyReflection: weeklyReflection == null && nullToAbsent
          ? const Value.absent()
          : Value(weeklyReflection),
      createdAt: Value(createdAt),
    );
  }

  factory JournalEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalEntry(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      sleepRating: serializer.fromJson<int?>(json['sleepRating']),
      energyRating: serializer.fromJson<int?>(json['energyRating']),
      focusRating: serializer.fromJson<int?>(json['focusRating']),
      moodRating: serializer.fromJson<int?>(json['moodRating']),
      reflection: serializer.fromJson<String?>(json['reflection']),
      moodNote: serializer.fromJson<String?>(json['moodNote']),
      dailyIntention: serializer.fromJson<String?>(json['dailyIntention']),
      endOfDayNote: serializer.fromJson<String?>(json['endOfDayNote']),
      screenTimeMinutes: serializer.fromJson<int?>(json['screenTimeMinutes']),
      productiveTimeMinutes: serializer.fromJson<int?>(
        json['productiveTimeMinutes'],
      ),
      distractedTimeMinutes: serializer.fromJson<int?>(
        json['distractedTimeMinutes'],
      ),
      tasksCompleted: serializer.fromJson<int>(json['tasksCompleted']),
      weeklyReflectionGenerated: serializer.fromJson<bool>(
        json['weeklyReflectionGenerated'],
      ),
      weeklyReflection: serializer.fromJson<String?>(json['weeklyReflection']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<DateTime>(date),
      'sleepRating': serializer.toJson<int?>(sleepRating),
      'energyRating': serializer.toJson<int?>(energyRating),
      'focusRating': serializer.toJson<int?>(focusRating),
      'moodRating': serializer.toJson<int?>(moodRating),
      'reflection': serializer.toJson<String?>(reflection),
      'moodNote': serializer.toJson<String?>(moodNote),
      'dailyIntention': serializer.toJson<String?>(dailyIntention),
      'endOfDayNote': serializer.toJson<String?>(endOfDayNote),
      'screenTimeMinutes': serializer.toJson<int?>(screenTimeMinutes),
      'productiveTimeMinutes': serializer.toJson<int?>(productiveTimeMinutes),
      'distractedTimeMinutes': serializer.toJson<int?>(distractedTimeMinutes),
      'tasksCompleted': serializer.toJson<int>(tasksCompleted),
      'weeklyReflectionGenerated': serializer.toJson<bool>(
        weeklyReflectionGenerated,
      ),
      'weeklyReflection': serializer.toJson<String?>(weeklyReflection),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  JournalEntry copyWith({
    String? id,
    DateTime? date,
    Value<int?> sleepRating = const Value.absent(),
    Value<int?> energyRating = const Value.absent(),
    Value<int?> focusRating = const Value.absent(),
    Value<int?> moodRating = const Value.absent(),
    Value<String?> reflection = const Value.absent(),
    Value<String?> moodNote = const Value.absent(),
    Value<String?> dailyIntention = const Value.absent(),
    Value<String?> endOfDayNote = const Value.absent(),
    Value<int?> screenTimeMinutes = const Value.absent(),
    Value<int?> productiveTimeMinutes = const Value.absent(),
    Value<int?> distractedTimeMinutes = const Value.absent(),
    int? tasksCompleted,
    bool? weeklyReflectionGenerated,
    Value<String?> weeklyReflection = const Value.absent(),
    DateTime? createdAt,
  }) => JournalEntry(
    id: id ?? this.id,
    date: date ?? this.date,
    sleepRating: sleepRating.present ? sleepRating.value : this.sleepRating,
    energyRating: energyRating.present ? energyRating.value : this.energyRating,
    focusRating: focusRating.present ? focusRating.value : this.focusRating,
    moodRating: moodRating.present ? moodRating.value : this.moodRating,
    reflection: reflection.present ? reflection.value : this.reflection,
    moodNote: moodNote.present ? moodNote.value : this.moodNote,
    dailyIntention: dailyIntention.present
        ? dailyIntention.value
        : this.dailyIntention,
    endOfDayNote: endOfDayNote.present ? endOfDayNote.value : this.endOfDayNote,
    screenTimeMinutes: screenTimeMinutes.present
        ? screenTimeMinutes.value
        : this.screenTimeMinutes,
    productiveTimeMinutes: productiveTimeMinutes.present
        ? productiveTimeMinutes.value
        : this.productiveTimeMinutes,
    distractedTimeMinutes: distractedTimeMinutes.present
        ? distractedTimeMinutes.value
        : this.distractedTimeMinutes,
    tasksCompleted: tasksCompleted ?? this.tasksCompleted,
    weeklyReflectionGenerated:
        weeklyReflectionGenerated ?? this.weeklyReflectionGenerated,
    weeklyReflection: weeklyReflection.present
        ? weeklyReflection.value
        : this.weeklyReflection,
    createdAt: createdAt ?? this.createdAt,
  );
  JournalEntry copyWithCompanion(JournalEntriesCompanion data) {
    return JournalEntry(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      sleepRating: data.sleepRating.present
          ? data.sleepRating.value
          : this.sleepRating,
      energyRating: data.energyRating.present
          ? data.energyRating.value
          : this.energyRating,
      focusRating: data.focusRating.present
          ? data.focusRating.value
          : this.focusRating,
      moodRating: data.moodRating.present
          ? data.moodRating.value
          : this.moodRating,
      reflection: data.reflection.present
          ? data.reflection.value
          : this.reflection,
      moodNote: data.moodNote.present ? data.moodNote.value : this.moodNote,
      dailyIntention: data.dailyIntention.present
          ? data.dailyIntention.value
          : this.dailyIntention,
      endOfDayNote: data.endOfDayNote.present
          ? data.endOfDayNote.value
          : this.endOfDayNote,
      screenTimeMinutes: data.screenTimeMinutes.present
          ? data.screenTimeMinutes.value
          : this.screenTimeMinutes,
      productiveTimeMinutes: data.productiveTimeMinutes.present
          ? data.productiveTimeMinutes.value
          : this.productiveTimeMinutes,
      distractedTimeMinutes: data.distractedTimeMinutes.present
          ? data.distractedTimeMinutes.value
          : this.distractedTimeMinutes,
      tasksCompleted: data.tasksCompleted.present
          ? data.tasksCompleted.value
          : this.tasksCompleted,
      weeklyReflectionGenerated: data.weeklyReflectionGenerated.present
          ? data.weeklyReflectionGenerated.value
          : this.weeklyReflectionGenerated,
      weeklyReflection: data.weeklyReflection.present
          ? data.weeklyReflection.value
          : this.weeklyReflection,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntry(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('sleepRating: $sleepRating, ')
          ..write('energyRating: $energyRating, ')
          ..write('focusRating: $focusRating, ')
          ..write('moodRating: $moodRating, ')
          ..write('reflection: $reflection, ')
          ..write('moodNote: $moodNote, ')
          ..write('dailyIntention: $dailyIntention, ')
          ..write('endOfDayNote: $endOfDayNote, ')
          ..write('screenTimeMinutes: $screenTimeMinutes, ')
          ..write('productiveTimeMinutes: $productiveTimeMinutes, ')
          ..write('distractedTimeMinutes: $distractedTimeMinutes, ')
          ..write('tasksCompleted: $tasksCompleted, ')
          ..write('weeklyReflectionGenerated: $weeklyReflectionGenerated, ')
          ..write('weeklyReflection: $weeklyReflection, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    sleepRating,
    energyRating,
    focusRating,
    moodRating,
    reflection,
    moodNote,
    dailyIntention,
    endOfDayNote,
    screenTimeMinutes,
    productiveTimeMinutes,
    distractedTimeMinutes,
    tasksCompleted,
    weeklyReflectionGenerated,
    weeklyReflection,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalEntry &&
          other.id == this.id &&
          other.date == this.date &&
          other.sleepRating == this.sleepRating &&
          other.energyRating == this.energyRating &&
          other.focusRating == this.focusRating &&
          other.moodRating == this.moodRating &&
          other.reflection == this.reflection &&
          other.moodNote == this.moodNote &&
          other.dailyIntention == this.dailyIntention &&
          other.endOfDayNote == this.endOfDayNote &&
          other.screenTimeMinutes == this.screenTimeMinutes &&
          other.productiveTimeMinutes == this.productiveTimeMinutes &&
          other.distractedTimeMinutes == this.distractedTimeMinutes &&
          other.tasksCompleted == this.tasksCompleted &&
          other.weeklyReflectionGenerated == this.weeklyReflectionGenerated &&
          other.weeklyReflection == this.weeklyReflection &&
          other.createdAt == this.createdAt);
}

class JournalEntriesCompanion extends UpdateCompanion<JournalEntry> {
  final Value<String> id;
  final Value<DateTime> date;
  final Value<int?> sleepRating;
  final Value<int?> energyRating;
  final Value<int?> focusRating;
  final Value<int?> moodRating;
  final Value<String?> reflection;
  final Value<String?> moodNote;
  final Value<String?> dailyIntention;
  final Value<String?> endOfDayNote;
  final Value<int?> screenTimeMinutes;
  final Value<int?> productiveTimeMinutes;
  final Value<int?> distractedTimeMinutes;
  final Value<int> tasksCompleted;
  final Value<bool> weeklyReflectionGenerated;
  final Value<String?> weeklyReflection;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const JournalEntriesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.sleepRating = const Value.absent(),
    this.energyRating = const Value.absent(),
    this.focusRating = const Value.absent(),
    this.moodRating = const Value.absent(),
    this.reflection = const Value.absent(),
    this.moodNote = const Value.absent(),
    this.dailyIntention = const Value.absent(),
    this.endOfDayNote = const Value.absent(),
    this.screenTimeMinutes = const Value.absent(),
    this.productiveTimeMinutes = const Value.absent(),
    this.distractedTimeMinutes = const Value.absent(),
    this.tasksCompleted = const Value.absent(),
    this.weeklyReflectionGenerated = const Value.absent(),
    this.weeklyReflection = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JournalEntriesCompanion.insert({
    required String id,
    required DateTime date,
    this.sleepRating = const Value.absent(),
    this.energyRating = const Value.absent(),
    this.focusRating = const Value.absent(),
    this.moodRating = const Value.absent(),
    this.reflection = const Value.absent(),
    this.moodNote = const Value.absent(),
    this.dailyIntention = const Value.absent(),
    this.endOfDayNote = const Value.absent(),
    this.screenTimeMinutes = const Value.absent(),
    this.productiveTimeMinutes = const Value.absent(),
    this.distractedTimeMinutes = const Value.absent(),
    this.tasksCompleted = const Value.absent(),
    this.weeklyReflectionGenerated = const Value.absent(),
    this.weeklyReflection = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       date = Value(date);
  static Insertable<JournalEntry> custom({
    Expression<String>? id,
    Expression<DateTime>? date,
    Expression<int>? sleepRating,
    Expression<int>? energyRating,
    Expression<int>? focusRating,
    Expression<int>? moodRating,
    Expression<String>? reflection,
    Expression<String>? moodNote,
    Expression<String>? dailyIntention,
    Expression<String>? endOfDayNote,
    Expression<int>? screenTimeMinutes,
    Expression<int>? productiveTimeMinutes,
    Expression<int>? distractedTimeMinutes,
    Expression<int>? tasksCompleted,
    Expression<bool>? weeklyReflectionGenerated,
    Expression<String>? weeklyReflection,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (sleepRating != null) 'sleep_rating': sleepRating,
      if (energyRating != null) 'energy_rating': energyRating,
      if (focusRating != null) 'focus_rating': focusRating,
      if (moodRating != null) 'mood_rating': moodRating,
      if (reflection != null) 'reflection': reflection,
      if (moodNote != null) 'mood_note': moodNote,
      if (dailyIntention != null) 'daily_intention': dailyIntention,
      if (endOfDayNote != null) 'end_of_day_note': endOfDayNote,
      if (screenTimeMinutes != null) 'screen_time_minutes': screenTimeMinutes,
      if (productiveTimeMinutes != null)
        'productive_time_minutes': productiveTimeMinutes,
      if (distractedTimeMinutes != null)
        'distracted_time_minutes': distractedTimeMinutes,
      if (tasksCompleted != null) 'tasks_completed': tasksCompleted,
      if (weeklyReflectionGenerated != null)
        'weekly_reflection_generated': weeklyReflectionGenerated,
      if (weeklyReflection != null) 'weekly_reflection': weeklyReflection,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JournalEntriesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? date,
    Value<int?>? sleepRating,
    Value<int?>? energyRating,
    Value<int?>? focusRating,
    Value<int?>? moodRating,
    Value<String?>? reflection,
    Value<String?>? moodNote,
    Value<String?>? dailyIntention,
    Value<String?>? endOfDayNote,
    Value<int?>? screenTimeMinutes,
    Value<int?>? productiveTimeMinutes,
    Value<int?>? distractedTimeMinutes,
    Value<int>? tasksCompleted,
    Value<bool>? weeklyReflectionGenerated,
    Value<String?>? weeklyReflection,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return JournalEntriesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      sleepRating: sleepRating ?? this.sleepRating,
      energyRating: energyRating ?? this.energyRating,
      focusRating: focusRating ?? this.focusRating,
      moodRating: moodRating ?? this.moodRating,
      reflection: reflection ?? this.reflection,
      moodNote: moodNote ?? this.moodNote,
      dailyIntention: dailyIntention ?? this.dailyIntention,
      endOfDayNote: endOfDayNote ?? this.endOfDayNote,
      screenTimeMinutes: screenTimeMinutes ?? this.screenTimeMinutes,
      productiveTimeMinutes:
          productiveTimeMinutes ?? this.productiveTimeMinutes,
      distractedTimeMinutes:
          distractedTimeMinutes ?? this.distractedTimeMinutes,
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
      weeklyReflectionGenerated:
          weeklyReflectionGenerated ?? this.weeklyReflectionGenerated,
      weeklyReflection: weeklyReflection ?? this.weeklyReflection,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (sleepRating.present) {
      map['sleep_rating'] = Variable<int>(sleepRating.value);
    }
    if (energyRating.present) {
      map['energy_rating'] = Variable<int>(energyRating.value);
    }
    if (focusRating.present) {
      map['focus_rating'] = Variable<int>(focusRating.value);
    }
    if (moodRating.present) {
      map['mood_rating'] = Variable<int>(moodRating.value);
    }
    if (reflection.present) {
      map['reflection'] = Variable<String>(reflection.value);
    }
    if (moodNote.present) {
      map['mood_note'] = Variable<String>(moodNote.value);
    }
    if (dailyIntention.present) {
      map['daily_intention'] = Variable<String>(dailyIntention.value);
    }
    if (endOfDayNote.present) {
      map['end_of_day_note'] = Variable<String>(endOfDayNote.value);
    }
    if (screenTimeMinutes.present) {
      map['screen_time_minutes'] = Variable<int>(screenTimeMinutes.value);
    }
    if (productiveTimeMinutes.present) {
      map['productive_time_minutes'] = Variable<int>(
        productiveTimeMinutes.value,
      );
    }
    if (distractedTimeMinutes.present) {
      map['distracted_time_minutes'] = Variable<int>(
        distractedTimeMinutes.value,
      );
    }
    if (tasksCompleted.present) {
      map['tasks_completed'] = Variable<int>(tasksCompleted.value);
    }
    if (weeklyReflectionGenerated.present) {
      map['weekly_reflection_generated'] = Variable<bool>(
        weeklyReflectionGenerated.value,
      );
    }
    if (weeklyReflection.present) {
      map['weekly_reflection'] = Variable<String>(weeklyReflection.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntriesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('sleepRating: $sleepRating, ')
          ..write('energyRating: $energyRating, ')
          ..write('focusRating: $focusRating, ')
          ..write('moodRating: $moodRating, ')
          ..write('reflection: $reflection, ')
          ..write('moodNote: $moodNote, ')
          ..write('dailyIntention: $dailyIntention, ')
          ..write('endOfDayNote: $endOfDayNote, ')
          ..write('screenTimeMinutes: $screenTimeMinutes, ')
          ..write('productiveTimeMinutes: $productiveTimeMinutes, ')
          ..write('distractedTimeMinutes: $distractedTimeMinutes, ')
          ..write('tasksCompleted: $tasksCompleted, ')
          ..write('weeklyReflectionGenerated: $weeklyReflectionGenerated, ')
          ..write('weeklyReflection: $weeklyReflection, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProgressDimensionsTable extends ProgressDimensions
    with TableInfo<$ProgressDimensionsTable, ProgressDimension> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgressDimensionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weeklyTargetMeta = const VerificationMeta(
    'weeklyTarget',
  );
  @override
  late final GeneratedColumn<double> weeklyTarget = GeneratedColumn<double>(
    'weekly_target',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('count'),
  );
  static const VerificationMeta _isAutomaticMeta = const VerificationMeta(
    'isAutomatic',
  );
  @override
  late final GeneratedColumn<bool> isAutomatic = GeneratedColumn<bool>(
    'is_automatic',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_automatic" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#5B8DEF'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.now()),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    weeklyTarget,
    unit,
    isAutomatic,
    colorHex,
    sortOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'progress_dimensions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProgressDimension> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('weekly_target')) {
      context.handle(
        _weeklyTargetMeta,
        weeklyTarget.isAcceptableOrUnknown(
          data['weekly_target']!,
          _weeklyTargetMeta,
        ),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('is_automatic')) {
      context.handle(
        _isAutomaticMeta,
        isAutomatic.isAcceptableOrUnknown(
          data['is_automatic']!,
          _isAutomaticMeta,
        ),
      );
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProgressDimension map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgressDimension(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      weeklyTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weekly_target'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      isAutomatic: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_automatic'],
      )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ProgressDimensionsTable createAlias(String alias) {
    return $ProgressDimensionsTable(attachedDatabase, alias);
  }
}

class ProgressDimension extends DataClass
    implements Insertable<ProgressDimension> {
  /// Dimension ID (UUID v4).
  final String id;

  /// Name of the dimension (e.g., "Study Hours", "Exercise", "Coding").
  final String name;

  /// Target value per week.
  final double weeklyTarget;

  /// Unit of measurement (e.g., "hours", "sessions", "pages").
  final String unit;

  /// Whether this is an automatic (computed) dimension.
  final bool isAutomatic;

  /// Color hex for the dimension.
  final String colorHex;

  /// Order in the UI.
  final int sortOrder;

  /// When created.
  final DateTime createdAt;
  const ProgressDimension({
    required this.id,
    required this.name,
    required this.weeklyTarget,
    required this.unit,
    required this.isAutomatic,
    required this.colorHex,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['weekly_target'] = Variable<double>(weeklyTarget);
    map['unit'] = Variable<String>(unit);
    map['is_automatic'] = Variable<bool>(isAutomatic);
    map['color_hex'] = Variable<String>(colorHex);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ProgressDimensionsCompanion toCompanion(bool nullToAbsent) {
    return ProgressDimensionsCompanion(
      id: Value(id),
      name: Value(name),
      weeklyTarget: Value(weeklyTarget),
      unit: Value(unit),
      isAutomatic: Value(isAutomatic),
      colorHex: Value(colorHex),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory ProgressDimension.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgressDimension(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      weeklyTarget: serializer.fromJson<double>(json['weeklyTarget']),
      unit: serializer.fromJson<String>(json['unit']),
      isAutomatic: serializer.fromJson<bool>(json['isAutomatic']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'weeklyTarget': serializer.toJson<double>(weeklyTarget),
      'unit': serializer.toJson<String>(unit),
      'isAutomatic': serializer.toJson<bool>(isAutomatic),
      'colorHex': serializer.toJson<String>(colorHex),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ProgressDimension copyWith({
    String? id,
    String? name,
    double? weeklyTarget,
    String? unit,
    bool? isAutomatic,
    String? colorHex,
    int? sortOrder,
    DateTime? createdAt,
  }) => ProgressDimension(
    id: id ?? this.id,
    name: name ?? this.name,
    weeklyTarget: weeklyTarget ?? this.weeklyTarget,
    unit: unit ?? this.unit,
    isAutomatic: isAutomatic ?? this.isAutomatic,
    colorHex: colorHex ?? this.colorHex,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  ProgressDimension copyWithCompanion(ProgressDimensionsCompanion data) {
    return ProgressDimension(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      weeklyTarget: data.weeklyTarget.present
          ? data.weeklyTarget.value
          : this.weeklyTarget,
      unit: data.unit.present ? data.unit.value : this.unit,
      isAutomatic: data.isAutomatic.present
          ? data.isAutomatic.value
          : this.isAutomatic,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgressDimension(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('weeklyTarget: $weeklyTarget, ')
          ..write('unit: $unit, ')
          ..write('isAutomatic: $isAutomatic, ')
          ..write('colorHex: $colorHex, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    weeklyTarget,
    unit,
    isAutomatic,
    colorHex,
    sortOrder,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgressDimension &&
          other.id == this.id &&
          other.name == this.name &&
          other.weeklyTarget == this.weeklyTarget &&
          other.unit == this.unit &&
          other.isAutomatic == this.isAutomatic &&
          other.colorHex == this.colorHex &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class ProgressDimensionsCompanion extends UpdateCompanion<ProgressDimension> {
  final Value<String> id;
  final Value<String> name;
  final Value<double> weeklyTarget;
  final Value<String> unit;
  final Value<bool> isAutomatic;
  final Value<String> colorHex;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ProgressDimensionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.weeklyTarget = const Value.absent(),
    this.unit = const Value.absent(),
    this.isAutomatic = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProgressDimensionsCompanion.insert({
    required String id,
    required String name,
    this.weeklyTarget = const Value.absent(),
    this.unit = const Value.absent(),
    this.isAutomatic = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<ProgressDimension> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? weeklyTarget,
    Expression<String>? unit,
    Expression<bool>? isAutomatic,
    Expression<String>? colorHex,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (weeklyTarget != null) 'weekly_target': weeklyTarget,
      if (unit != null) 'unit': unit,
      if (isAutomatic != null) 'is_automatic': isAutomatic,
      if (colorHex != null) 'color_hex': colorHex,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProgressDimensionsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<double>? weeklyTarget,
    Value<String>? unit,
    Value<bool>? isAutomatic,
    Value<String>? colorHex,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ProgressDimensionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      weeklyTarget: weeklyTarget ?? this.weeklyTarget,
      unit: unit ?? this.unit,
      isAutomatic: isAutomatic ?? this.isAutomatic,
      colorHex: colorHex ?? this.colorHex,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (weeklyTarget.present) {
      map['weekly_target'] = Variable<double>(weeklyTarget.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (isAutomatic.present) {
      map['is_automatic'] = Variable<bool>(isAutomatic.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgressDimensionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('weeklyTarget: $weeklyTarget, ')
          ..write('unit: $unit, ')
          ..write('isAutomatic: $isAutomatic, ')
          ..write('colorHex: $colorHex, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProgressValuesTable extends ProgressValues
    with TableInfo<$ProgressValuesTable, ProgressValue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgressValuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dimensionIdMeta = const VerificationMeta(
    'dimensionId',
  );
  @override
  late final GeneratedColumn<String> dimensionId = GeneratedColumn<String>(
    'dimension_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, dimensionId, date, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'progress_values';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProgressValue> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('dimension_id')) {
      context.handle(
        _dimensionIdMeta,
        dimensionId.isAcceptableOrUnknown(
          data['dimension_id']!,
          _dimensionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dimensionIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProgressValue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgressValue(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      dimensionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dimension_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $ProgressValuesTable createAlias(String alias) {
    return $ProgressValuesTable(attachedDatabase, alias);
  }
}

class ProgressValue extends DataClass implements Insertable<ProgressValue> {
  /// Value ID (UUID v4).
  final String id;

  /// Reference to ProgressDimensions.
  final String dimensionId;

  /// Date of the value.
  final DateTime date;

  /// Numeric value for that day.
  final double value;
  const ProgressValue({
    required this.id,
    required this.dimensionId,
    required this.date,
    required this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['dimension_id'] = Variable<String>(dimensionId);
    map['date'] = Variable<DateTime>(date);
    map['value'] = Variable<double>(value);
    return map;
  }

  ProgressValuesCompanion toCompanion(bool nullToAbsent) {
    return ProgressValuesCompanion(
      id: Value(id),
      dimensionId: Value(dimensionId),
      date: Value(date),
      value: Value(value),
    );
  }

  factory ProgressValue.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgressValue(
      id: serializer.fromJson<String>(json['id']),
      dimensionId: serializer.fromJson<String>(json['dimensionId']),
      date: serializer.fromJson<DateTime>(json['date']),
      value: serializer.fromJson<double>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dimensionId': serializer.toJson<String>(dimensionId),
      'date': serializer.toJson<DateTime>(date),
      'value': serializer.toJson<double>(value),
    };
  }

  ProgressValue copyWith({
    String? id,
    String? dimensionId,
    DateTime? date,
    double? value,
  }) => ProgressValue(
    id: id ?? this.id,
    dimensionId: dimensionId ?? this.dimensionId,
    date: date ?? this.date,
    value: value ?? this.value,
  );
  ProgressValue copyWithCompanion(ProgressValuesCompanion data) {
    return ProgressValue(
      id: data.id.present ? data.id.value : this.id,
      dimensionId: data.dimensionId.present
          ? data.dimensionId.value
          : this.dimensionId,
      date: data.date.present ? data.date.value : this.date,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgressValue(')
          ..write('id: $id, ')
          ..write('dimensionId: $dimensionId, ')
          ..write('date: $date, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dimensionId, date, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgressValue &&
          other.id == this.id &&
          other.dimensionId == this.dimensionId &&
          other.date == this.date &&
          other.value == this.value);
}

class ProgressValuesCompanion extends UpdateCompanion<ProgressValue> {
  final Value<String> id;
  final Value<String> dimensionId;
  final Value<DateTime> date;
  final Value<double> value;
  final Value<int> rowid;
  const ProgressValuesCompanion({
    this.id = const Value.absent(),
    this.dimensionId = const Value.absent(),
    this.date = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProgressValuesCompanion.insert({
    required String id,
    required String dimensionId,
    required DateTime date,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       dimensionId = Value(dimensionId),
       date = Value(date);
  static Insertable<ProgressValue> custom({
    Expression<String>? id,
    Expression<String>? dimensionId,
    Expression<DateTime>? date,
    Expression<double>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dimensionId != null) 'dimension_id': dimensionId,
      if (date != null) 'date': date,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProgressValuesCompanion copyWith({
    Value<String>? id,
    Value<String>? dimensionId,
    Value<DateTime>? date,
    Value<double>? value,
    Value<int>? rowid,
  }) {
    return ProgressValuesCompanion(
      id: id ?? this.id,
      dimensionId: dimensionId ?? this.dimensionId,
      date: date ?? this.date,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dimensionId.present) {
      map['dimension_id'] = Variable<String>(dimensionId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgressValuesCompanion(')
          ..write('id: $id, ')
          ..write('dimensionId: $dimensionId, ')
          ..write('date: $date, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userNameMeta = const VerificationMeta(
    'userName',
  );
  @override
  late final GeneratedColumn<String> userName = GeneratedColumn<String>(
    'user_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _independenceDateMeta = const VerificationMeta(
    'independenceDate',
  );
  @override
  late final GeneratedColumn<DateTime> independenceDate =
      GeneratedColumn<DateTime>(
        'independence_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _independenceLabelMeta = const VerificationMeta(
    'independenceLabel',
  );
  @override
  late final GeneratedColumn<String> independenceLabel =
      GeneratedColumn<String>(
        'independence_label',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _distractionLimitMinutesMeta =
      const VerificationMeta('distractionLimitMinutes');
  @override
  late final GeneratedColumn<int> distractionLimitMinutes =
      GeneratedColumn<int>(
        'distraction_limit_minutes',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(120),
      );
  static const VerificationMeta _screenTimeResetHourMeta =
      const VerificationMeta('screenTimeResetHour');
  @override
  late final GeneratedColumn<int> screenTimeResetHour = GeneratedColumn<int>(
    'screen_time_reset_hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _todoistApiTokenMeta = const VerificationMeta(
    'todoistApiToken',
  );
  @override
  late final GeneratedColumn<String> todoistApiToken = GeneratedColumn<String>(
    'todoist_api_token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _geminiApiKeyMeta = const VerificationMeta(
    'geminiApiKey',
  );
  @override
  late final GeneratedColumn<String> geminiApiKey = GeneratedColumn<String>(
    'gemini_api_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weatherCityMeta = const VerificationMeta(
    'weatherCity',
  );
  @override
  late final GeneratedColumn<String> weatherCity = GeneratedColumn<String>(
    'weather_city',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weatherLatMeta = const VerificationMeta(
    'weatherLat',
  );
  @override
  late final GeneratedColumn<double> weatherLat = GeneratedColumn<double>(
    'weather_lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weatherLonMeta = const VerificationMeta(
    'weatherLon',
  );
  @override
  late final GeneratedColumn<double> weatherLon = GeneratedColumn<double>(
    'weather_lon',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _newsCategoryMeta = const VerificationMeta(
    'newsCategory',
  );
  @override
  late final GeneratedColumn<String> newsCategory = GeneratedColumn<String>(
    'news_category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('technology'),
  );
  static const VerificationMeta _showPersistentWidgetMeta =
      const VerificationMeta('showPersistentWidget');
  @override
  late final GeneratedColumn<bool> showPersistentWidget = GeneratedColumn<bool>(
    'show_persistent_widget',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_persistent_widget" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _launchOnStartupMeta = const VerificationMeta(
    'launchOnStartup',
  );
  @override
  late final GeneratedColumn<bool> launchOnStartup = GeneratedColumn<bool>(
    'launch_on_startup',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("launch_on_startup" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _whatsappDigestEnabledMeta =
      const VerificationMeta('whatsappDigestEnabled');
  @override
  late final GeneratedColumn<bool> whatsappDigestEnabled =
      GeneratedColumn<bool>(
        'whatsapp_digest_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("whatsapp_digest_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _lastDigestAtMeta = const VerificationMeta(
    'lastDigestAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastDigestAt = GeneratedColumn<DateTime>(
    'last_digest_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _geminiModelMeta = const VerificationMeta(
    'geminiModel',
  );
  @override
  late final GeneratedColumn<String> geminiModel = GeneratedColumn<String>(
    'gemini_model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('gemini-2.0-flash'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userName,
    independenceDate,
    independenceLabel,
    distractionLimitMinutes,
    screenTimeResetHour,
    todoistApiToken,
    geminiApiKey,
    weatherCity,
    weatherLat,
    weatherLon,
    newsCategory,
    showPersistentWidget,
    launchOnStartup,
    whatsappDigestEnabled,
    lastDigestAt,
    geminiModel,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_name')) {
      context.handle(
        _userNameMeta,
        userName.isAcceptableOrUnknown(data['user_name']!, _userNameMeta),
      );
    }
    if (data.containsKey('independence_date')) {
      context.handle(
        _independenceDateMeta,
        independenceDate.isAcceptableOrUnknown(
          data['independence_date']!,
          _independenceDateMeta,
        ),
      );
    }
    if (data.containsKey('independence_label')) {
      context.handle(
        _independenceLabelMeta,
        independenceLabel.isAcceptableOrUnknown(
          data['independence_label']!,
          _independenceLabelMeta,
        ),
      );
    }
    if (data.containsKey('distraction_limit_minutes')) {
      context.handle(
        _distractionLimitMinutesMeta,
        distractionLimitMinutes.isAcceptableOrUnknown(
          data['distraction_limit_minutes']!,
          _distractionLimitMinutesMeta,
        ),
      );
    }
    if (data.containsKey('screen_time_reset_hour')) {
      context.handle(
        _screenTimeResetHourMeta,
        screenTimeResetHour.isAcceptableOrUnknown(
          data['screen_time_reset_hour']!,
          _screenTimeResetHourMeta,
        ),
      );
    }
    if (data.containsKey('todoist_api_token')) {
      context.handle(
        _todoistApiTokenMeta,
        todoistApiToken.isAcceptableOrUnknown(
          data['todoist_api_token']!,
          _todoistApiTokenMeta,
        ),
      );
    }
    if (data.containsKey('gemini_api_key')) {
      context.handle(
        _geminiApiKeyMeta,
        geminiApiKey.isAcceptableOrUnknown(
          data['gemini_api_key']!,
          _geminiApiKeyMeta,
        ),
      );
    }
    if (data.containsKey('weather_city')) {
      context.handle(
        _weatherCityMeta,
        weatherCity.isAcceptableOrUnknown(
          data['weather_city']!,
          _weatherCityMeta,
        ),
      );
    }
    if (data.containsKey('weather_lat')) {
      context.handle(
        _weatherLatMeta,
        weatherLat.isAcceptableOrUnknown(data['weather_lat']!, _weatherLatMeta),
      );
    }
    if (data.containsKey('weather_lon')) {
      context.handle(
        _weatherLonMeta,
        weatherLon.isAcceptableOrUnknown(data['weather_lon']!, _weatherLonMeta),
      );
    }
    if (data.containsKey('news_category')) {
      context.handle(
        _newsCategoryMeta,
        newsCategory.isAcceptableOrUnknown(
          data['news_category']!,
          _newsCategoryMeta,
        ),
      );
    }
    if (data.containsKey('show_persistent_widget')) {
      context.handle(
        _showPersistentWidgetMeta,
        showPersistentWidget.isAcceptableOrUnknown(
          data['show_persistent_widget']!,
          _showPersistentWidgetMeta,
        ),
      );
    }
    if (data.containsKey('launch_on_startup')) {
      context.handle(
        _launchOnStartupMeta,
        launchOnStartup.isAcceptableOrUnknown(
          data['launch_on_startup']!,
          _launchOnStartupMeta,
        ),
      );
    }
    if (data.containsKey('whatsapp_digest_enabled')) {
      context.handle(
        _whatsappDigestEnabledMeta,
        whatsappDigestEnabled.isAcceptableOrUnknown(
          data['whatsapp_digest_enabled']!,
          _whatsappDigestEnabledMeta,
        ),
      );
    }
    if (data.containsKey('last_digest_at')) {
      context.handle(
        _lastDigestAtMeta,
        lastDigestAt.isAcceptableOrUnknown(
          data['last_digest_at']!,
          _lastDigestAtMeta,
        ),
      );
    }
    if (data.containsKey('gemini_model')) {
      context.handle(
        _geminiModelMeta,
        geminiModel.isAcceptableOrUnknown(
          data['gemini_model']!,
          _geminiModelMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_name'],
      ),
      independenceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}independence_date'],
      ),
      independenceLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}independence_label'],
      ),
      distractionLimitMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}distraction_limit_minutes'],
      )!,
      screenTimeResetHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}screen_time_reset_hour'],
      )!,
      todoistApiToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}todoist_api_token'],
      ),
      geminiApiKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gemini_api_key'],
      ),
      weatherCity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weather_city'],
      ),
      weatherLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weather_lat'],
      ),
      weatherLon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weather_lon'],
      ),
      newsCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}news_category'],
      )!,
      showPersistentWidget: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_persistent_widget'],
      )!,
      launchOnStartup: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}launch_on_startup'],
      )!,
      whatsappDigestEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}whatsapp_digest_enabled'],
      )!,
      lastDigestAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_digest_at'],
      ),
      geminiModel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gemini_model'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  /// Single row — always 'anchor_settings'.
  final String id;

  /// User's display name.
  final String? userName;

  /// Independence goal date.
  final DateTime? independenceDate;

  /// What the independence date represents (e.g., "Graduation").
  final String? independenceLabel;

  /// Daily distraction time limit in minutes.
  final int distractionLimitMinutes;

  /// Screen time reset hour (0-23).
  final int screenTimeResetHour;

  /// Todoist API token.
  final String? todoistApiToken;

  /// Gemini API key.
  final String? geminiApiKey;

  /// City for weather.
  final String? weatherCity;

  /// Latitude for weather.
  final double? weatherLat;

  /// Longitude for weather.
  final double? weatherLon;

  /// News category preference.
  final String newsCategory;

  /// Whether to show the persistent widget.
  final bool showPersistentWidget;

  /// Whether app should launch on startup.
  final bool launchOnStartup;

  /// Whether WhatsApp digest is enabled.
  final bool whatsappDigestEnabled;

  /// Last digest generation timestamp.
  final DateTime? lastDigestAt;

  /// Selected Gemini model for AI features.
  final String geminiModel;
  const AppSetting({
    required this.id,
    this.userName,
    this.independenceDate,
    this.independenceLabel,
    required this.distractionLimitMinutes,
    required this.screenTimeResetHour,
    this.todoistApiToken,
    this.geminiApiKey,
    this.weatherCity,
    this.weatherLat,
    this.weatherLon,
    required this.newsCategory,
    required this.showPersistentWidget,
    required this.launchOnStartup,
    required this.whatsappDigestEnabled,
    this.lastDigestAt,
    required this.geminiModel,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || userName != null) {
      map['user_name'] = Variable<String>(userName);
    }
    if (!nullToAbsent || independenceDate != null) {
      map['independence_date'] = Variable<DateTime>(independenceDate);
    }
    if (!nullToAbsent || independenceLabel != null) {
      map['independence_label'] = Variable<String>(independenceLabel);
    }
    map['distraction_limit_minutes'] = Variable<int>(distractionLimitMinutes);
    map['screen_time_reset_hour'] = Variable<int>(screenTimeResetHour);
    if (!nullToAbsent || todoistApiToken != null) {
      map['todoist_api_token'] = Variable<String>(todoistApiToken);
    }
    if (!nullToAbsent || geminiApiKey != null) {
      map['gemini_api_key'] = Variable<String>(geminiApiKey);
    }
    if (!nullToAbsent || weatherCity != null) {
      map['weather_city'] = Variable<String>(weatherCity);
    }
    if (!nullToAbsent || weatherLat != null) {
      map['weather_lat'] = Variable<double>(weatherLat);
    }
    if (!nullToAbsent || weatherLon != null) {
      map['weather_lon'] = Variable<double>(weatherLon);
    }
    map['news_category'] = Variable<String>(newsCategory);
    map['show_persistent_widget'] = Variable<bool>(showPersistentWidget);
    map['launch_on_startup'] = Variable<bool>(launchOnStartup);
    map['whatsapp_digest_enabled'] = Variable<bool>(whatsappDigestEnabled);
    if (!nullToAbsent || lastDigestAt != null) {
      map['last_digest_at'] = Variable<DateTime>(lastDigestAt);
    }
    map['gemini_model'] = Variable<String>(geminiModel);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      userName: userName == null && nullToAbsent
          ? const Value.absent()
          : Value(userName),
      independenceDate: independenceDate == null && nullToAbsent
          ? const Value.absent()
          : Value(independenceDate),
      independenceLabel: independenceLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(independenceLabel),
      distractionLimitMinutes: Value(distractionLimitMinutes),
      screenTimeResetHour: Value(screenTimeResetHour),
      todoistApiToken: todoistApiToken == null && nullToAbsent
          ? const Value.absent()
          : Value(todoistApiToken),
      geminiApiKey: geminiApiKey == null && nullToAbsent
          ? const Value.absent()
          : Value(geminiApiKey),
      weatherCity: weatherCity == null && nullToAbsent
          ? const Value.absent()
          : Value(weatherCity),
      weatherLat: weatherLat == null && nullToAbsent
          ? const Value.absent()
          : Value(weatherLat),
      weatherLon: weatherLon == null && nullToAbsent
          ? const Value.absent()
          : Value(weatherLon),
      newsCategory: Value(newsCategory),
      showPersistentWidget: Value(showPersistentWidget),
      launchOnStartup: Value(launchOnStartup),
      whatsappDigestEnabled: Value(whatsappDigestEnabled),
      lastDigestAt: lastDigestAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastDigestAt),
      geminiModel: Value(geminiModel),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      id: serializer.fromJson<String>(json['id']),
      userName: serializer.fromJson<String?>(json['userName']),
      independenceDate: serializer.fromJson<DateTime?>(
        json['independenceDate'],
      ),
      independenceLabel: serializer.fromJson<String?>(
        json['independenceLabel'],
      ),
      distractionLimitMinutes: serializer.fromJson<int>(
        json['distractionLimitMinutes'],
      ),
      screenTimeResetHour: serializer.fromJson<int>(
        json['screenTimeResetHour'],
      ),
      todoistApiToken: serializer.fromJson<String?>(json['todoistApiToken']),
      geminiApiKey: serializer.fromJson<String?>(json['geminiApiKey']),
      weatherCity: serializer.fromJson<String?>(json['weatherCity']),
      weatherLat: serializer.fromJson<double?>(json['weatherLat']),
      weatherLon: serializer.fromJson<double?>(json['weatherLon']),
      newsCategory: serializer.fromJson<String>(json['newsCategory']),
      showPersistentWidget: serializer.fromJson<bool>(
        json['showPersistentWidget'],
      ),
      launchOnStartup: serializer.fromJson<bool>(json['launchOnStartup']),
      whatsappDigestEnabled: serializer.fromJson<bool>(
        json['whatsappDigestEnabled'],
      ),
      lastDigestAt: serializer.fromJson<DateTime?>(json['lastDigestAt']),
      geminiModel: serializer.fromJson<String>(json['geminiModel']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userName': serializer.toJson<String?>(userName),
      'independenceDate': serializer.toJson<DateTime?>(independenceDate),
      'independenceLabel': serializer.toJson<String?>(independenceLabel),
      'distractionLimitMinutes': serializer.toJson<int>(
        distractionLimitMinutes,
      ),
      'screenTimeResetHour': serializer.toJson<int>(screenTimeResetHour),
      'todoistApiToken': serializer.toJson<String?>(todoistApiToken),
      'geminiApiKey': serializer.toJson<String?>(geminiApiKey),
      'weatherCity': serializer.toJson<String?>(weatherCity),
      'weatherLat': serializer.toJson<double?>(weatherLat),
      'weatherLon': serializer.toJson<double?>(weatherLon),
      'newsCategory': serializer.toJson<String>(newsCategory),
      'showPersistentWidget': serializer.toJson<bool>(showPersistentWidget),
      'launchOnStartup': serializer.toJson<bool>(launchOnStartup),
      'whatsappDigestEnabled': serializer.toJson<bool>(whatsappDigestEnabled),
      'lastDigestAt': serializer.toJson<DateTime?>(lastDigestAt),
      'geminiModel': serializer.toJson<String>(geminiModel),
    };
  }

  AppSetting copyWith({
    String? id,
    Value<String?> userName = const Value.absent(),
    Value<DateTime?> independenceDate = const Value.absent(),
    Value<String?> independenceLabel = const Value.absent(),
    int? distractionLimitMinutes,
    int? screenTimeResetHour,
    Value<String?> todoistApiToken = const Value.absent(),
    Value<String?> geminiApiKey = const Value.absent(),
    Value<String?> weatherCity = const Value.absent(),
    Value<double?> weatherLat = const Value.absent(),
    Value<double?> weatherLon = const Value.absent(),
    String? newsCategory,
    bool? showPersistentWidget,
    bool? launchOnStartup,
    bool? whatsappDigestEnabled,
    Value<DateTime?> lastDigestAt = const Value.absent(),
    String? geminiModel,
  }) => AppSetting(
    id: id ?? this.id,
    userName: userName.present ? userName.value : this.userName,
    independenceDate: independenceDate.present
        ? independenceDate.value
        : this.independenceDate,
    independenceLabel: independenceLabel.present
        ? independenceLabel.value
        : this.independenceLabel,
    distractionLimitMinutes:
        distractionLimitMinutes ?? this.distractionLimitMinutes,
    screenTimeResetHour: screenTimeResetHour ?? this.screenTimeResetHour,
    todoistApiToken: todoistApiToken.present
        ? todoistApiToken.value
        : this.todoistApiToken,
    geminiApiKey: geminiApiKey.present ? geminiApiKey.value : this.geminiApiKey,
    weatherCity: weatherCity.present ? weatherCity.value : this.weatherCity,
    weatherLat: weatherLat.present ? weatherLat.value : this.weatherLat,
    weatherLon: weatherLon.present ? weatherLon.value : this.weatherLon,
    newsCategory: newsCategory ?? this.newsCategory,
    showPersistentWidget: showPersistentWidget ?? this.showPersistentWidget,
    launchOnStartup: launchOnStartup ?? this.launchOnStartup,
    whatsappDigestEnabled: whatsappDigestEnabled ?? this.whatsappDigestEnabled,
    lastDigestAt: lastDigestAt.present ? lastDigestAt.value : this.lastDigestAt,
    geminiModel: geminiModel ?? this.geminiModel,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      id: data.id.present ? data.id.value : this.id,
      userName: data.userName.present ? data.userName.value : this.userName,
      independenceDate: data.independenceDate.present
          ? data.independenceDate.value
          : this.independenceDate,
      independenceLabel: data.independenceLabel.present
          ? data.independenceLabel.value
          : this.independenceLabel,
      distractionLimitMinutes: data.distractionLimitMinutes.present
          ? data.distractionLimitMinutes.value
          : this.distractionLimitMinutes,
      screenTimeResetHour: data.screenTimeResetHour.present
          ? data.screenTimeResetHour.value
          : this.screenTimeResetHour,
      todoistApiToken: data.todoistApiToken.present
          ? data.todoistApiToken.value
          : this.todoistApiToken,
      geminiApiKey: data.geminiApiKey.present
          ? data.geminiApiKey.value
          : this.geminiApiKey,
      weatherCity: data.weatherCity.present
          ? data.weatherCity.value
          : this.weatherCity,
      weatherLat: data.weatherLat.present
          ? data.weatherLat.value
          : this.weatherLat,
      weatherLon: data.weatherLon.present
          ? data.weatherLon.value
          : this.weatherLon,
      newsCategory: data.newsCategory.present
          ? data.newsCategory.value
          : this.newsCategory,
      showPersistentWidget: data.showPersistentWidget.present
          ? data.showPersistentWidget.value
          : this.showPersistentWidget,
      launchOnStartup: data.launchOnStartup.present
          ? data.launchOnStartup.value
          : this.launchOnStartup,
      whatsappDigestEnabled: data.whatsappDigestEnabled.present
          ? data.whatsappDigestEnabled.value
          : this.whatsappDigestEnabled,
      lastDigestAt: data.lastDigestAt.present
          ? data.lastDigestAt.value
          : this.lastDigestAt,
      geminiModel: data.geminiModel.present
          ? data.geminiModel.value
          : this.geminiModel,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('id: $id, ')
          ..write('userName: $userName, ')
          ..write('independenceDate: $independenceDate, ')
          ..write('independenceLabel: $independenceLabel, ')
          ..write('distractionLimitMinutes: $distractionLimitMinutes, ')
          ..write('screenTimeResetHour: $screenTimeResetHour, ')
          ..write('todoistApiToken: $todoistApiToken, ')
          ..write('geminiApiKey: $geminiApiKey, ')
          ..write('weatherCity: $weatherCity, ')
          ..write('weatherLat: $weatherLat, ')
          ..write('weatherLon: $weatherLon, ')
          ..write('newsCategory: $newsCategory, ')
          ..write('showPersistentWidget: $showPersistentWidget, ')
          ..write('launchOnStartup: $launchOnStartup, ')
          ..write('whatsappDigestEnabled: $whatsappDigestEnabled, ')
          ..write('lastDigestAt: $lastDigestAt, ')
          ..write('geminiModel: $geminiModel')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userName,
    independenceDate,
    independenceLabel,
    distractionLimitMinutes,
    screenTimeResetHour,
    todoistApiToken,
    geminiApiKey,
    weatherCity,
    weatherLat,
    weatherLon,
    newsCategory,
    showPersistentWidget,
    launchOnStartup,
    whatsappDigestEnabled,
    lastDigestAt,
    geminiModel,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.id == this.id &&
          other.userName == this.userName &&
          other.independenceDate == this.independenceDate &&
          other.independenceLabel == this.independenceLabel &&
          other.distractionLimitMinutes == this.distractionLimitMinutes &&
          other.screenTimeResetHour == this.screenTimeResetHour &&
          other.todoistApiToken == this.todoistApiToken &&
          other.geminiApiKey == this.geminiApiKey &&
          other.weatherCity == this.weatherCity &&
          other.weatherLat == this.weatherLat &&
          other.weatherLon == this.weatherLon &&
          other.newsCategory == this.newsCategory &&
          other.showPersistentWidget == this.showPersistentWidget &&
          other.launchOnStartup == this.launchOnStartup &&
          other.whatsappDigestEnabled == this.whatsappDigestEnabled &&
          other.lastDigestAt == this.lastDigestAt &&
          other.geminiModel == this.geminiModel);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> id;
  final Value<String?> userName;
  final Value<DateTime?> independenceDate;
  final Value<String?> independenceLabel;
  final Value<int> distractionLimitMinutes;
  final Value<int> screenTimeResetHour;
  final Value<String?> todoistApiToken;
  final Value<String?> geminiApiKey;
  final Value<String?> weatherCity;
  final Value<double?> weatherLat;
  final Value<double?> weatherLon;
  final Value<String> newsCategory;
  final Value<bool> showPersistentWidget;
  final Value<bool> launchOnStartup;
  final Value<bool> whatsappDigestEnabled;
  final Value<DateTime?> lastDigestAt;
  final Value<String> geminiModel;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.userName = const Value.absent(),
    this.independenceDate = const Value.absent(),
    this.independenceLabel = const Value.absent(),
    this.distractionLimitMinutes = const Value.absent(),
    this.screenTimeResetHour = const Value.absent(),
    this.todoistApiToken = const Value.absent(),
    this.geminiApiKey = const Value.absent(),
    this.weatherCity = const Value.absent(),
    this.weatherLat = const Value.absent(),
    this.weatherLon = const Value.absent(),
    this.newsCategory = const Value.absent(),
    this.showPersistentWidget = const Value.absent(),
    this.launchOnStartup = const Value.absent(),
    this.whatsappDigestEnabled = const Value.absent(),
    this.lastDigestAt = const Value.absent(),
    this.geminiModel = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String id,
    this.userName = const Value.absent(),
    this.independenceDate = const Value.absent(),
    this.independenceLabel = const Value.absent(),
    this.distractionLimitMinutes = const Value.absent(),
    this.screenTimeResetHour = const Value.absent(),
    this.todoistApiToken = const Value.absent(),
    this.geminiApiKey = const Value.absent(),
    this.weatherCity = const Value.absent(),
    this.weatherLat = const Value.absent(),
    this.weatherLon = const Value.absent(),
    this.newsCategory = const Value.absent(),
    this.showPersistentWidget = const Value.absent(),
    this.launchOnStartup = const Value.absent(),
    this.whatsappDigestEnabled = const Value.absent(),
    this.lastDigestAt = const Value.absent(),
    this.geminiModel = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<AppSetting> custom({
    Expression<String>? id,
    Expression<String>? userName,
    Expression<DateTime>? independenceDate,
    Expression<String>? independenceLabel,
    Expression<int>? distractionLimitMinutes,
    Expression<int>? screenTimeResetHour,
    Expression<String>? todoistApiToken,
    Expression<String>? geminiApiKey,
    Expression<String>? weatherCity,
    Expression<double>? weatherLat,
    Expression<double>? weatherLon,
    Expression<String>? newsCategory,
    Expression<bool>? showPersistentWidget,
    Expression<bool>? launchOnStartup,
    Expression<bool>? whatsappDigestEnabled,
    Expression<DateTime>? lastDigestAt,
    Expression<String>? geminiModel,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userName != null) 'user_name': userName,
      if (independenceDate != null) 'independence_date': independenceDate,
      if (independenceLabel != null) 'independence_label': independenceLabel,
      if (distractionLimitMinutes != null)
        'distraction_limit_minutes': distractionLimitMinutes,
      if (screenTimeResetHour != null)
        'screen_time_reset_hour': screenTimeResetHour,
      if (todoistApiToken != null) 'todoist_api_token': todoistApiToken,
      if (geminiApiKey != null) 'gemini_api_key': geminiApiKey,
      if (weatherCity != null) 'weather_city': weatherCity,
      if (weatherLat != null) 'weather_lat': weatherLat,
      if (weatherLon != null) 'weather_lon': weatherLon,
      if (newsCategory != null) 'news_category': newsCategory,
      if (showPersistentWidget != null)
        'show_persistent_widget': showPersistentWidget,
      if (launchOnStartup != null) 'launch_on_startup': launchOnStartup,
      if (whatsappDigestEnabled != null)
        'whatsapp_digest_enabled': whatsappDigestEnabled,
      if (lastDigestAt != null) 'last_digest_at': lastDigestAt,
      if (geminiModel != null) 'gemini_model': geminiModel,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? id,
    Value<String?>? userName,
    Value<DateTime?>? independenceDate,
    Value<String?>? independenceLabel,
    Value<int>? distractionLimitMinutes,
    Value<int>? screenTimeResetHour,
    Value<String?>? todoistApiToken,
    Value<String?>? geminiApiKey,
    Value<String?>? weatherCity,
    Value<double?>? weatherLat,
    Value<double?>? weatherLon,
    Value<String>? newsCategory,
    Value<bool>? showPersistentWidget,
    Value<bool>? launchOnStartup,
    Value<bool>? whatsappDigestEnabled,
    Value<DateTime?>? lastDigestAt,
    Value<String>? geminiModel,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      independenceDate: independenceDate ?? this.independenceDate,
      independenceLabel: independenceLabel ?? this.independenceLabel,
      distractionLimitMinutes:
          distractionLimitMinutes ?? this.distractionLimitMinutes,
      screenTimeResetHour: screenTimeResetHour ?? this.screenTimeResetHour,
      todoistApiToken: todoistApiToken ?? this.todoistApiToken,
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
      weatherCity: weatherCity ?? this.weatherCity,
      weatherLat: weatherLat ?? this.weatherLat,
      weatherLon: weatherLon ?? this.weatherLon,
      newsCategory: newsCategory ?? this.newsCategory,
      showPersistentWidget: showPersistentWidget ?? this.showPersistentWidget,
      launchOnStartup: launchOnStartup ?? this.launchOnStartup,
      whatsappDigestEnabled:
          whatsappDigestEnabled ?? this.whatsappDigestEnabled,
      lastDigestAt: lastDigestAt ?? this.lastDigestAt,
      geminiModel: geminiModel ?? this.geminiModel,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userName.present) {
      map['user_name'] = Variable<String>(userName.value);
    }
    if (independenceDate.present) {
      map['independence_date'] = Variable<DateTime>(independenceDate.value);
    }
    if (independenceLabel.present) {
      map['independence_label'] = Variable<String>(independenceLabel.value);
    }
    if (distractionLimitMinutes.present) {
      map['distraction_limit_minutes'] = Variable<int>(
        distractionLimitMinutes.value,
      );
    }
    if (screenTimeResetHour.present) {
      map['screen_time_reset_hour'] = Variable<int>(screenTimeResetHour.value);
    }
    if (todoistApiToken.present) {
      map['todoist_api_token'] = Variable<String>(todoistApiToken.value);
    }
    if (geminiApiKey.present) {
      map['gemini_api_key'] = Variable<String>(geminiApiKey.value);
    }
    if (weatherCity.present) {
      map['weather_city'] = Variable<String>(weatherCity.value);
    }
    if (weatherLat.present) {
      map['weather_lat'] = Variable<double>(weatherLat.value);
    }
    if (weatherLon.present) {
      map['weather_lon'] = Variable<double>(weatherLon.value);
    }
    if (newsCategory.present) {
      map['news_category'] = Variable<String>(newsCategory.value);
    }
    if (showPersistentWidget.present) {
      map['show_persistent_widget'] = Variable<bool>(
        showPersistentWidget.value,
      );
    }
    if (launchOnStartup.present) {
      map['launch_on_startup'] = Variable<bool>(launchOnStartup.value);
    }
    if (whatsappDigestEnabled.present) {
      map['whatsapp_digest_enabled'] = Variable<bool>(
        whatsappDigestEnabled.value,
      );
    }
    if (lastDigestAt.present) {
      map['last_digest_at'] = Variable<DateTime>(lastDigestAt.value);
    }
    if (geminiModel.present) {
      map['gemini_model'] = Variable<String>(geminiModel.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('userName: $userName, ')
          ..write('independenceDate: $independenceDate, ')
          ..write('independenceLabel: $independenceLabel, ')
          ..write('distractionLimitMinutes: $distractionLimitMinutes, ')
          ..write('screenTimeResetHour: $screenTimeResetHour, ')
          ..write('todoistApiToken: $todoistApiToken, ')
          ..write('geminiApiKey: $geminiApiKey, ')
          ..write('weatherCity: $weatherCity, ')
          ..write('weatherLat: $weatherLat, ')
          ..write('weatherLon: $weatherLon, ')
          ..write('newsCategory: $newsCategory, ')
          ..write('showPersistentWidget: $showPersistentWidget, ')
          ..write('launchOnStartup: $launchOnStartup, ')
          ..write('whatsappDigestEnabled: $whatsappDigestEnabled, ')
          ..write('lastDigestAt: $lastDigestAt, ')
          ..write('geminiModel: $geminiModel, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScreenTimeSessionsTable extends ScreenTimeSessions
    with TableInfo<$ScreenTimeSessionsTable, ScreenTimeSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScreenTimeSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appNameMeta = const VerificationMeta(
    'appName',
  );
  @override
  late final GeneratedColumn<String> appName = GeneratedColumn<String>(
    'app_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('neutral'),
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
    'end_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    appName,
    category,
    startTime,
    endTime,
    durationSeconds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'screen_time_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScreenTimeSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('app_name')) {
      context.handle(
        _appNameMeta,
        appName.isAcceptableOrUnknown(data['app_name']!, _appNameMeta),
      );
    } else if (isInserting) {
      context.missing(_appNameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScreenTimeSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScreenTimeSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      appName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_time'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
    );
  }

  @override
  $ScreenTimeSessionsTable createAlias(String alias) {
    return $ScreenTimeSessionsTable(attachedDatabase, alias);
  }
}

class ScreenTimeSession extends DataClass
    implements Insertable<ScreenTimeSession> {
  /// Session ID (UUID v4).
  final String id;

  /// Date of the session.
  final DateTime date;

  /// App name or window title.
  final String appName;

  /// Category: productive, neutral, distracted.
  final String category;

  /// Start time.
  final DateTime startTime;

  /// End time (null if still active).
  final DateTime? endTime;

  /// Duration in seconds (computed when ended).
  final int durationSeconds;
  const ScreenTimeSession({
    required this.id,
    required this.date,
    required this.appName,
    required this.category,
    required this.startTime,
    this.endTime,
    required this.durationSeconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<DateTime>(date);
    map['app_name'] = Variable<String>(appName);
    map['category'] = Variable<String>(category);
    map['start_time'] = Variable<DateTime>(startTime);
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    map['duration_seconds'] = Variable<int>(durationSeconds);
    return map;
  }

  ScreenTimeSessionsCompanion toCompanion(bool nullToAbsent) {
    return ScreenTimeSessionsCompanion(
      id: Value(id),
      date: Value(date),
      appName: Value(appName),
      category: Value(category),
      startTime: Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      durationSeconds: Value(durationSeconds),
    );
  }

  factory ScreenTimeSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScreenTimeSession(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      appName: serializer.fromJson<String>(json['appName']),
      category: serializer.fromJson<String>(json['category']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<DateTime>(date),
      'appName': serializer.toJson<String>(appName),
      'category': serializer.toJson<String>(category),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
    };
  }

  ScreenTimeSession copyWith({
    String? id,
    DateTime? date,
    String? appName,
    String? category,
    DateTime? startTime,
    Value<DateTime?> endTime = const Value.absent(),
    int? durationSeconds,
  }) => ScreenTimeSession(
    id: id ?? this.id,
    date: date ?? this.date,
    appName: appName ?? this.appName,
    category: category ?? this.category,
    startTime: startTime ?? this.startTime,
    endTime: endTime.present ? endTime.value : this.endTime,
    durationSeconds: durationSeconds ?? this.durationSeconds,
  );
  ScreenTimeSession copyWithCompanion(ScreenTimeSessionsCompanion data) {
    return ScreenTimeSession(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      appName: data.appName.present ? data.appName.value : this.appName,
      category: data.category.present ? data.category.value : this.category,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScreenTimeSession(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('appName: $appName, ')
          ..write('category: $category, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('durationSeconds: $durationSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    appName,
    category,
    startTime,
    endTime,
    durationSeconds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScreenTimeSession &&
          other.id == this.id &&
          other.date == this.date &&
          other.appName == this.appName &&
          other.category == this.category &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.durationSeconds == this.durationSeconds);
}

class ScreenTimeSessionsCompanion extends UpdateCompanion<ScreenTimeSession> {
  final Value<String> id;
  final Value<DateTime> date;
  final Value<String> appName;
  final Value<String> category;
  final Value<DateTime> startTime;
  final Value<DateTime?> endTime;
  final Value<int> durationSeconds;
  final Value<int> rowid;
  const ScreenTimeSessionsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.appName = const Value.absent(),
    this.category = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScreenTimeSessionsCompanion.insert({
    required String id,
    required DateTime date,
    required String appName,
    this.category = const Value.absent(),
    required DateTime startTime,
    this.endTime = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       date = Value(date),
       appName = Value(appName),
       startTime = Value(startTime);
  static Insertable<ScreenTimeSession> custom({
    Expression<String>? id,
    Expression<DateTime>? date,
    Expression<String>? appName,
    Expression<String>? category,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<int>? durationSeconds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (appName != null) 'app_name': appName,
      if (category != null) 'category': category,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScreenTimeSessionsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? date,
    Value<String>? appName,
    Value<String>? category,
    Value<DateTime>? startTime,
    Value<DateTime?>? endTime,
    Value<int>? durationSeconds,
    Value<int>? rowid,
  }) {
    return ScreenTimeSessionsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      appName: appName ?? this.appName,
      category: category ?? this.category,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (appName.present) {
      map['app_name'] = Variable<String>(appName.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScreenTimeSessionsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('appName: $appName, ')
          ..write('category: $category, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppCategoriesTable extends AppCategories
    with TableInfo<$AppCategoriesTable, AppCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _appNameMeta = const VerificationMeta(
    'appName',
  );
  @override
  late final GeneratedColumn<String> appName = GeneratedColumn<String>(
    'app_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [appName, category];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('app_name')) {
      context.handle(
        _appNameMeta,
        appName.isAcceptableOrUnknown(data['app_name']!, _appNameMeta),
      );
    } else if (isInserting) {
      context.missing(_appNameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {appName};
  @override
  AppCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppCategory(
      appName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
    );
  }

  @override
  $AppCategoriesTable createAlias(String alias) {
    return $AppCategoriesTable(attachedDatabase, alias);
  }
}

class AppCategory extends DataClass implements Insertable<AppCategory> {
  /// App name or bundle ID.
  final String appName;

  /// Category: productive, neutral, distracted.
  final String category;
  const AppCategory({required this.appName, required this.category});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['app_name'] = Variable<String>(appName);
    map['category'] = Variable<String>(category);
    return map;
  }

  AppCategoriesCompanion toCompanion(bool nullToAbsent) {
    return AppCategoriesCompanion(
      appName: Value(appName),
      category: Value(category),
    );
  }

  factory AppCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppCategory(
      appName: serializer.fromJson<String>(json['appName']),
      category: serializer.fromJson<String>(json['category']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'appName': serializer.toJson<String>(appName),
      'category': serializer.toJson<String>(category),
    };
  }

  AppCategory copyWith({String? appName, String? category}) => AppCategory(
    appName: appName ?? this.appName,
    category: category ?? this.category,
  );
  AppCategory copyWithCompanion(AppCategoriesCompanion data) {
    return AppCategory(
      appName: data.appName.present ? data.appName.value : this.appName,
      category: data.category.present ? data.category.value : this.category,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppCategory(')
          ..write('appName: $appName, ')
          ..write('category: $category')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(appName, category);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppCategory &&
          other.appName == this.appName &&
          other.category == this.category);
}

class AppCategoriesCompanion extends UpdateCompanion<AppCategory> {
  final Value<String> appName;
  final Value<String> category;
  final Value<int> rowid;
  const AppCategoriesCompanion({
    this.appName = const Value.absent(),
    this.category = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppCategoriesCompanion.insert({
    required String appName,
    required String category,
    this.rowid = const Value.absent(),
  }) : appName = Value(appName),
       category = Value(category);
  static Insertable<AppCategory> custom({
    Expression<String>? appName,
    Expression<String>? category,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (appName != null) 'app_name': appName,
      if (category != null) 'category': category,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppCategoriesCompanion copyWith({
    Value<String>? appName,
    Value<String>? category,
    Value<int>? rowid,
  }) {
    return AppCategoriesCompanion(
      appName: appName ?? this.appName,
      category: category ?? this.category,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (appName.present) {
      map['app_name'] = Variable<String>(appName.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppCategoriesCompanion(')
          ..write('appName: $appName, ')
          ..write('category: $category, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatMessagesTable extends ChatMessages
    with TableInfo<$ChatMessagesTable, ChatMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isUserMeta = const VerificationMeta('isUser');
  @override
  late final GeneratedColumn<bool> isUser = GeneratedColumn<bool>(
    'is_user',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_user" IN (0, 1))',
    ),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _todoistTaskIdMeta = const VerificationMeta(
    'todoistTaskId',
  );
  @override
  late final GeneratedColumn<String> todoistTaskId = GeneratedColumn<String>(
    'todoist_task_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    content,
    isUser,
    timestamp,
    sessionId,
    todoistTaskId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('is_user')) {
      context.handle(
        _isUserMeta,
        isUser.isAcceptableOrUnknown(data['is_user']!, _isUserMeta),
      );
    } else if (isInserting) {
      context.missing(_isUserMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('todoist_task_id')) {
      context.handle(
        _todoistTaskIdMeta,
        todoistTaskId.isAcceptableOrUnknown(
          data['todoist_task_id']!,
          _todoistTaskIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      isUser: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_user'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      todoistTaskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}todoist_task_id'],
      ),
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }
}

class ChatMessage extends DataClass implements Insertable<ChatMessage> {
  /// Unique message ID (UUID v4).
  final String id;

  /// Message content.
  final String content;

  /// True = user message, false = AI response.
  final bool isUser;

  /// When the message was created.
  final DateTime timestamp;

  /// Session ID — groups messages into one conversation.
  /// Format: 'session_<millisecondsSinceEpoch>'
  final String sessionId;

  /// Todoist task ID after sync (null = not synced yet).
  final String? todoistTaskId;
  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    required this.sessionId,
    this.todoistTaskId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['content'] = Variable<String>(content);
    map['is_user'] = Variable<bool>(isUser);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['session_id'] = Variable<String>(sessionId);
    if (!nullToAbsent || todoistTaskId != null) {
      map['todoist_task_id'] = Variable<String>(todoistTaskId);
    }
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      content: Value(content),
      isUser: Value(isUser),
      timestamp: Value(timestamp),
      sessionId: Value(sessionId),
      todoistTaskId: todoistTaskId == null && nullToAbsent
          ? const Value.absent()
          : Value(todoistTaskId),
    );
  }

  factory ChatMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessage(
      id: serializer.fromJson<String>(json['id']),
      content: serializer.fromJson<String>(json['content']),
      isUser: serializer.fromJson<bool>(json['isUser']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      todoistTaskId: serializer.fromJson<String?>(json['todoistTaskId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'content': serializer.toJson<String>(content),
      'isUser': serializer.toJson<bool>(isUser),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'sessionId': serializer.toJson<String>(sessionId),
      'todoistTaskId': serializer.toJson<String?>(todoistTaskId),
    };
  }

  ChatMessage copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    String? sessionId,
    Value<String?> todoistTaskId = const Value.absent(),
  }) => ChatMessage(
    id: id ?? this.id,
    content: content ?? this.content,
    isUser: isUser ?? this.isUser,
    timestamp: timestamp ?? this.timestamp,
    sessionId: sessionId ?? this.sessionId,
    todoistTaskId: todoistTaskId.present
        ? todoistTaskId.value
        : this.todoistTaskId,
  );
  ChatMessage copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessage(
      id: data.id.present ? data.id.value : this.id,
      content: data.content.present ? data.content.value : this.content,
      isUser: data.isUser.present ? data.isUser.value : this.isUser,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      todoistTaskId: data.todoistTaskId.present
          ? data.todoistTaskId.value
          : this.todoistTaskId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessage(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('isUser: $isUser, ')
          ..write('timestamp: $timestamp, ')
          ..write('sessionId: $sessionId, ')
          ..write('todoistTaskId: $todoistTaskId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, content, isUser, timestamp, sessionId, todoistTaskId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessage &&
          other.id == this.id &&
          other.content == this.content &&
          other.isUser == this.isUser &&
          other.timestamp == this.timestamp &&
          other.sessionId == this.sessionId &&
          other.todoistTaskId == this.todoistTaskId);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessage> {
  final Value<String> id;
  final Value<String> content;
  final Value<bool> isUser;
  final Value<DateTime> timestamp;
  final Value<String> sessionId;
  final Value<String?> todoistTaskId;
  final Value<int> rowid;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.content = const Value.absent(),
    this.isUser = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.todoistTaskId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    required String id,
    required String content,
    required bool isUser,
    required DateTime timestamp,
    required String sessionId,
    this.todoistTaskId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       content = Value(content),
       isUser = Value(isUser),
       timestamp = Value(timestamp),
       sessionId = Value(sessionId);
  static Insertable<ChatMessage> custom({
    Expression<String>? id,
    Expression<String>? content,
    Expression<bool>? isUser,
    Expression<DateTime>? timestamp,
    Expression<String>? sessionId,
    Expression<String>? todoistTaskId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (content != null) 'content': content,
      if (isUser != null) 'is_user': isUser,
      if (timestamp != null) 'timestamp': timestamp,
      if (sessionId != null) 'session_id': sessionId,
      if (todoistTaskId != null) 'todoist_task_id': todoistTaskId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatMessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? content,
    Value<bool>? isUser,
    Value<DateTime>? timestamp,
    Value<String>? sessionId,
    Value<String?>? todoistTaskId,
    Value<int>? rowid,
  }) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      sessionId: sessionId ?? this.sessionId,
      todoistTaskId: todoistTaskId ?? this.todoistTaskId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (isUser.present) {
      map['is_user'] = Variable<bool>(isUser.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (todoistTaskId.present) {
      map['todoist_task_id'] = Variable<String>(todoistTaskId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('isUser: $isUser, ')
          ..write('timestamp: $timestamp, ')
          ..write('sessionId: $sessionId, ')
          ..write('todoistTaskId: $todoistTaskId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WhatsappDigestsTable extends WhatsappDigests
    with TableInfo<$WhatsappDigestsTable, WhatsappDigest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WhatsappDigestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupNameMeta = const VerificationMeta(
    'groupName',
  );
  @override
  late final GeneratedColumn<String> groupName = GeneratedColumn<String>(
    'group_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupJidMeta = const VerificationMeta(
    'groupJid',
  );
  @override
  late final GeneratedColumn<String> groupJid = GeneratedColumn<String>(
    'group_jid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawMessagesMeta = const VerificationMeta(
    'rawMessages',
  );
  @override
  late final GeneratedColumn<String> rawMessages = GeneratedColumn<String>(
    'raw_messages',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _digestDateMeta = const VerificationMeta(
    'digestDate',
  );
  @override
  late final GeneratedColumn<DateTime> digestDate = GeneratedColumn<DateTime>(
    'digest_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _todoistTaskIdMeta = const VerificationMeta(
    'todoistTaskId',
  );
  @override
  late final GeneratedColumn<String> todoistTaskId = GeneratedColumn<String>(
    'todoist_task_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.now()),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    groupName,
    groupJid,
    rawMessages,
    summary,
    digestDate,
    todoistTaskId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'whatsapp_digests';
  @override
  VerificationContext validateIntegrity(
    Insertable<WhatsappDigest> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group_name')) {
      context.handle(
        _groupNameMeta,
        groupName.isAcceptableOrUnknown(data['group_name']!, _groupNameMeta),
      );
    } else if (isInserting) {
      context.missing(_groupNameMeta);
    }
    if (data.containsKey('group_jid')) {
      context.handle(
        _groupJidMeta,
        groupJid.isAcceptableOrUnknown(data['group_jid']!, _groupJidMeta),
      );
    }
    if (data.containsKey('raw_messages')) {
      context.handle(
        _rawMessagesMeta,
        rawMessages.isAcceptableOrUnknown(
          data['raw_messages']!,
          _rawMessagesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rawMessagesMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    } else if (isInserting) {
      context.missing(_summaryMeta);
    }
    if (data.containsKey('digest_date')) {
      context.handle(
        _digestDateMeta,
        digestDate.isAcceptableOrUnknown(data['digest_date']!, _digestDateMeta),
      );
    } else if (isInserting) {
      context.missing(_digestDateMeta);
    }
    if (data.containsKey('todoist_task_id')) {
      context.handle(
        _todoistTaskIdMeta,
        todoistTaskId.isAcceptableOrUnknown(
          data['todoist_task_id']!,
          _todoistTaskIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WhatsappDigest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WhatsappDigest(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      groupName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_name'],
      )!,
      groupJid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_jid'],
      ),
      rawMessages: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_messages'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      digestDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}digest_date'],
      )!,
      todoistTaskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}todoist_task_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WhatsappDigestsTable createAlias(String alias) {
    return $WhatsappDigestsTable(attachedDatabase, alias);
  }
}

class WhatsappDigest extends DataClass implements Insertable<WhatsappDigest> {
  /// Unique digest ID (UUID v4).
  final String id;

  /// Group display name (e.g., "CSE Department").
  final String groupName;

  /// WhatsApp group JID (e.g., "1234567890-123456@g.us"). Nullable for manual pastes.
  final String? groupJid;

  /// Raw concatenated messages that were summarized.
  final String rawMessages;

  /// Gemini-generated summary (markdown bullets).
  final String summary;

  /// Date of the digest.
  final DateTime digestDate;

  /// Todoist task ID after sync (null = not synced).
  final String? todoistTaskId;

  /// When the digest was created.
  final DateTime createdAt;
  const WhatsappDigest({
    required this.id,
    required this.groupName,
    this.groupJid,
    required this.rawMessages,
    required this.summary,
    required this.digestDate,
    this.todoistTaskId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['group_name'] = Variable<String>(groupName);
    if (!nullToAbsent || groupJid != null) {
      map['group_jid'] = Variable<String>(groupJid);
    }
    map['raw_messages'] = Variable<String>(rawMessages);
    map['summary'] = Variable<String>(summary);
    map['digest_date'] = Variable<DateTime>(digestDate);
    if (!nullToAbsent || todoistTaskId != null) {
      map['todoist_task_id'] = Variable<String>(todoistTaskId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WhatsappDigestsCompanion toCompanion(bool nullToAbsent) {
    return WhatsappDigestsCompanion(
      id: Value(id),
      groupName: Value(groupName),
      groupJid: groupJid == null && nullToAbsent
          ? const Value.absent()
          : Value(groupJid),
      rawMessages: Value(rawMessages),
      summary: Value(summary),
      digestDate: Value(digestDate),
      todoistTaskId: todoistTaskId == null && nullToAbsent
          ? const Value.absent()
          : Value(todoistTaskId),
      createdAt: Value(createdAt),
    );
  }

  factory WhatsappDigest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WhatsappDigest(
      id: serializer.fromJson<String>(json['id']),
      groupName: serializer.fromJson<String>(json['groupName']),
      groupJid: serializer.fromJson<String?>(json['groupJid']),
      rawMessages: serializer.fromJson<String>(json['rawMessages']),
      summary: serializer.fromJson<String>(json['summary']),
      digestDate: serializer.fromJson<DateTime>(json['digestDate']),
      todoistTaskId: serializer.fromJson<String?>(json['todoistTaskId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'groupName': serializer.toJson<String>(groupName),
      'groupJid': serializer.toJson<String?>(groupJid),
      'rawMessages': serializer.toJson<String>(rawMessages),
      'summary': serializer.toJson<String>(summary),
      'digestDate': serializer.toJson<DateTime>(digestDate),
      'todoistTaskId': serializer.toJson<String?>(todoistTaskId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WhatsappDigest copyWith({
    String? id,
    String? groupName,
    Value<String?> groupJid = const Value.absent(),
    String? rawMessages,
    String? summary,
    DateTime? digestDate,
    Value<String?> todoistTaskId = const Value.absent(),
    DateTime? createdAt,
  }) => WhatsappDigest(
    id: id ?? this.id,
    groupName: groupName ?? this.groupName,
    groupJid: groupJid.present ? groupJid.value : this.groupJid,
    rawMessages: rawMessages ?? this.rawMessages,
    summary: summary ?? this.summary,
    digestDate: digestDate ?? this.digestDate,
    todoistTaskId: todoistTaskId.present
        ? todoistTaskId.value
        : this.todoistTaskId,
    createdAt: createdAt ?? this.createdAt,
  );
  WhatsappDigest copyWithCompanion(WhatsappDigestsCompanion data) {
    return WhatsappDigest(
      id: data.id.present ? data.id.value : this.id,
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
      groupJid: data.groupJid.present ? data.groupJid.value : this.groupJid,
      rawMessages: data.rawMessages.present
          ? data.rawMessages.value
          : this.rawMessages,
      summary: data.summary.present ? data.summary.value : this.summary,
      digestDate: data.digestDate.present
          ? data.digestDate.value
          : this.digestDate,
      todoistTaskId: data.todoistTaskId.present
          ? data.todoistTaskId.value
          : this.todoistTaskId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WhatsappDigest(')
          ..write('id: $id, ')
          ..write('groupName: $groupName, ')
          ..write('groupJid: $groupJid, ')
          ..write('rawMessages: $rawMessages, ')
          ..write('summary: $summary, ')
          ..write('digestDate: $digestDate, ')
          ..write('todoistTaskId: $todoistTaskId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    groupName,
    groupJid,
    rawMessages,
    summary,
    digestDate,
    todoistTaskId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WhatsappDigest &&
          other.id == this.id &&
          other.groupName == this.groupName &&
          other.groupJid == this.groupJid &&
          other.rawMessages == this.rawMessages &&
          other.summary == this.summary &&
          other.digestDate == this.digestDate &&
          other.todoistTaskId == this.todoistTaskId &&
          other.createdAt == this.createdAt);
}

class WhatsappDigestsCompanion extends UpdateCompanion<WhatsappDigest> {
  final Value<String> id;
  final Value<String> groupName;
  final Value<String?> groupJid;
  final Value<String> rawMessages;
  final Value<String> summary;
  final Value<DateTime> digestDate;
  final Value<String?> todoistTaskId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const WhatsappDigestsCompanion({
    this.id = const Value.absent(),
    this.groupName = const Value.absent(),
    this.groupJid = const Value.absent(),
    this.rawMessages = const Value.absent(),
    this.summary = const Value.absent(),
    this.digestDate = const Value.absent(),
    this.todoistTaskId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WhatsappDigestsCompanion.insert({
    required String id,
    required String groupName,
    this.groupJid = const Value.absent(),
    required String rawMessages,
    required String summary,
    required DateTime digestDate,
    this.todoistTaskId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       groupName = Value(groupName),
       rawMessages = Value(rawMessages),
       summary = Value(summary),
       digestDate = Value(digestDate);
  static Insertable<WhatsappDigest> custom({
    Expression<String>? id,
    Expression<String>? groupName,
    Expression<String>? groupJid,
    Expression<String>? rawMessages,
    Expression<String>? summary,
    Expression<DateTime>? digestDate,
    Expression<String>? todoistTaskId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupName != null) 'group_name': groupName,
      if (groupJid != null) 'group_jid': groupJid,
      if (rawMessages != null) 'raw_messages': rawMessages,
      if (summary != null) 'summary': summary,
      if (digestDate != null) 'digest_date': digestDate,
      if (todoistTaskId != null) 'todoist_task_id': todoistTaskId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WhatsappDigestsCompanion copyWith({
    Value<String>? id,
    Value<String>? groupName,
    Value<String?>? groupJid,
    Value<String>? rawMessages,
    Value<String>? summary,
    Value<DateTime>? digestDate,
    Value<String?>? todoistTaskId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return WhatsappDigestsCompanion(
      id: id ?? this.id,
      groupName: groupName ?? this.groupName,
      groupJid: groupJid ?? this.groupJid,
      rawMessages: rawMessages ?? this.rawMessages,
      summary: summary ?? this.summary,
      digestDate: digestDate ?? this.digestDate,
      todoistTaskId: todoistTaskId ?? this.todoistTaskId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (groupName.present) {
      map['group_name'] = Variable<String>(groupName.value);
    }
    if (groupJid.present) {
      map['group_jid'] = Variable<String>(groupJid.value);
    }
    if (rawMessages.present) {
      map['raw_messages'] = Variable<String>(rawMessages.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (digestDate.present) {
      map['digest_date'] = Variable<DateTime>(digestDate.value);
    }
    if (todoistTaskId.present) {
      map['todoist_task_id'] = Variable<String>(todoistTaskId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WhatsappDigestsCompanion(')
          ..write('id: $id, ')
          ..write('groupName: $groupName, ')
          ..write('groupJid: $groupJid, ')
          ..write('rawMessages: $rawMessages, ')
          ..write('summary: $summary, ')
          ..write('digestDate: $digestDate, ')
          ..write('todoistTaskId: $todoistTaskId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WhatsappGroupsTable extends WhatsappGroups
    with TableInfo<$WhatsappGroupsTable, WhatsappGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WhatsappGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _jidMeta = const VerificationMeta('jid');
  @override
  late final GeneratedColumn<String> jid = GeneratedColumn<String>(
    'jid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isTrackedMeta = const VerificationMeta(
    'isTracked',
  );
  @override
  late final GeneratedColumn<bool> isTracked = GeneratedColumn<bool>(
    'is_tracked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_tracked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _participantCountMeta = const VerificationMeta(
    'participantCount',
  );
  @override
  late final GeneratedColumn<int> participantCount = GeneratedColumn<int>(
    'participant_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastDigestAtMeta = const VerificationMeta(
    'lastDigestAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastDigestAt = GeneratedColumn<DateTime>(
    'last_digest_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.now()),
  );
  @override
  List<GeneratedColumn> get $columns => [
    jid,
    name,
    isTracked,
    participantCount,
    lastDigestAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'whatsapp_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<WhatsappGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('jid')) {
      context.handle(
        _jidMeta,
        jid.isAcceptableOrUnknown(data['jid']!, _jidMeta),
      );
    } else if (isInserting) {
      context.missing(_jidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_tracked')) {
      context.handle(
        _isTrackedMeta,
        isTracked.isAcceptableOrUnknown(data['is_tracked']!, _isTrackedMeta),
      );
    }
    if (data.containsKey('participant_count')) {
      context.handle(
        _participantCountMeta,
        participantCount.isAcceptableOrUnknown(
          data['participant_count']!,
          _participantCountMeta,
        ),
      );
    }
    if (data.containsKey('last_digest_at')) {
      context.handle(
        _lastDigestAtMeta,
        lastDigestAt.isAcceptableOrUnknown(
          data['last_digest_at']!,
          _lastDigestAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {jid};
  @override
  WhatsappGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WhatsappGroup(
      jid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jid'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isTracked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_tracked'],
      )!,
      participantCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}participant_count'],
      )!,
      lastDigestAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_digest_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WhatsappGroupsTable createAlias(String alias) {
    return $WhatsappGroupsTable(attachedDatabase, alias);
  }
}

class WhatsappGroup extends DataClass implements Insertable<WhatsappGroup> {
  /// WhatsApp group JID — the unique group identifier (e.g., "1234567890-123456@g.us").
  final String jid;

  /// Human-readable group name.
  final String name;

  /// Whether Anchor is actively tracking this group for digests.
  final bool isTracked;

  /// Participant count (updated from Baileys).
  final int participantCount;

  /// When the last digest was generated for this group.
  final DateTime? lastDigestAt;

  /// When this group record was created/updated.
  final DateTime updatedAt;
  const WhatsappGroup({
    required this.jid,
    required this.name,
    required this.isTracked,
    required this.participantCount,
    this.lastDigestAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['jid'] = Variable<String>(jid);
    map['name'] = Variable<String>(name);
    map['is_tracked'] = Variable<bool>(isTracked);
    map['participant_count'] = Variable<int>(participantCount);
    if (!nullToAbsent || lastDigestAt != null) {
      map['last_digest_at'] = Variable<DateTime>(lastDigestAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WhatsappGroupsCompanion toCompanion(bool nullToAbsent) {
    return WhatsappGroupsCompanion(
      jid: Value(jid),
      name: Value(name),
      isTracked: Value(isTracked),
      participantCount: Value(participantCount),
      lastDigestAt: lastDigestAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastDigestAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WhatsappGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WhatsappGroup(
      jid: serializer.fromJson<String>(json['jid']),
      name: serializer.fromJson<String>(json['name']),
      isTracked: serializer.fromJson<bool>(json['isTracked']),
      participantCount: serializer.fromJson<int>(json['participantCount']),
      lastDigestAt: serializer.fromJson<DateTime?>(json['lastDigestAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'jid': serializer.toJson<String>(jid),
      'name': serializer.toJson<String>(name),
      'isTracked': serializer.toJson<bool>(isTracked),
      'participantCount': serializer.toJson<int>(participantCount),
      'lastDigestAt': serializer.toJson<DateTime?>(lastDigestAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WhatsappGroup copyWith({
    String? jid,
    String? name,
    bool? isTracked,
    int? participantCount,
    Value<DateTime?> lastDigestAt = const Value.absent(),
    DateTime? updatedAt,
  }) => WhatsappGroup(
    jid: jid ?? this.jid,
    name: name ?? this.name,
    isTracked: isTracked ?? this.isTracked,
    participantCount: participantCount ?? this.participantCount,
    lastDigestAt: lastDigestAt.present ? lastDigestAt.value : this.lastDigestAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WhatsappGroup copyWithCompanion(WhatsappGroupsCompanion data) {
    return WhatsappGroup(
      jid: data.jid.present ? data.jid.value : this.jid,
      name: data.name.present ? data.name.value : this.name,
      isTracked: data.isTracked.present ? data.isTracked.value : this.isTracked,
      participantCount: data.participantCount.present
          ? data.participantCount.value
          : this.participantCount,
      lastDigestAt: data.lastDigestAt.present
          ? data.lastDigestAt.value
          : this.lastDigestAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WhatsappGroup(')
          ..write('jid: $jid, ')
          ..write('name: $name, ')
          ..write('isTracked: $isTracked, ')
          ..write('participantCount: $participantCount, ')
          ..write('lastDigestAt: $lastDigestAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    jid,
    name,
    isTracked,
    participantCount,
    lastDigestAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WhatsappGroup &&
          other.jid == this.jid &&
          other.name == this.name &&
          other.isTracked == this.isTracked &&
          other.participantCount == this.participantCount &&
          other.lastDigestAt == this.lastDigestAt &&
          other.updatedAt == this.updatedAt);
}

class WhatsappGroupsCompanion extends UpdateCompanion<WhatsappGroup> {
  final Value<String> jid;
  final Value<String> name;
  final Value<bool> isTracked;
  final Value<int> participantCount;
  final Value<DateTime?> lastDigestAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WhatsappGroupsCompanion({
    this.jid = const Value.absent(),
    this.name = const Value.absent(),
    this.isTracked = const Value.absent(),
    this.participantCount = const Value.absent(),
    this.lastDigestAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WhatsappGroupsCompanion.insert({
    required String jid,
    required String name,
    this.isTracked = const Value.absent(),
    this.participantCount = const Value.absent(),
    this.lastDigestAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : jid = Value(jid),
       name = Value(name);
  static Insertable<WhatsappGroup> custom({
    Expression<String>? jid,
    Expression<String>? name,
    Expression<bool>? isTracked,
    Expression<int>? participantCount,
    Expression<DateTime>? lastDigestAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (jid != null) 'jid': jid,
      if (name != null) 'name': name,
      if (isTracked != null) 'is_tracked': isTracked,
      if (participantCount != null) 'participant_count': participantCount,
      if (lastDigestAt != null) 'last_digest_at': lastDigestAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WhatsappGroupsCompanion copyWith({
    Value<String>? jid,
    Value<String>? name,
    Value<bool>? isTracked,
    Value<int>? participantCount,
    Value<DateTime?>? lastDigestAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return WhatsappGroupsCompanion(
      jid: jid ?? this.jid,
      name: name ?? this.name,
      isTracked: isTracked ?? this.isTracked,
      participantCount: participantCount ?? this.participantCount,
      lastDigestAt: lastDigestAt ?? this.lastDigestAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (jid.present) {
      map['jid'] = Variable<String>(jid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isTracked.present) {
      map['is_tracked'] = Variable<bool>(isTracked.value);
    }
    if (participantCount.present) {
      map['participant_count'] = Variable<int>(participantCount.value);
    }
    if (lastDigestAt.present) {
      map['last_digest_at'] = Variable<DateTime>(lastDigestAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WhatsappGroupsCompanion(')
          ..write('jid: $jid, ')
          ..write('name: $name, ')
          ..write('isTracked: $isTracked, ')
          ..write('participantCount: $participantCount, ')
          ..write('lastDigestAt: $lastDigestAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AnchorDatabase extends GeneratedDatabase {
  _$AnchorDatabase(QueryExecutor e) : super(e);
  $AnchorDatabaseManager get managers => $AnchorDatabaseManager(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $JournalEntriesTable journalEntries = $JournalEntriesTable(this);
  late final $ProgressDimensionsTable progressDimensions =
      $ProgressDimensionsTable(this);
  late final $ProgressValuesTable progressValues = $ProgressValuesTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $ScreenTimeSessionsTable screenTimeSessions =
      $ScreenTimeSessionsTable(this);
  late final $AppCategoriesTable appCategories = $AppCategoriesTable(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final $WhatsappDigestsTable whatsappDigests = $WhatsappDigestsTable(
    this,
  );
  late final $WhatsappGroupsTable whatsappGroups = $WhatsappGroupsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tasks,
    journalEntries,
    progressDimensions,
    progressValues,
    appSettings,
    screenTimeSessions,
    appCategories,
    chatMessages,
    whatsappDigests,
    whatsappGroups,
  ];
}

typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      required String id,
      required String title,
      Value<String?> description,
      Value<DateTime?> dueDate,
      Value<int> priority,
      Value<String?> label,
      Value<String?> projectName,
      Value<String?> todoistProjectId,
      Value<bool> isCompleted,
      Value<DateTime?> completedAt,
      Value<DateTime> createdAt,
      Value<bool> isRecurring,
      Value<String?> recurringSchedule,
      Value<String> source,
      Value<String?> todoistId,
      Value<int> rowid,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> description,
      Value<DateTime?> dueDate,
      Value<int> priority,
      Value<String?> label,
      Value<String?> projectName,
      Value<String?> todoistProjectId,
      Value<bool> isCompleted,
      Value<DateTime?> completedAt,
      Value<DateTime> createdAt,
      Value<bool> isRecurring,
      Value<String?> recurringSchedule,
      Value<String> source,
      Value<String?> todoistId,
      Value<int> rowid,
    });

class $$TasksTableFilterComposer
    extends Composer<_$AnchorDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get projectName => $composableBuilder(
    column: $table.projectName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get todoistProjectId => $composableBuilder(
    column: $table.todoistProjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurringSchedule => $composableBuilder(
    column: $table.recurringSchedule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get todoistId => $composableBuilder(
    column: $table.todoistId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasksTableOrderingComposer
    extends Composer<_$AnchorDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectName => $composableBuilder(
    column: $table.projectName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get todoistProjectId => $composableBuilder(
    column: $table.todoistProjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurringSchedule => $composableBuilder(
    column: $table.recurringSchedule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get todoistId => $composableBuilder(
    column: $table.todoistId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AnchorDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get projectName => $composableBuilder(
    column: $table.projectName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get todoistProjectId => $composableBuilder(
    column: $table.todoistProjectId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurringSchedule => $composableBuilder(
    column: $table.recurringSchedule,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get todoistId =>
      $composableBuilder(column: $table.todoistId, builder: (column) => column);
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AnchorDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, BaseReferences<_$AnchorDatabase, $TasksTable, Task>),
          Task,
          PrefetchHooks Function()
        > {
  $$TasksTableTableManager(_$AnchorDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<String?> projectName = const Value.absent(),
                Value<String?> todoistProjectId = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isRecurring = const Value.absent(),
                Value<String?> recurringSchedule = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> todoistId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                title: title,
                description: description,
                dueDate: dueDate,
                priority: priority,
                label: label,
                projectName: projectName,
                todoistProjectId: todoistProjectId,
                isCompleted: isCompleted,
                completedAt: completedAt,
                createdAt: createdAt,
                isRecurring: isRecurring,
                recurringSchedule: recurringSchedule,
                source: source,
                todoistId: todoistId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<String?> projectName = const Value.absent(),
                Value<String?> todoistProjectId = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isRecurring = const Value.absent(),
                Value<String?> recurringSchedule = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> todoistId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                title: title,
                description: description,
                dueDate: dueDate,
                priority: priority,
                label: label,
                projectName: projectName,
                todoistProjectId: todoistProjectId,
                isCompleted: isCompleted,
                completedAt: completedAt,
                createdAt: createdAt,
                isRecurring: isRecurring,
                recurringSchedule: recurringSchedule,
                source: source,
                todoistId: todoistId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AnchorDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, BaseReferences<_$AnchorDatabase, $TasksTable, Task>),
      Task,
      PrefetchHooks Function()
    >;
typedef $$JournalEntriesTableCreateCompanionBuilder =
    JournalEntriesCompanion Function({
      required String id,
      required DateTime date,
      Value<int?> sleepRating,
      Value<int?> energyRating,
      Value<int?> focusRating,
      Value<int?> moodRating,
      Value<String?> reflection,
      Value<String?> moodNote,
      Value<String?> dailyIntention,
      Value<String?> endOfDayNote,
      Value<int?> screenTimeMinutes,
      Value<int?> productiveTimeMinutes,
      Value<int?> distractedTimeMinutes,
      Value<int> tasksCompleted,
      Value<bool> weeklyReflectionGenerated,
      Value<String?> weeklyReflection,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$JournalEntriesTableUpdateCompanionBuilder =
    JournalEntriesCompanion Function({
      Value<String> id,
      Value<DateTime> date,
      Value<int?> sleepRating,
      Value<int?> energyRating,
      Value<int?> focusRating,
      Value<int?> moodRating,
      Value<String?> reflection,
      Value<String?> moodNote,
      Value<String?> dailyIntention,
      Value<String?> endOfDayNote,
      Value<int?> screenTimeMinutes,
      Value<int?> productiveTimeMinutes,
      Value<int?> distractedTimeMinutes,
      Value<int> tasksCompleted,
      Value<bool> weeklyReflectionGenerated,
      Value<String?> weeklyReflection,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$JournalEntriesTableFilterComposer
    extends Composer<_$AnchorDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sleepRating => $composableBuilder(
    column: $table.sleepRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get energyRating => $composableBuilder(
    column: $table.energyRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get focusRating => $composableBuilder(
    column: $table.focusRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get moodRating => $composableBuilder(
    column: $table.moodRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reflection => $composableBuilder(
    column: $table.reflection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get moodNote => $composableBuilder(
    column: $table.moodNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dailyIntention => $composableBuilder(
    column: $table.dailyIntention,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endOfDayNote => $composableBuilder(
    column: $table.endOfDayNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get screenTimeMinutes => $composableBuilder(
    column: $table.screenTimeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get productiveTimeMinutes => $composableBuilder(
    column: $table.productiveTimeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get distractedTimeMinutes => $composableBuilder(
    column: $table.distractedTimeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tasksCompleted => $composableBuilder(
    column: $table.tasksCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get weeklyReflectionGenerated => $composableBuilder(
    column: $table.weeklyReflectionGenerated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weeklyReflection => $composableBuilder(
    column: $table.weeklyReflection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JournalEntriesTableOrderingComposer
    extends Composer<_$AnchorDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sleepRating => $composableBuilder(
    column: $table.sleepRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get energyRating => $composableBuilder(
    column: $table.energyRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get focusRating => $composableBuilder(
    column: $table.focusRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get moodRating => $composableBuilder(
    column: $table.moodRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reflection => $composableBuilder(
    column: $table.reflection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get moodNote => $composableBuilder(
    column: $table.moodNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dailyIntention => $composableBuilder(
    column: $table.dailyIntention,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endOfDayNote => $composableBuilder(
    column: $table.endOfDayNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get screenTimeMinutes => $composableBuilder(
    column: $table.screenTimeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get productiveTimeMinutes => $composableBuilder(
    column: $table.productiveTimeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get distractedTimeMinutes => $composableBuilder(
    column: $table.distractedTimeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tasksCompleted => $composableBuilder(
    column: $table.tasksCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get weeklyReflectionGenerated => $composableBuilder(
    column: $table.weeklyReflectionGenerated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weeklyReflection => $composableBuilder(
    column: $table.weeklyReflection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JournalEntriesTableAnnotationComposer
    extends Composer<_$AnchorDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get sleepRating => $composableBuilder(
    column: $table.sleepRating,
    builder: (column) => column,
  );

  GeneratedColumn<int> get energyRating => $composableBuilder(
    column: $table.energyRating,
    builder: (column) => column,
  );

  GeneratedColumn<int> get focusRating => $composableBuilder(
    column: $table.focusRating,
    builder: (column) => column,
  );

  GeneratedColumn<int> get moodRating => $composableBuilder(
    column: $table.moodRating,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reflection => $composableBuilder(
    column: $table.reflection,
    builder: (column) => column,
  );

  GeneratedColumn<String> get moodNote =>
      $composableBuilder(column: $table.moodNote, builder: (column) => column);

  GeneratedColumn<String> get dailyIntention => $composableBuilder(
    column: $table.dailyIntention,
    builder: (column) => column,
  );

  GeneratedColumn<String> get endOfDayNote => $composableBuilder(
    column: $table.endOfDayNote,
    builder: (column) => column,
  );

  GeneratedColumn<int> get screenTimeMinutes => $composableBuilder(
    column: $table.screenTimeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get productiveTimeMinutes => $composableBuilder(
    column: $table.productiveTimeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get distractedTimeMinutes => $composableBuilder(
    column: $table.distractedTimeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tasksCompleted => $composableBuilder(
    column: $table.tasksCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get weeklyReflectionGenerated => $composableBuilder(
    column: $table.weeklyReflectionGenerated,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weeklyReflection => $composableBuilder(
    column: $table.weeklyReflection,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$JournalEntriesTableTableManager
    extends
        RootTableManager<
          _$AnchorDatabase,
          $JournalEntriesTable,
          JournalEntry,
          $$JournalEntriesTableFilterComposer,
          $$JournalEntriesTableOrderingComposer,
          $$JournalEntriesTableAnnotationComposer,
          $$JournalEntriesTableCreateCompanionBuilder,
          $$JournalEntriesTableUpdateCompanionBuilder,
          (
            JournalEntry,
            BaseReferences<
              _$AnchorDatabase,
              $JournalEntriesTable,
              JournalEntry
            >,
          ),
          JournalEntry,
          PrefetchHooks Function()
        > {
  $$JournalEntriesTableTableManager(
    _$AnchorDatabase db,
    $JournalEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int?> sleepRating = const Value.absent(),
                Value<int?> energyRating = const Value.absent(),
                Value<int?> focusRating = const Value.absent(),
                Value<int?> moodRating = const Value.absent(),
                Value<String?> reflection = const Value.absent(),
                Value<String?> moodNote = const Value.absent(),
                Value<String?> dailyIntention = const Value.absent(),
                Value<String?> endOfDayNote = const Value.absent(),
                Value<int?> screenTimeMinutes = const Value.absent(),
                Value<int?> productiveTimeMinutes = const Value.absent(),
                Value<int?> distractedTimeMinutes = const Value.absent(),
                Value<int> tasksCompleted = const Value.absent(),
                Value<bool> weeklyReflectionGenerated = const Value.absent(),
                Value<String?> weeklyReflection = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JournalEntriesCompanion(
                id: id,
                date: date,
                sleepRating: sleepRating,
                energyRating: energyRating,
                focusRating: focusRating,
                moodRating: moodRating,
                reflection: reflection,
                moodNote: moodNote,
                dailyIntention: dailyIntention,
                endOfDayNote: endOfDayNote,
                screenTimeMinutes: screenTimeMinutes,
                productiveTimeMinutes: productiveTimeMinutes,
                distractedTimeMinutes: distractedTimeMinutes,
                tasksCompleted: tasksCompleted,
                weeklyReflectionGenerated: weeklyReflectionGenerated,
                weeklyReflection: weeklyReflection,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime date,
                Value<int?> sleepRating = const Value.absent(),
                Value<int?> energyRating = const Value.absent(),
                Value<int?> focusRating = const Value.absent(),
                Value<int?> moodRating = const Value.absent(),
                Value<String?> reflection = const Value.absent(),
                Value<String?> moodNote = const Value.absent(),
                Value<String?> dailyIntention = const Value.absent(),
                Value<String?> endOfDayNote = const Value.absent(),
                Value<int?> screenTimeMinutes = const Value.absent(),
                Value<int?> productiveTimeMinutes = const Value.absent(),
                Value<int?> distractedTimeMinutes = const Value.absent(),
                Value<int> tasksCompleted = const Value.absent(),
                Value<bool> weeklyReflectionGenerated = const Value.absent(),
                Value<String?> weeklyReflection = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JournalEntriesCompanion.insert(
                id: id,
                date: date,
                sleepRating: sleepRating,
                energyRating: energyRating,
                focusRating: focusRating,
                moodRating: moodRating,
                reflection: reflection,
                moodNote: moodNote,
                dailyIntention: dailyIntention,
                endOfDayNote: endOfDayNote,
                screenTimeMinutes: screenTimeMinutes,
                productiveTimeMinutes: productiveTimeMinutes,
                distractedTimeMinutes: distractedTimeMinutes,
                tasksCompleted: tasksCompleted,
                weeklyReflectionGenerated: weeklyReflectionGenerated,
                weeklyReflection: weeklyReflection,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JournalEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AnchorDatabase,
      $JournalEntriesTable,
      JournalEntry,
      $$JournalEntriesTableFilterComposer,
      $$JournalEntriesTableOrderingComposer,
      $$JournalEntriesTableAnnotationComposer,
      $$JournalEntriesTableCreateCompanionBuilder,
      $$JournalEntriesTableUpdateCompanionBuilder,
      (
        JournalEntry,
        BaseReferences<_$AnchorDatabase, $JournalEntriesTable, JournalEntry>,
      ),
      JournalEntry,
      PrefetchHooks Function()
    >;
typedef $$ProgressDimensionsTableCreateCompanionBuilder =
    ProgressDimensionsCompanion Function({
      required String id,
      required String name,
      Value<double> weeklyTarget,
      Value<String> unit,
      Value<bool> isAutomatic,
      Value<String> colorHex,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$ProgressDimensionsTableUpdateCompanionBuilder =
    ProgressDimensionsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<double> weeklyTarget,
      Value<String> unit,
      Value<bool> isAutomatic,
      Value<String> colorHex,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ProgressDimensionsTableFilterComposer
    extends Composer<_$AnchorDatabase, $ProgressDimensionsTable> {
  $$ProgressDimensionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weeklyTarget => $composableBuilder(
    column: $table.weeklyTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAutomatic => $composableBuilder(
    column: $table.isAutomatic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProgressDimensionsTableOrderingComposer
    extends Composer<_$AnchorDatabase, $ProgressDimensionsTable> {
  $$ProgressDimensionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weeklyTarget => $composableBuilder(
    column: $table.weeklyTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAutomatic => $composableBuilder(
    column: $table.isAutomatic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProgressDimensionsTableAnnotationComposer
    extends Composer<_$AnchorDatabase, $ProgressDimensionsTable> {
  $$ProgressDimensionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get weeklyTarget => $composableBuilder(
    column: $table.weeklyTarget,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<bool> get isAutomatic => $composableBuilder(
    column: $table.isAutomatic,
    builder: (column) => column,
  );

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ProgressDimensionsTableTableManager
    extends
        RootTableManager<
          _$AnchorDatabase,
          $ProgressDimensionsTable,
          ProgressDimension,
          $$ProgressDimensionsTableFilterComposer,
          $$ProgressDimensionsTableOrderingComposer,
          $$ProgressDimensionsTableAnnotationComposer,
          $$ProgressDimensionsTableCreateCompanionBuilder,
          $$ProgressDimensionsTableUpdateCompanionBuilder,
          (
            ProgressDimension,
            BaseReferences<
              _$AnchorDatabase,
              $ProgressDimensionsTable,
              ProgressDimension
            >,
          ),
          ProgressDimension,
          PrefetchHooks Function()
        > {
  $$ProgressDimensionsTableTableManager(
    _$AnchorDatabase db,
    $ProgressDimensionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProgressDimensionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProgressDimensionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProgressDimensionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> weeklyTarget = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<bool> isAutomatic = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProgressDimensionsCompanion(
                id: id,
                name: name,
                weeklyTarget: weeklyTarget,
                unit: unit,
                isAutomatic: isAutomatic,
                colorHex: colorHex,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<double> weeklyTarget = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<bool> isAutomatic = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProgressDimensionsCompanion.insert(
                id: id,
                name: name,
                weeklyTarget: weeklyTarget,
                unit: unit,
                isAutomatic: isAutomatic,
                colorHex: colorHex,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProgressDimensionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AnchorDatabase,
      $ProgressDimensionsTable,
      ProgressDimension,
      $$ProgressDimensionsTableFilterComposer,
      $$ProgressDimensionsTableOrderingComposer,
      $$ProgressDimensionsTableAnnotationComposer,
      $$ProgressDimensionsTableCreateCompanionBuilder,
      $$ProgressDimensionsTableUpdateCompanionBuilder,
      (
        ProgressDimension,
        BaseReferences<
          _$AnchorDatabase,
          $ProgressDimensionsTable,
          ProgressDimension
        >,
      ),
      ProgressDimension,
      PrefetchHooks Function()
    >;
typedef $$ProgressValuesTableCreateCompanionBuilder =
    ProgressValuesCompanion Function({
      required String id,
      required String dimensionId,
      required DateTime date,
      Value<double> value,
      Value<int> rowid,
    });
typedef $$ProgressValuesTableUpdateCompanionBuilder =
    ProgressValuesCompanion Function({
      Value<String> id,
      Value<String> dimensionId,
      Value<DateTime> date,
      Value<double> value,
      Value<int> rowid,
    });

class $$ProgressValuesTableFilterComposer
    extends Composer<_$AnchorDatabase, $ProgressValuesTable> {
  $$ProgressValuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dimensionId => $composableBuilder(
    column: $table.dimensionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProgressValuesTableOrderingComposer
    extends Composer<_$AnchorDatabase, $ProgressValuesTable> {
  $$ProgressValuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dimensionId => $composableBuilder(
    column: $table.dimensionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProgressValuesTableAnnotationComposer
    extends Composer<_$AnchorDatabase, $ProgressValuesTable> {
  $$ProgressValuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dimensionId => $composableBuilder(
    column: $table.dimensionId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$ProgressValuesTableTableManager
    extends
        RootTableManager<
          _$AnchorDatabase,
          $ProgressValuesTable,
          ProgressValue,
          $$ProgressValuesTableFilterComposer,
          $$ProgressValuesTableOrderingComposer,
          $$ProgressValuesTableAnnotationComposer,
          $$ProgressValuesTableCreateCompanionBuilder,
          $$ProgressValuesTableUpdateCompanionBuilder,
          (
            ProgressValue,
            BaseReferences<
              _$AnchorDatabase,
              $ProgressValuesTable,
              ProgressValue
            >,
          ),
          ProgressValue,
          PrefetchHooks Function()
        > {
  $$ProgressValuesTableTableManager(
    _$AnchorDatabase db,
    $ProgressValuesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProgressValuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProgressValuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProgressValuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> dimensionId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProgressValuesCompanion(
                id: id,
                dimensionId: dimensionId,
                date: date,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String dimensionId,
                required DateTime date,
                Value<double> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProgressValuesCompanion.insert(
                id: id,
                dimensionId: dimensionId,
                date: date,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProgressValuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AnchorDatabase,
      $ProgressValuesTable,
      ProgressValue,
      $$ProgressValuesTableFilterComposer,
      $$ProgressValuesTableOrderingComposer,
      $$ProgressValuesTableAnnotationComposer,
      $$ProgressValuesTableCreateCompanionBuilder,
      $$ProgressValuesTableUpdateCompanionBuilder,
      (
        ProgressValue,
        BaseReferences<_$AnchorDatabase, $ProgressValuesTable, ProgressValue>,
      ),
      ProgressValue,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String id,
      Value<String?> userName,
      Value<DateTime?> independenceDate,
      Value<String?> independenceLabel,
      Value<int> distractionLimitMinutes,
      Value<int> screenTimeResetHour,
      Value<String?> todoistApiToken,
      Value<String?> geminiApiKey,
      Value<String?> weatherCity,
      Value<double?> weatherLat,
      Value<double?> weatherLon,
      Value<String> newsCategory,
      Value<bool> showPersistentWidget,
      Value<bool> launchOnStartup,
      Value<bool> whatsappDigestEnabled,
      Value<DateTime?> lastDigestAt,
      Value<String> geminiModel,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> id,
      Value<String?> userName,
      Value<DateTime?> independenceDate,
      Value<String?> independenceLabel,
      Value<int> distractionLimitMinutes,
      Value<int> screenTimeResetHour,
      Value<String?> todoistApiToken,
      Value<String?> geminiApiKey,
      Value<String?> weatherCity,
      Value<double?> weatherLat,
      Value<double?> weatherLon,
      Value<String> newsCategory,
      Value<bool> showPersistentWidget,
      Value<bool> launchOnStartup,
      Value<bool> whatsappDigestEnabled,
      Value<DateTime?> lastDigestAt,
      Value<String> geminiModel,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AnchorDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userName => $composableBuilder(
    column: $table.userName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get independenceDate => $composableBuilder(
    column: $table.independenceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get independenceLabel => $composableBuilder(
    column: $table.independenceLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get distractionLimitMinutes => $composableBuilder(
    column: $table.distractionLimitMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get screenTimeResetHour => $composableBuilder(
    column: $table.screenTimeResetHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get todoistApiToken => $composableBuilder(
    column: $table.todoistApiToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get geminiApiKey => $composableBuilder(
    column: $table.geminiApiKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weatherCity => $composableBuilder(
    column: $table.weatherCity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weatherLat => $composableBuilder(
    column: $table.weatherLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weatherLon => $composableBuilder(
    column: $table.weatherLon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get newsCategory => $composableBuilder(
    column: $table.newsCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showPersistentWidget => $composableBuilder(
    column: $table.showPersistentWidget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get launchOnStartup => $composableBuilder(
    column: $table.launchOnStartup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get whatsappDigestEnabled => $composableBuilder(
    column: $table.whatsappDigestEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastDigestAt => $composableBuilder(
    column: $table.lastDigestAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get geminiModel => $composableBuilder(
    column: $table.geminiModel,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AnchorDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userName => $composableBuilder(
    column: $table.userName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get independenceDate => $composableBuilder(
    column: $table.independenceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get independenceLabel => $composableBuilder(
    column: $table.independenceLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get distractionLimitMinutes => $composableBuilder(
    column: $table.distractionLimitMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get screenTimeResetHour => $composableBuilder(
    column: $table.screenTimeResetHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get todoistApiToken => $composableBuilder(
    column: $table.todoistApiToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get geminiApiKey => $composableBuilder(
    column: $table.geminiApiKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weatherCity => $composableBuilder(
    column: $table.weatherCity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weatherLat => $composableBuilder(
    column: $table.weatherLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weatherLon => $composableBuilder(
    column: $table.weatherLon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get newsCategory => $composableBuilder(
    column: $table.newsCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showPersistentWidget => $composableBuilder(
    column: $table.showPersistentWidget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get launchOnStartup => $composableBuilder(
    column: $table.launchOnStartup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get whatsappDigestEnabled => $composableBuilder(
    column: $table.whatsappDigestEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastDigestAt => $composableBuilder(
    column: $table.lastDigestAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get geminiModel => $composableBuilder(
    column: $table.geminiModel,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AnchorDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userName =>
      $composableBuilder(column: $table.userName, builder: (column) => column);

  GeneratedColumn<DateTime> get independenceDate => $composableBuilder(
    column: $table.independenceDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get independenceLabel => $composableBuilder(
    column: $table.independenceLabel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get distractionLimitMinutes => $composableBuilder(
    column: $table.distractionLimitMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get screenTimeResetHour => $composableBuilder(
    column: $table.screenTimeResetHour,
    builder: (column) => column,
  );

  GeneratedColumn<String> get todoistApiToken => $composableBuilder(
    column: $table.todoistApiToken,
    builder: (column) => column,
  );

  GeneratedColumn<String> get geminiApiKey => $composableBuilder(
    column: $table.geminiApiKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weatherCity => $composableBuilder(
    column: $table.weatherCity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weatherLat => $composableBuilder(
    column: $table.weatherLat,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weatherLon => $composableBuilder(
    column: $table.weatherLon,
    builder: (column) => column,
  );

  GeneratedColumn<String> get newsCategory => $composableBuilder(
    column: $table.newsCategory,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showPersistentWidget => $composableBuilder(
    column: $table.showPersistentWidget,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get launchOnStartup => $composableBuilder(
    column: $table.launchOnStartup,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get whatsappDigestEnabled => $composableBuilder(
    column: $table.whatsappDigestEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastDigestAt => $composableBuilder(
    column: $table.lastDigestAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get geminiModel => $composableBuilder(
    column: $table.geminiModel,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AnchorDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AnchorDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AnchorDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userName = const Value.absent(),
                Value<DateTime?> independenceDate = const Value.absent(),
                Value<String?> independenceLabel = const Value.absent(),
                Value<int> distractionLimitMinutes = const Value.absent(),
                Value<int> screenTimeResetHour = const Value.absent(),
                Value<String?> todoistApiToken = const Value.absent(),
                Value<String?> geminiApiKey = const Value.absent(),
                Value<String?> weatherCity = const Value.absent(),
                Value<double?> weatherLat = const Value.absent(),
                Value<double?> weatherLon = const Value.absent(),
                Value<String> newsCategory = const Value.absent(),
                Value<bool> showPersistentWidget = const Value.absent(),
                Value<bool> launchOnStartup = const Value.absent(),
                Value<bool> whatsappDigestEnabled = const Value.absent(),
                Value<DateTime?> lastDigestAt = const Value.absent(),
                Value<String> geminiModel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                userName: userName,
                independenceDate: independenceDate,
                independenceLabel: independenceLabel,
                distractionLimitMinutes: distractionLimitMinutes,
                screenTimeResetHour: screenTimeResetHour,
                todoistApiToken: todoistApiToken,
                geminiApiKey: geminiApiKey,
                weatherCity: weatherCity,
                weatherLat: weatherLat,
                weatherLon: weatherLon,
                newsCategory: newsCategory,
                showPersistentWidget: showPersistentWidget,
                launchOnStartup: launchOnStartup,
                whatsappDigestEnabled: whatsappDigestEnabled,
                lastDigestAt: lastDigestAt,
                geminiModel: geminiModel,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> userName = const Value.absent(),
                Value<DateTime?> independenceDate = const Value.absent(),
                Value<String?> independenceLabel = const Value.absent(),
                Value<int> distractionLimitMinutes = const Value.absent(),
                Value<int> screenTimeResetHour = const Value.absent(),
                Value<String?> todoistApiToken = const Value.absent(),
                Value<String?> geminiApiKey = const Value.absent(),
                Value<String?> weatherCity = const Value.absent(),
                Value<double?> weatherLat = const Value.absent(),
                Value<double?> weatherLon = const Value.absent(),
                Value<String> newsCategory = const Value.absent(),
                Value<bool> showPersistentWidget = const Value.absent(),
                Value<bool> launchOnStartup = const Value.absent(),
                Value<bool> whatsappDigestEnabled = const Value.absent(),
                Value<DateTime?> lastDigestAt = const Value.absent(),
                Value<String> geminiModel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                userName: userName,
                independenceDate: independenceDate,
                independenceLabel: independenceLabel,
                distractionLimitMinutes: distractionLimitMinutes,
                screenTimeResetHour: screenTimeResetHour,
                todoistApiToken: todoistApiToken,
                geminiApiKey: geminiApiKey,
                weatherCity: weatherCity,
                weatherLat: weatherLat,
                weatherLon: weatherLon,
                newsCategory: newsCategory,
                showPersistentWidget: showPersistentWidget,
                launchOnStartup: launchOnStartup,
                whatsappDigestEnabled: whatsappDigestEnabled,
                lastDigestAt: lastDigestAt,
                geminiModel: geminiModel,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AnchorDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AnchorDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$ScreenTimeSessionsTableCreateCompanionBuilder =
    ScreenTimeSessionsCompanion Function({
      required String id,
      required DateTime date,
      required String appName,
      Value<String> category,
      required DateTime startTime,
      Value<DateTime?> endTime,
      Value<int> durationSeconds,
      Value<int> rowid,
    });
typedef $$ScreenTimeSessionsTableUpdateCompanionBuilder =
    ScreenTimeSessionsCompanion Function({
      Value<String> id,
      Value<DateTime> date,
      Value<String> appName,
      Value<String> category,
      Value<DateTime> startTime,
      Value<DateTime?> endTime,
      Value<int> durationSeconds,
      Value<int> rowid,
    });

class $$ScreenTimeSessionsTableFilterComposer
    extends Composer<_$AnchorDatabase, $ScreenTimeSessionsTable> {
  $$ScreenTimeSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appName => $composableBuilder(
    column: $table.appName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScreenTimeSessionsTableOrderingComposer
    extends Composer<_$AnchorDatabase, $ScreenTimeSessionsTable> {
  $$ScreenTimeSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appName => $composableBuilder(
    column: $table.appName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScreenTimeSessionsTableAnnotationComposer
    extends Composer<_$AnchorDatabase, $ScreenTimeSessionsTable> {
  $$ScreenTimeSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get appName =>
      $composableBuilder(column: $table.appName, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );
}

class $$ScreenTimeSessionsTableTableManager
    extends
        RootTableManager<
          _$AnchorDatabase,
          $ScreenTimeSessionsTable,
          ScreenTimeSession,
          $$ScreenTimeSessionsTableFilterComposer,
          $$ScreenTimeSessionsTableOrderingComposer,
          $$ScreenTimeSessionsTableAnnotationComposer,
          $$ScreenTimeSessionsTableCreateCompanionBuilder,
          $$ScreenTimeSessionsTableUpdateCompanionBuilder,
          (
            ScreenTimeSession,
            BaseReferences<
              _$AnchorDatabase,
              $ScreenTimeSessionsTable,
              ScreenTimeSession
            >,
          ),
          ScreenTimeSession,
          PrefetchHooks Function()
        > {
  $$ScreenTimeSessionsTableTableManager(
    _$AnchorDatabase db,
    $ScreenTimeSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScreenTimeSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScreenTimeSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScreenTimeSessionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> appName = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<DateTime> startTime = const Value.absent(),
                Value<DateTime?> endTime = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScreenTimeSessionsCompanion(
                id: id,
                date: date,
                appName: appName,
                category: category,
                startTime: startTime,
                endTime: endTime,
                durationSeconds: durationSeconds,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime date,
                required String appName,
                Value<String> category = const Value.absent(),
                required DateTime startTime,
                Value<DateTime?> endTime = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScreenTimeSessionsCompanion.insert(
                id: id,
                date: date,
                appName: appName,
                category: category,
                startTime: startTime,
                endTime: endTime,
                durationSeconds: durationSeconds,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScreenTimeSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AnchorDatabase,
      $ScreenTimeSessionsTable,
      ScreenTimeSession,
      $$ScreenTimeSessionsTableFilterComposer,
      $$ScreenTimeSessionsTableOrderingComposer,
      $$ScreenTimeSessionsTableAnnotationComposer,
      $$ScreenTimeSessionsTableCreateCompanionBuilder,
      $$ScreenTimeSessionsTableUpdateCompanionBuilder,
      (
        ScreenTimeSession,
        BaseReferences<
          _$AnchorDatabase,
          $ScreenTimeSessionsTable,
          ScreenTimeSession
        >,
      ),
      ScreenTimeSession,
      PrefetchHooks Function()
    >;
typedef $$AppCategoriesTableCreateCompanionBuilder =
    AppCategoriesCompanion Function({
      required String appName,
      required String category,
      Value<int> rowid,
    });
typedef $$AppCategoriesTableUpdateCompanionBuilder =
    AppCategoriesCompanion Function({
      Value<String> appName,
      Value<String> category,
      Value<int> rowid,
    });

class $$AppCategoriesTableFilterComposer
    extends Composer<_$AnchorDatabase, $AppCategoriesTable> {
  $$AppCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get appName => $composableBuilder(
    column: $table.appName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppCategoriesTableOrderingComposer
    extends Composer<_$AnchorDatabase, $AppCategoriesTable> {
  $$AppCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get appName => $composableBuilder(
    column: $table.appName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppCategoriesTableAnnotationComposer
    extends Composer<_$AnchorDatabase, $AppCategoriesTable> {
  $$AppCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get appName =>
      $composableBuilder(column: $table.appName, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);
}

class $$AppCategoriesTableTableManager
    extends
        RootTableManager<
          _$AnchorDatabase,
          $AppCategoriesTable,
          AppCategory,
          $$AppCategoriesTableFilterComposer,
          $$AppCategoriesTableOrderingComposer,
          $$AppCategoriesTableAnnotationComposer,
          $$AppCategoriesTableCreateCompanionBuilder,
          $$AppCategoriesTableUpdateCompanionBuilder,
          (
            AppCategory,
            BaseReferences<_$AnchorDatabase, $AppCategoriesTable, AppCategory>,
          ),
          AppCategory,
          PrefetchHooks Function()
        > {
  $$AppCategoriesTableTableManager(
    _$AnchorDatabase db,
    $AppCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> appName = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppCategoriesCompanion(
                appName: appName,
                category: category,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String appName,
                required String category,
                Value<int> rowid = const Value.absent(),
              }) => AppCategoriesCompanion.insert(
                appName: appName,
                category: category,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AnchorDatabase,
      $AppCategoriesTable,
      AppCategory,
      $$AppCategoriesTableFilterComposer,
      $$AppCategoriesTableOrderingComposer,
      $$AppCategoriesTableAnnotationComposer,
      $$AppCategoriesTableCreateCompanionBuilder,
      $$AppCategoriesTableUpdateCompanionBuilder,
      (
        AppCategory,
        BaseReferences<_$AnchorDatabase, $AppCategoriesTable, AppCategory>,
      ),
      AppCategory,
      PrefetchHooks Function()
    >;
typedef $$ChatMessagesTableCreateCompanionBuilder =
    ChatMessagesCompanion Function({
      required String id,
      required String content,
      required bool isUser,
      required DateTime timestamp,
      required String sessionId,
      Value<String?> todoistTaskId,
      Value<int> rowid,
    });
typedef $$ChatMessagesTableUpdateCompanionBuilder =
    ChatMessagesCompanion Function({
      Value<String> id,
      Value<String> content,
      Value<bool> isUser,
      Value<DateTime> timestamp,
      Value<String> sessionId,
      Value<String?> todoistTaskId,
      Value<int> rowid,
    });

class $$ChatMessagesTableFilterComposer
    extends Composer<_$AnchorDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isUser => $composableBuilder(
    column: $table.isUser,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get todoistTaskId => $composableBuilder(
    column: $table.todoistTaskId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChatMessagesTableOrderingComposer
    extends Composer<_$AnchorDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isUser => $composableBuilder(
    column: $table.isUser,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get todoistTaskId => $composableBuilder(
    column: $table.todoistTaskId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatMessagesTableAnnotationComposer
    extends Composer<_$AnchorDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<bool> get isUser =>
      $composableBuilder(column: $table.isUser, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get todoistTaskId => $composableBuilder(
    column: $table.todoistTaskId,
    builder: (column) => column,
  );
}

class $$ChatMessagesTableTableManager
    extends
        RootTableManager<
          _$AnchorDatabase,
          $ChatMessagesTable,
          ChatMessage,
          $$ChatMessagesTableFilterComposer,
          $$ChatMessagesTableOrderingComposer,
          $$ChatMessagesTableAnnotationComposer,
          $$ChatMessagesTableCreateCompanionBuilder,
          $$ChatMessagesTableUpdateCompanionBuilder,
          (
            ChatMessage,
            BaseReferences<_$AnchorDatabase, $ChatMessagesTable, ChatMessage>,
          ),
          ChatMessage,
          PrefetchHooks Function()
        > {
  $$ChatMessagesTableTableManager(_$AnchorDatabase db, $ChatMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<bool> isUser = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String?> todoistTaskId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatMessagesCompanion(
                id: id,
                content: content,
                isUser: isUser,
                timestamp: timestamp,
                sessionId: sessionId,
                todoistTaskId: todoistTaskId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String content,
                required bool isUser,
                required DateTime timestamp,
                required String sessionId,
                Value<String?> todoistTaskId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatMessagesCompanion.insert(
                id: id,
                content: content,
                isUser: isUser,
                timestamp: timestamp,
                sessionId: sessionId,
                todoistTaskId: todoistTaskId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AnchorDatabase,
      $ChatMessagesTable,
      ChatMessage,
      $$ChatMessagesTableFilterComposer,
      $$ChatMessagesTableOrderingComposer,
      $$ChatMessagesTableAnnotationComposer,
      $$ChatMessagesTableCreateCompanionBuilder,
      $$ChatMessagesTableUpdateCompanionBuilder,
      (
        ChatMessage,
        BaseReferences<_$AnchorDatabase, $ChatMessagesTable, ChatMessage>,
      ),
      ChatMessage,
      PrefetchHooks Function()
    >;
typedef $$WhatsappDigestsTableCreateCompanionBuilder =
    WhatsappDigestsCompanion Function({
      required String id,
      required String groupName,
      Value<String?> groupJid,
      required String rawMessages,
      required String summary,
      required DateTime digestDate,
      Value<String?> todoistTaskId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$WhatsappDigestsTableUpdateCompanionBuilder =
    WhatsappDigestsCompanion Function({
      Value<String> id,
      Value<String> groupName,
      Value<String?> groupJid,
      Value<String> rawMessages,
      Value<String> summary,
      Value<DateTime> digestDate,
      Value<String?> todoistTaskId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$WhatsappDigestsTableFilterComposer
    extends Composer<_$AnchorDatabase, $WhatsappDigestsTable> {
  $$WhatsappDigestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupName => $composableBuilder(
    column: $table.groupName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupJid => $composableBuilder(
    column: $table.groupJid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawMessages => $composableBuilder(
    column: $table.rawMessages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get digestDate => $composableBuilder(
    column: $table.digestDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get todoistTaskId => $composableBuilder(
    column: $table.todoistTaskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WhatsappDigestsTableOrderingComposer
    extends Composer<_$AnchorDatabase, $WhatsappDigestsTable> {
  $$WhatsappDigestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupName => $composableBuilder(
    column: $table.groupName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupJid => $composableBuilder(
    column: $table.groupJid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawMessages => $composableBuilder(
    column: $table.rawMessages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get digestDate => $composableBuilder(
    column: $table.digestDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get todoistTaskId => $composableBuilder(
    column: $table.todoistTaskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WhatsappDigestsTableAnnotationComposer
    extends Composer<_$AnchorDatabase, $WhatsappDigestsTable> {
  $$WhatsappDigestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get groupName =>
      $composableBuilder(column: $table.groupName, builder: (column) => column);

  GeneratedColumn<String> get groupJid =>
      $composableBuilder(column: $table.groupJid, builder: (column) => column);

  GeneratedColumn<String> get rawMessages => $composableBuilder(
    column: $table.rawMessages,
    builder: (column) => column,
  );

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<DateTime> get digestDate => $composableBuilder(
    column: $table.digestDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get todoistTaskId => $composableBuilder(
    column: $table.todoistTaskId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$WhatsappDigestsTableTableManager
    extends
        RootTableManager<
          _$AnchorDatabase,
          $WhatsappDigestsTable,
          WhatsappDigest,
          $$WhatsappDigestsTableFilterComposer,
          $$WhatsappDigestsTableOrderingComposer,
          $$WhatsappDigestsTableAnnotationComposer,
          $$WhatsappDigestsTableCreateCompanionBuilder,
          $$WhatsappDigestsTableUpdateCompanionBuilder,
          (
            WhatsappDigest,
            BaseReferences<
              _$AnchorDatabase,
              $WhatsappDigestsTable,
              WhatsappDigest
            >,
          ),
          WhatsappDigest,
          PrefetchHooks Function()
        > {
  $$WhatsappDigestsTableTableManager(
    _$AnchorDatabase db,
    $WhatsappDigestsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WhatsappDigestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WhatsappDigestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WhatsappDigestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> groupName = const Value.absent(),
                Value<String?> groupJid = const Value.absent(),
                Value<String> rawMessages = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<DateTime> digestDate = const Value.absent(),
                Value<String?> todoistTaskId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WhatsappDigestsCompanion(
                id: id,
                groupName: groupName,
                groupJid: groupJid,
                rawMessages: rawMessages,
                summary: summary,
                digestDate: digestDate,
                todoistTaskId: todoistTaskId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String groupName,
                Value<String?> groupJid = const Value.absent(),
                required String rawMessages,
                required String summary,
                required DateTime digestDate,
                Value<String?> todoistTaskId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WhatsappDigestsCompanion.insert(
                id: id,
                groupName: groupName,
                groupJid: groupJid,
                rawMessages: rawMessages,
                summary: summary,
                digestDate: digestDate,
                todoistTaskId: todoistTaskId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WhatsappDigestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AnchorDatabase,
      $WhatsappDigestsTable,
      WhatsappDigest,
      $$WhatsappDigestsTableFilterComposer,
      $$WhatsappDigestsTableOrderingComposer,
      $$WhatsappDigestsTableAnnotationComposer,
      $$WhatsappDigestsTableCreateCompanionBuilder,
      $$WhatsappDigestsTableUpdateCompanionBuilder,
      (
        WhatsappDigest,
        BaseReferences<_$AnchorDatabase, $WhatsappDigestsTable, WhatsappDigest>,
      ),
      WhatsappDigest,
      PrefetchHooks Function()
    >;
typedef $$WhatsappGroupsTableCreateCompanionBuilder =
    WhatsappGroupsCompanion Function({
      required String jid,
      required String name,
      Value<bool> isTracked,
      Value<int> participantCount,
      Value<DateTime?> lastDigestAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$WhatsappGroupsTableUpdateCompanionBuilder =
    WhatsappGroupsCompanion Function({
      Value<String> jid,
      Value<String> name,
      Value<bool> isTracked,
      Value<int> participantCount,
      Value<DateTime?> lastDigestAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$WhatsappGroupsTableFilterComposer
    extends Composer<_$AnchorDatabase, $WhatsappGroupsTable> {
  $$WhatsappGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get jid => $composableBuilder(
    column: $table.jid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTracked => $composableBuilder(
    column: $table.isTracked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get participantCount => $composableBuilder(
    column: $table.participantCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastDigestAt => $composableBuilder(
    column: $table.lastDigestAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WhatsappGroupsTableOrderingComposer
    extends Composer<_$AnchorDatabase, $WhatsappGroupsTable> {
  $$WhatsappGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get jid => $composableBuilder(
    column: $table.jid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTracked => $composableBuilder(
    column: $table.isTracked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get participantCount => $composableBuilder(
    column: $table.participantCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastDigestAt => $composableBuilder(
    column: $table.lastDigestAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WhatsappGroupsTableAnnotationComposer
    extends Composer<_$AnchorDatabase, $WhatsappGroupsTable> {
  $$WhatsappGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get jid =>
      $composableBuilder(column: $table.jid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isTracked =>
      $composableBuilder(column: $table.isTracked, builder: (column) => column);

  GeneratedColumn<int> get participantCount => $composableBuilder(
    column: $table.participantCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastDigestAt => $composableBuilder(
    column: $table.lastDigestAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$WhatsappGroupsTableTableManager
    extends
        RootTableManager<
          _$AnchorDatabase,
          $WhatsappGroupsTable,
          WhatsappGroup,
          $$WhatsappGroupsTableFilterComposer,
          $$WhatsappGroupsTableOrderingComposer,
          $$WhatsappGroupsTableAnnotationComposer,
          $$WhatsappGroupsTableCreateCompanionBuilder,
          $$WhatsappGroupsTableUpdateCompanionBuilder,
          (
            WhatsappGroup,
            BaseReferences<
              _$AnchorDatabase,
              $WhatsappGroupsTable,
              WhatsappGroup
            >,
          ),
          WhatsappGroup,
          PrefetchHooks Function()
        > {
  $$WhatsappGroupsTableTableManager(
    _$AnchorDatabase db,
    $WhatsappGroupsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WhatsappGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WhatsappGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WhatsappGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> jid = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isTracked = const Value.absent(),
                Value<int> participantCount = const Value.absent(),
                Value<DateTime?> lastDigestAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WhatsappGroupsCompanion(
                jid: jid,
                name: name,
                isTracked: isTracked,
                participantCount: participantCount,
                lastDigestAt: lastDigestAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String jid,
                required String name,
                Value<bool> isTracked = const Value.absent(),
                Value<int> participantCount = const Value.absent(),
                Value<DateTime?> lastDigestAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WhatsappGroupsCompanion.insert(
                jid: jid,
                name: name,
                isTracked: isTracked,
                participantCount: participantCount,
                lastDigestAt: lastDigestAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WhatsappGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AnchorDatabase,
      $WhatsappGroupsTable,
      WhatsappGroup,
      $$WhatsappGroupsTableFilterComposer,
      $$WhatsappGroupsTableOrderingComposer,
      $$WhatsappGroupsTableAnnotationComposer,
      $$WhatsappGroupsTableCreateCompanionBuilder,
      $$WhatsappGroupsTableUpdateCompanionBuilder,
      (
        WhatsappGroup,
        BaseReferences<_$AnchorDatabase, $WhatsappGroupsTable, WhatsappGroup>,
      ),
      WhatsappGroup,
      PrefetchHooks Function()
    >;

class $AnchorDatabaseManager {
  final _$AnchorDatabase _db;
  $AnchorDatabaseManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$JournalEntriesTableTableManager get journalEntries =>
      $$JournalEntriesTableTableManager(_db, _db.journalEntries);
  $$ProgressDimensionsTableTableManager get progressDimensions =>
      $$ProgressDimensionsTableTableManager(_db, _db.progressDimensions);
  $$ProgressValuesTableTableManager get progressValues =>
      $$ProgressValuesTableTableManager(_db, _db.progressValues);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$ScreenTimeSessionsTableTableManager get screenTimeSessions =>
      $$ScreenTimeSessionsTableTableManager(_db, _db.screenTimeSessions);
  $$AppCategoriesTableTableManager get appCategories =>
      $$AppCategoriesTableTableManager(_db, _db.appCategories);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
  $$WhatsappDigestsTableTableManager get whatsappDigests =>
      $$WhatsappDigestsTableTableManager(_db, _db.whatsappDigests);
  $$WhatsappGroupsTableTableManager get whatsappGroups =>
      $$WhatsappGroupsTableTableManager(_db, _db.whatsappGroups);
}
