import '../config/api_config.dart';
import '../models/task.dart';
import 'api_service.dart';

/// Service for task/calendar operations
class TaskService {
  final ApiService _api = ApiService();

  /// Get all tasks
  Future<List<Task>> getTasks({DateTime? startDate, DateTime? endDate}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String().split('T')[0];
      }
      
      final response = await _api.get(
        ApiEndpoints.tasks,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final List<dynamic> data = response.data['tasks'] ?? response.data ?? [];
      return data.map((e) => Task.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching tasks: $e');
      rethrow;
    }
  }

  /// Get tasks for a specific date
  Future<List<Task>> getTasksByDate(DateTime date) async {
    try {
      final response = await _api.get(
        ApiEndpoints.tasks,
        queryParameters: {
          'date': date.toIso8601String().split('T')[0],
        },
      );
      final List<dynamic> data = response.data['tasks'] ?? response.data ?? [];
      return data.map((e) => Task.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching tasks for date: $e');
      rethrow;
    }
  }

  /// Get a single task by ID
  Future<Task> getTaskById(String id) async {
    try {
      final response = await _api.get(ApiEndpoints.taskById(id));
      return Task.fromJson(response.data);
    } catch (e) {
      print('Error fetching task $id: $e');
      rethrow;
    }
  }

  /// Create a new task
  Future<Task> createTask(Task task) async {
    try {
      final response = await _api.post(
        ApiEndpoints.tasks,
        data: task.toRequestBody(),
      );
      return Task.fromJson(response.data);
    } catch (e) {
      print('Error creating task: $e');
      rethrow;
    }
  }

  /// Update an existing task
  Future<Task> updateTask(String id, Task task) async {
    try {
      final response = await _api.put(
        ApiEndpoints.taskById(id),
        data: task.toRequestBody(),
      );
      return Task.fromJson(response.data);
    } catch (e) {
      print('Error updating task $id: $e');
      rethrow;
    }
  }

  /// Toggle task completion status
  Future<Task> toggleTaskCompletion(String id, bool isCompleted) async {
    try {
      final response = await _api.put(
        ApiEndpoints.taskById(id),
        data: {'isCompleted': isCompleted},
      );
      return Task.fromJson(response.data);
    } catch (e) {
      print('Error toggling task $id: $e');
      rethrow;
    }
  }

  /// Delete a task
  Future<void> deleteTask(String id) async {
    try {
      await _api.delete(ApiEndpoints.taskById(id));
    } catch (e) {
      print('Error deleting task $id: $e');
      rethrow;
    }
  }
}
