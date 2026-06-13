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

/// Top 10 tasks for today (for Morning Brief).
final topTasksProvider = FutureProvider<List<Task>>((ref) async {
  final dao = ref.watch(taskDaoProvider);
  return dao.getTopTasksForToday();
});

/// Task count by label.
final taskCountByLabelProvider = FutureProvider.family<int, String>((ref, label) async {
  final dao = ref.watch(taskDaoProvider);
  final tasks = await dao.getTasksByLabel(label);
  return tasks.length;
});
