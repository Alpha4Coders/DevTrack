import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

/// Callback for when session expires and user needs to re-authenticate
typedef SessionExpiredCallback = void Function();

/// Main API service for communicating with DevTrack backend
class ApiService {
  static ApiService? _instance;
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  /// Session expiry duration (7 days)
  static const Duration sessionDuration = Duration(days: 7);
  
  /// Callback when session expires
  static SessionExpiredCallback? onSessionExpired;

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.apiUrl,
      connectTimeout: ApiConfig.connectionTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors for auth and logging
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Check if session is expired before making request
        final isExpired = await isSessionExpired();
        if (isExpired) {
          print('⚠️ Session expired, clearing token');
          await clearAuthToken();
          onSessionExpired?.call();
          return handler.reject(
            DioException(
              requestOptions: options,
              error: 'Session expired. Please sign in again.',
              type: DioExceptionType.cancel,
            ),
          );
        }
        
        // Add auth token to requests
        final token = await _safeRead('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        print('→ ${options.method} ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('← ${response.statusCode} ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (error, handler) async {
        print('✖ ${error.response?.statusCode} ${error.message}');
        
        // Handle 401 Unauthorized - session may have been revoked server-side
        if (error.response?.statusCode == 401) {
          print('🔒 Token rejected by server, clearing session');
          await clearAuthToken();
          onSessionExpired?.call();
        }
        
        return handler.next(error);
      },
    ));
  }

  factory ApiService() {
    _instance ??= ApiService._internal();
    return _instance!;
  }

  /// Helper to safely read from secure storage and handle PlatformExceptions
  Future<String?> _safeRead(String key) async {
    try {
      return await _storage.read(
        key: key,
        aOptions: const AndroidOptions(encryptedSharedPreferences: true),
      );
    } catch (e) {
      print('⚠️ Secure storage read error for $key: $e');
      // If we hit a decryption error, the storage is likely corrupted
      if (e.toString().contains('BadPaddingException') ||
          e.toString().contains('BAD_DECRYPT')) {
        print('🧹 Decryption failed, clearing storage...');
        await _storage.deleteAll(
          aOptions: const AndroidOptions(encryptedSharedPreferences: true),
        );
      }
      return null;
    }
  }

  /// Store auth token securely with expiry timestamp
  Future<void> setAuthToken(String token) async {
    try {
      await _storage.write(
        key: 'auth_token',
        value: token,
        aOptions: const AndroidOptions(encryptedSharedPreferences: true),
      );
      
      // Store session expiry timestamp (7 days from now)
      final expiryTime = DateTime.now().add(sessionDuration);
      await _storage.write(
        key: 'session_expiry',
        value: expiryTime.toIso8601String(),
        aOptions: const AndroidOptions(encryptedSharedPreferences: true),
      );
      
      print('✅ Token stored, expires: ${expiryTime.toIso8601String()}');
    } catch (e) {
      print('Error writing to secure storage: $e');
    }
  }

  /// Get stored auth token
  Future<String?> getAuthToken() async {
    return await _safeRead('auth_token');
  }

  /// Clear auth token on logout
  Future<void> clearAuthToken() async {
    try {
      await _storage.delete(
        key: 'auth_token',
        aOptions: const AndroidOptions(encryptedSharedPreferences: true),
      );
      await _storage.delete(
        key: 'session_expiry',
        aOptions: const AndroidOptions(encryptedSharedPreferences: true),
      );
      print('🧹 Auth token and session expiry cleared');
    } catch (e) {
      print('Error deleting from secure storage: $e');
    }
  }

  /// Check if session has expired (based on stored expiry timestamp)
  Future<bool> isSessionExpired() async {
    try {
      final expiryStr = await _safeRead('session_expiry');
      if (expiryStr == null) {
        // No expiry stored, session is valid (new login)
        return false;
      }
      
      final expiryTime = DateTime.parse(expiryStr);
      final isExpired = DateTime.now().isAfter(expiryTime);
      
      if (isExpired) {
        print('⏰ Session expired at: $expiryStr');
      }
      
      return isExpired;
    } catch (e) {
      print('Error checking session expiry: $e');
      return false;
    }
  }

  /// Get remaining session time
  Future<Duration?> getRemainingSessionTime() async {
    try {
      final expiryStr = await _safeRead('session_expiry');
      if (expiryStr == null) return null;
      
      final expiryTime = DateTime.parse(expiryStr);
      final remaining = expiryTime.difference(DateTime.now());
      
      return remaining.isNegative ? Duration.zero : remaining;
    } catch (e) {
      return null;
    }
  }

  /// Check if user is authenticated (token exists and not expired)
  Future<bool> isAuthenticated() async {
    final token = await _safeRead('auth_token');
    if (token == null || token.isEmpty) return false;
    
    final isExpired = await isSessionExpired();
    return !isExpired;
  }

  // ==================== HTTP METHODS ====================

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.post<T>(path, data: data, queryParameters: queryParameters);
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.put<T>(path, data: data, queryParameters: queryParameters);
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.delete<T>(path, data: data, queryParameters: queryParameters);
  }
}
