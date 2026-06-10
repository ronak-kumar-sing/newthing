import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../models/task_model.dart';

/// Todoist REST API v1 client.
class TodoistApi {
  final Dio _dio;
  String? _apiToken;

  TodoistApi({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(
    baseUrl: 'https://api.todoist.com/api/v1',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  /// Set the API token for authentication.
  void setToken(String token) {
    _apiToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Check if authenticated.
  bool get isAuthenticated => _apiToken != null && _apiToken!.isNotEmpty;

  /// Test connectivity — fetches 1 task, returns true on success.
  Future<bool> testConnection() async {
    if (!isAuthenticated) return false;
    try {
      final response = await _dio.get(
        '/tasks',
        queryParameters: {'limit': 1},
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Todoist testConnection error: $e');
      return false;
    }
  }

  /// Extract results array from paginated v1 response.
  List<dynamic> _extractResults(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('results')) {
      return data['results'] as List<dynamic>;
    }
    if (data is List) return data;
    return [];
  }

  /// Get all active tasks.
  Future<List<TaskModel>> getTasks() async {
    if (!isAuthenticated) return [];
    try {
      final response = await _dio.get('/tasks');
      final results = _extractResults(response);
      return results.map((json) => _mapTodoistTask(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Todoist getTasks error: $e');
      return [];
    }
  }

  /// Get tasks by project ID.
  Future<List<TaskModel>> getTasksByProject(String projectId) async {
    if (!isAuthenticated) return [];
    try {
      final response = await _dio.get('/tasks', queryParameters: {'project_id': projectId});
      final results = _extractResults(response);
      return results.map((json) => _mapTodoistTask(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Todoist getTasksByProject error: $e');
      return [];
    }
  }

  /// Create a new task.
  Future<TaskModel?> createTask({
    required String title,
    String? description,
    DateTime? dueDate,
    int priority = 4,
    String? projectId,
    List<String> labels = const [],
  }) async {
    if (!isAuthenticated) return null;
    try {
      final body = <String, dynamic>{
        'content': title,
        'priority': priority,
        if (description != null) 'description': description,
        if (dueDate != null) 'due_date': _formatDate(dueDate),
        if (projectId != null) 'project_id': projectId,
        if (labels.isNotEmpty) 'labels': labels,
      };
      final response = await _dio.post('/tasks', data: body);
      return _mapTodoistTask(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Todoist createTask error: $e');
      return null;
    }
  }

  /// Update an existing task.
  Future<bool> updateTask({
    required String todoistId,
    String? title,
    String? description,
    DateTime? dueDate,
    int? priority,
    List<String>? labels,
  }) async {
    if (!isAuthenticated) return false;
    try {
      final body = <String, dynamic>{
        if (title != null) 'content': title,
        if (description != null) 'description': description,
        if (dueDate != null) 'due_date': _formatDate(dueDate),
        if (priority != null) 'priority': priority,
        if (labels != null) 'labels': labels,
      };
      await _dio.post('/tasks/$todoistId', data: body);
      return true;
    } catch (e) {
      debugPrint('Todoist updateTask error: $e');
      return false;
    }
  }

  /// Close (complete) a task.
  Future<bool> closeTask(String todoistId) async {
    if (!isAuthenticated) return false;
    try {
      await _dio.post('/tasks/$todoistId/close');
      return true;
    } catch (e) {
      debugPrint('Todoist closeTask error: $e');
      return false;
    }
  }

  /// Reopen a completed task.
  Future<bool> reopenTask(String todoistId) async {
    if (!isAuthenticated) return false;
    try {
      await _dio.post('/tasks/$todoistId/reopen');
      return true;
    } catch (e) {
      debugPrint('Todoist reopenTask error: $e');
      return false;
    }
  }

  /// Delete a task.
  Future<bool> deleteTask(String todoistId) async {
    if (!isAuthenticated) return false;
    try {
      await _dio.delete('/tasks/$todoistId');
      return true;
    } catch (e) {
      debugPrint('Todoist deleteTask error: $e');
      return false;
    }
  }

  /// Get all projects.
  Future<List<Map<String, dynamic>>> getProjects() async {
    if (!isAuthenticated) return [];
    try {
      final response = await _dio.get('/projects');
      final results = _extractResults(response);
      return results.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Todoist getProjects error: $e');
      return [];
    }
  }

  /// Create a new project, returns its ID.
  Future<Map<String, dynamic>?> createProject({
    required String name,
    String color = 'grape',
  }) async {
    if (!isAuthenticated) return null;
    try {
      final response = await _dio.post('/projects', data: {
        'name': name,
        'color': color,
      });
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Todoist createProject error: $e');
      return null;
    }
  }

  /// Find a project by name, returns its ID or null.
  Future<String?> findProjectByName(String name) async {
    final projects = await getProjects();
    for (final project in projects) {
      if (project['name'] == name) return project['id']?.toString();
    }
    return null;
  }

  /// Ensure a project exists, creating it if needed. Returns project ID.
  Future<String?> getOrCreateProject(String name) async {
    final existing = await findProjectByName(name);
    if (existing != null) return existing;
    final created = await createProject(name: name);
    return created?['id']?.toString();
  }

  /// Add a comment to a task.
  Future<bool> addComment({
    required String taskId,
    required String content,
  }) async {
    if (!isAuthenticated) return false;
    try {
      await _dio.post('/comments', data: {
        'task_id': taskId,
        'content': content,
      });
      return true;
    } catch (e) {
      debugPrint('Todoist addComment error: $e');
      return false;
    }
  }

  /// Get all labels.
  Future<List<Map<String, dynamic>>> getLabels() async {
    if (!isAuthenticated) return [];
    try {
      final response = await _dio.get('/labels');
      final results = _extractResults(response);
      return results.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Todoist getLabels error: $e');
      return [];
    }
  }

  /// Map Todoist API response to TaskModel.
  TaskModel _mapTodoistTask(Map<String, dynamic> json) {
    final due = json['due'] as Map<String, dynamic>?;
    DateTime? dueDate;
    if (due != null) {
      final dateStr = due['date'] as String?;
      if (dateStr != null) {
        dueDate = DateTime.tryParse(dateStr);
      }
    }

    final labels = (json['labels'] as List<dynamic>?)?.cast<String>() ?? [];
    String? label;
    if (labels.isNotEmpty) label = labels.first;

    final todoistPriority = json['priority'] as int? ?? 4;

    return TaskModel(
      id: 'todoist_${json['id']}',
      title: json['content'] as String,
      description: json['description'] as String?,
      dueDate: dueDate,
      priority: todoistPriority,
      label: label,
      projectName: json['project_id']?.toString(),
      isCompleted: json['is_completed'] as bool? ?? false,
      source: 'todoist',
      todoistId: json['id']?.toString(),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
