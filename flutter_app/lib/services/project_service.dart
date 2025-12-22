import '../config/api_config.dart';
import '../models/project.dart';
import 'api_service.dart';

/// Service for project operations
class ProjectService {
  final ApiService _api = ApiService();

  /// Get all projects
  Future<List<Project>> getProjects() async {
    try {
      final response = await _api.get(ApiEndpoints.projects);
      final List<dynamic> data = response.data['projects'] ?? response.data ?? [];
      return data.map((e) => Project.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching projects: $e');
      rethrow;
    }
  }

  /// Get a single project by ID
  Future<Project> getProjectById(String id) async {
    try {
      final response = await _api.get(ApiEndpoints.projectById(id));
      return Project.fromJson(response.data);
    } catch (e) {
      print('Error fetching project $id: $e');
      rethrow;
    }
  }

  /// Create a new project
  Future<Project> createProject(Project project) async {
    try {
      final response = await _api.post(
        ApiEndpoints.projects,
        data: project.toRequestBody(),
      );
      return Project.fromJson(response.data);
    } catch (e) {
      print('Error creating project: $e');
      rethrow;
    }
  }

  /// Update an existing project
  Future<Project> updateProject(String id, Project project) async {
    try {
      final response = await _api.put(
        ApiEndpoints.projectById(id),
        data: project.toRequestBody(),
      );
      return Project.fromJson(response.data);
    } catch (e) {
      print('Error updating project $id: $e');
      rethrow;
    }
  }

  /// Delete a project
  Future<void> deleteProject(String id) async {
    try {
      await _api.delete(ApiEndpoints.projectById(id));
    } catch (e) {
      print('Error deleting project $id: $e');
      rethrow;
    }
  }

  /// Request AI analysis for project
  Future<ProjectAnalysis> analyzeProject(String id) async {
    try {
      final response = await _api.post(
        ApiEndpoints.analyzeProject,
        data: {'projectId': id},
      );
      return ProjectAnalysis.fromJson(response.data);
    } catch (e) {
      print('Error analyzing project $id: $e');
      rethrow;
    }
  }
}
