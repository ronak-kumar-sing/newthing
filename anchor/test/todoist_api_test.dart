import 'package:anchor/data/remote/todoist_api.dart';

/// Standalone test for Todoist API integration.
/// Run with: dart test/test_todoist_api.dart
void main() async {
  print('═' * 60);
  print('TODOIST API TEST');
  print('═' * 60);

  final api = TodoistApi();

  // Set the token from .env
  const token = 'be425c09ad6c2fca2515632369d1f247200f04f2';
  api.setToken(token);

  print('\n1. Testing authentication...');
  print('   Token set: ${api.isAuthenticated}');

  print('\n2. Fetching projects...');
  final projects = await api.getProjects();
  print('   Found ${projects.length} projects:');
  for (final p in projects) {
    print('   • ${p['name']} (ID: ${p['id']})');
  }

  print('\n3. Fetching labels...');
  final labels = await api.getLabels();
  print('   Found ${labels.length} labels:');
  for (final l in labels) {
    print('   • ${l['name']}');
  }

  print('\n4. Fetching active tasks...');
  final tasks = await api.getTasks();
  print('   Found ${tasks.length} active tasks:');
  for (final t in tasks) {
    print('   • ${t.title} [${t.priorityLabel}]${t.dueDate != null ? ' (Due: ${t.dueDate!.toIso8601String().split('T').first})' : ''}');
  }

  print('\n5. Fetching tasks by project...');
  if (projects.isNotEmpty) {
    final projectTasks = await api.getTasksByProject(projects.first['id'].toString());
    print('   Found ${projectTasks.length} tasks in "${projects.first['name']}"');
  }

  print('\n' + '═' * 60);
  print('TEST COMPLETE');
  print('═' * 60);
}
