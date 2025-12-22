import '../config/api_config.dart';
import 'api_service.dart';

/// Service for AI chat operations
class ChatService {
  final ApiService _api = ApiService();

  /// Send a message to AI chat
  Future<ChatResponse> sendMessage(String message, {String? context}) async {
    try {
      final response = await _api.post(
        ApiEndpoints.geminiChat,
        data: {
          'message': message,
          if (context != null) 'context': context,
        },
      );
      return ChatResponse.fromJson(response.data);
    } catch (e) {
      print('Error sending chat message: $e');
      rethrow;
    }
  }

  /// Analyze a project using AI
  Future<String> analyzeProject({
    required String projectId,
    String? repoUrl,
  }) async {
    try {
      final response = await _api.post(
        ApiEndpoints.analyzeProject,
        data: {
          'projectId': projectId,
          if (repoUrl != null) 'repoUrl': repoUrl,
        },
      );
      return response.data['analysis'] ?? response.data['message'] ?? '';
    } catch (e) {
      print('Error analyzing project: $e');
      rethrow;
    }
  }
}

class ChatResponse {
  final String message;
  final String? role;
  final DateTime? timestamp;

  const ChatResponse({
    required this.message,
    this.role,
    this.timestamp,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      message: json['message'] ?? json['response'] ?? json['content'] ?? '',
      role: json['role'],
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
    );
  }
}
