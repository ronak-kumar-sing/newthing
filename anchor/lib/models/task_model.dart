/// A task in Anchor's domain model.
class TaskModel {
  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final int priority;
  final String? label;
  final String? projectName;
  final bool isCompleted;
  final DateTime? completedAt;
  final bool isRecurring;
  final String? recurringSchedule;
  final String source;
  final String? todoistId;

  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.priority = 4,
    this.label,
    this.projectName,
    this.isCompleted = false,
    this.completedAt,
    this.isRecurring = false,
    this.recurringSchedule,
    this.source = 'local',
    this.todoistId,
  });

  /// Priority label for display.
  String get priorityLabel {
    switch (priority) {
      case 1:
        return 'High';
      case 2:
        return 'Medium';
      case 3:
        return 'Low';
      default:
        return 'Normal';
    }
  }

  /// Whether task is overdue.
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    final now = DateTime.now();
    return dueDate!.isBefore(DateTime(now.year, now.month, now.day));
  }

  /// Whether task is due today.
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return dueDate!.year == today.year &&
        dueDate!.month == today.month &&
        dueDate!.day == today.day;
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    int? priority,
    String? label,
    String? projectName,
    bool? isCompleted,
    DateTime? completedAt,
    bool? isRecurring,
    String? recurringSchedule,
    String? source,
    String? todoistId,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      label: label ?? this.label,
      projectName: projectName ?? this.projectName,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringSchedule: recurringSchedule ?? this.recurringSchedule,
      source: source ?? this.source,
      todoistId: todoistId ?? this.todoistId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority,
      'label': label,
      'projectName': projectName,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'isRecurring': isRecurring,
      'recurringSchedule': recurringSchedule,
      'source': source,
      'todoistId': todoistId,
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      priority: json['priority'] as int? ?? 4,
      label: json['label'] as String?,
      projectName: json['projectName'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurringSchedule: json['recurringSchedule'] as String?,
      source: json['source'] as String? ?? 'local',
      todoistId: json['todoistId'] as String?,
    );
  }
}
