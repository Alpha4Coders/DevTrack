import '../config/api_config.dart';
import '../models/log_entry.dart';
import 'api_service.dart';

/// Service for learning log operations
class LogService {
  final ApiService _api = ApiService();

  /// Get all learning entries (paginated)
  Future<List<LogEntry>> getLogs({int page = 1, int limit = 20}) async {
    try {
      final response = await _api.get(
        ApiEndpoints.logs,
        queryParameters: {'page': page, 'limit': limit},
      );
      
      final List<dynamic> data = response.data['logs'] ?? response.data ?? [];
      return data.map((e) => LogEntry.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching logs: $e');
      rethrow;
    }
  }

  /// Get a single log entry by ID
  Future<LogEntry> getLogById(String id) async {
    try {
      final response = await _api.get(ApiEndpoints.logById(id));
      return LogEntry.fromJson(response.data);
    } catch (e) {
      print('Error fetching log $id: $e');
      rethrow;
    }
  }

  /// Create a new learning entry
  Future<LogEntry> createLog(LogEntry entry) async {
    try {
      final response = await _api.post(
        ApiEndpoints.logs,
        data: entry.toRequestBody(),
      );
      return LogEntry.fromJson(response.data);
    } catch (e) {
      print('Error creating log: $e');
      rethrow;
    }
  }

  /// Update an existing learning entry
  Future<LogEntry> updateLog(String id, LogEntry entry) async {
    try {
      final response = await _api.put(
        ApiEndpoints.logById(id),
        data: entry.toRequestBody(),
      );
      return LogEntry.fromJson(response.data);
    } catch (e) {
      print('Error updating log $id: $e');
      rethrow;
    }
  }

  /// Delete a learning entry
  Future<void> deleteLog(String id) async {
    try {
      await _api.delete(ApiEndpoints.logById(id));
    } catch (e) {
      print('Error deleting log $id: $e');
      rethrow;
    }
  }

  /// Get learning statistics
  Future<LogStats> getStats() async {
    try {
      final response = await _api.get(ApiEndpoints.logsStats);
      return LogStats.fromJson(response.data);
    } catch (e) {
      print('Error fetching log stats: $e');
      rethrow;
    }
  }
}
