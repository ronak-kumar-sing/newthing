import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/task_table.dart';

part 'task_dao.g.dart';

/// Data Access Object for task operations.
@DriftAccessor(tables: [Tasks])
class TaskDao extends DatabaseAccessor<AnchorDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  /// Get all active (non-completed) tasks, ordered by priority then due date.
  Future<List<Task>> getActiveTasks() {
    return (select(tasks)
      ..where((t) => t.isCompleted.equals(false))
      ..orderBy([
        (t) => OrderingTerm(expression: t.priority, mode: OrderingMode.asc),
        (t) => OrderingTerm(expression: t.dueDate, mode: OrderingMode.asc),
      ]))
        .get();
  }

  /// Get tasks due today.
  Future<List<Task>> getTasksDueToday() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return (select(tasks)
      ..where((t) => t.isCompleted.equals(false))
      ..where((t) => t.dueDate.isBetweenValues(start, end))
      ..orderBy([
        (t) => OrderingTerm(expression: t.priority, mode: OrderingMode.asc),
      ]))
        .get();
  }

  /// Get overdue tasks.
  Future<List<Task>> getOverdueTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return (select(tasks)
      ..where((t) => t.isCompleted.equals(false))
      ..where((t) => t.dueDate.isSmallerThanValue(today))
      ..orderBy([
        (t) => OrderingTerm(expression: t.dueDate, mode: OrderingMode.asc),
      ]))
        .get();
  }

  /// Get tasks due in the next N days.
  Future<List<Task>> getTasksDueInDays(int days) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(Duration(days: days));
    return (select(tasks)
      ..where((t) => t.isCompleted.equals(false))
      ..where((t) => t.dueDate.isBetweenValues(start, end))
      ..orderBy([
        (t) => OrderingTerm(expression: t.priority, mode: OrderingMode.asc),
        (t) => OrderingTerm(expression: t.dueDate, mode: OrderingMode.asc),
      ]))
        .get();
  }

  /// Get tasks by label.
  Future<List<Task>> getTasksByLabel(String label) {
    return (select(tasks)
      ..where((t) => t.label.equals(label))
      ..where((t) => t.isCompleted.equals(false))
      ..orderBy([
        (t) => OrderingTerm(expression: t.priority, mode: OrderingMode.asc),
      ]))
        .get();
  }

  /// Insert or update a task.
  Future<void> upsertTask(TasksCompanion task) {
    return into(tasks).insertOnConflictUpdate(task);
  }

  /// Mark a task as completed.
  Future<void> completeTask(String taskId) {
    return (update(tasks)..where((t) => t.id.equals(taskId)))
        .write(TasksCompanion(
      isCompleted: const Value(true),
      completedAt: Value(DateTime.now()),
    ));
  }

  /// Reopen a completed task.
  Future<void> reopenTask(String taskId) {
    return (update(tasks)..where((t) => t.id.equals(taskId)))
        .write(const TasksCompanion(
      isCompleted: Value(false),
      completedAt: Value.absent(),
    ));
  }

  /// Delete a task.
  Future<int> deleteTask(String taskId) {
    return (delete(tasks)..where((t) => t.id.equals(taskId))).go();
  }

  /// Get completion count for a date range.
  Future<int> getCompletedCount(DateTime start, DateTime end) {
    return (select(tasks)
      ..where((t) => t.isCompleted.equals(true))
      ..where((t) => t.completedAt.isBetweenValues(start, end)))
        .get()
        .then((list) => list.length);
  }

  /// Watch all active tasks (reactive stream).
  Stream<List<Task>> watchActiveTasks() {
    return (select(tasks)
      ..where((t) => t.isCompleted.equals(false))
      ..orderBy([
        (t) => OrderingTerm(expression: t.priority, mode: OrderingMode.asc),
        (t) => OrderingTerm(expression: t.dueDate, mode: OrderingMode.asc),
      ]))
        .watch();
  }

  /// Get top 3 tasks for today based on priority and due date.
  Future<List<Task>> getTopTasksForToday() async {
    final dueToday = await getTasksDueToday();
    if (dueToday.length >= 3) return dueToday.take(3).toList();

    final overdue = await getOverdueTasks();
    final combined = [...overdue, ...dueToday];
    if (combined.length >= 3) return combined.take(3).toList();

    final upcoming = await getTasksDueInDays(3);
    final all = [...combined, ...upcoming];
    return all.take(3).toList();
  }
}
