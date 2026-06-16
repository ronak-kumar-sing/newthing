import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/database.dart';
import 'database_provider.dart';

/// All active tasks (reactive stream).
final activeTasksProvider = StreamProvider<List<Task>>((ref) {
  final dao = ref.watch(taskDaoProvider);
  return dao.watchActiveTasks();
});

/// All completed tasks (reactive stream).
final completedTasksProvider = StreamProvider<List<Task>>((ref) {
  final dao = ref.watch(taskDaoProvider);
  return dao.watchCompletedTasks();
});

/// Tasks due today.
final tasksDueTodayProvider = FutureProvider<List<Task>>((ref) async {
  final dao = ref.watch(taskDaoProvider);
  return dao.getTasksDueToday();
});

/// Overdue tasks.
final overdueTasksProvider = FutureProvider<List<Task>>((ref) async {
  final dao = ref.watch(taskDaoProvider);
  return dao.getOverdueTasks();
});

/// Top 10 tasks for today (for Morning Brief), reactively updated.
final topTasksProvider = FutureProvider<List<Task>>((ref) async {
  final activeTasks = await ref.watch(activeTasksProvider.future);
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final todayEnd = todayStart.add(const Duration(days: 1));
  final nextWeekEnd = todayStart.add(const Duration(days: 7));

  // Filter tasks in memory:
  // 1. Overdue tasks: dueDate is before today
  final overdue = activeTasks.where((t) => t.dueDate != null && t.dueDate!.isBefore(todayStart)).toList();

  // 2. Today's tasks: dueDate is today
  final dueToday = activeTasks.where((t) => t.dueDate != null && 
      !t.dueDate!.isBefore(todayStart) && 
      t.dueDate!.isBefore(todayEnd)).toList();

  // 3. Upcoming tasks: dueDate is in the next 7 days (excluding today)
  final upcoming = activeTasks.where((t) => t.dueDate != null && 
      !t.dueDate!.isBefore(todayEnd) && 
      !t.dueDate!.isAfter(nextWeekEnd)).toList();

  // 4. Other tasks (no due date or due later than 7 days)
  final otherTasks = activeTasks.where((t) => 
      t.dueDate == null || 
      t.dueDate!.isAfter(nextWeekEnd)).toList();

  final combined = [...overdue, ...dueToday, ...upcoming, ...otherTasks];
  return combined.take(10).toList();
});

/// Task count by label.
final taskCountByLabelProvider = FutureProvider.family<int, String>((ref, label) async {
  final dao = ref.watch(taskDaoProvider);
  final tasks = await dao.getTasksByLabel(label);
  return tasks.length;
});
