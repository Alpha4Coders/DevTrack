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

  /// Get chat history
  Future<List<ChatMessage>> getHistory() async {
    try {
      final response = await _api.get(ApiEndpoints.geminiHistory);
      final List<dynamic> historyData = response.data['data']['history'] ?? [];
      return historyData.map((json) => ChatMessage.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching chat history: $e');
      return [];
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
    // Handle nested data structure
    final data = json['data'] ?? json;
    return ChatResponse(
      message: data['message'] ?? data['response'] ?? data['content'] ?? '',
      role: data['role'],
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] is String
              ? DateTime.parse(data['timestamp'])
              : (data['timestamp'] as dynamic).toDate())
          : DateTime.now(),
    );
  }
}

class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      content: json['content'] ?? '',
      isUser: json['role'] == 'user',
      timestamp: json['timestamp'] != null
          ? (json['timestamp'] is String
              ? DateTime.parse(json['timestamp'])
              : (json['timestamp'] as dynamic).toDate())
          : DateTime.now(),
    );
  }
}
