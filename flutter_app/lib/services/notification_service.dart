import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../config/firebase_options.dart';
import '../config/api_config.dart';
import 'api_service.dart';

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📩 Background message: ${message.messageId}');
}

/// Service for push notifications using Firebase Cloud Messaging
class NotificationService {
  static NotificationService? _instance;
  final ApiService _api = ApiService();
  
  FirebaseMessaging? _messaging;
  String? _fcmToken;

  NotificationService._internal();

  factory NotificationService() {
    _instance ??= NotificationService._internal();
    return _instance!;
  }

  /// Initialize notification service
  Future<void> initialize() async {
    try {
      _messaging = FirebaseMessaging.instance;
      
      // Request permission on iOS/macOS
      final settings = await _messaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      
      print('📱 Notification permission: ${settings.authorizationStatus}');
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Get FCM token
        await _getFCMToken();
        
        // Set up message handlers
        _setupMessageHandlers();
      }
    } catch (e) {
      print('Notification init error: $e');
    }
  }

  /// Get FCM token
  Future<String?> _getFCMToken() async {
    try {
      if (kIsWeb) {
        _fcmToken = await _messaging?.getToken(
          vapidKey: FCMConfig.vapidKey,
        );
      } else {
        _fcmToken = await _messaging?.getToken();
      }
      
      print('🔔 FCM Token: ${_fcmToken?.substring(0, 20)}...');
      
      // Listen for token refresh
      _messaging?.onTokenRefresh.listen((token) {
        _fcmToken = token;
        _registerTokenWithBackend(token);
      });
      
      return _fcmToken;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  /// Register FCM token with backend
  Future<void> _registerTokenWithBackend(String token) async {
    try {
      await _api.post(
        ApiEndpoints.notificationsToken,
        data: {'token': token},
      );
      print('✅ FCM token registered with backend');
    } catch (e) {
      print('Error registering FCM token: $e');
    }
  }

  /// Register token (call after login)
  Future<void> registerToken() async {
    if (_fcmToken != null) {
      await _registerTokenWithBackend(_fcmToken!);
    } else {
      final token = await _getFCMToken();
      if (token != null) {
        await _registerTokenWithBackend(token);
      }
    }
  }

  /// Setup message handlers
  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      print('📩 Foreground message: ${message.notification?.title}');
      // Show local notification or snackbar
    });
    
    // When app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('📩 Opened from notification: ${message.data}');
      _handleNotificationTap(message);
    });
    
    // Check for initial message (app opened from terminated state)
    _messaging?.getInitialMessage().then((message) {
      if (message != null) {
        print('📩 Initial message: ${message.data}');
        _handleNotificationTap(message);
      }
    });
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    // Navigate based on notification data
    final data = message.data;
    final type = data['type'];
    
    switch (type) {
      case 'reminder':
        // Navigate to learning screen
        break;
      case 'task':
        // Navigate to calendar
        break;
      case 'streak':
        // Navigate to dashboard
        break;
    }
  }

  /// Send test notification
  Future<bool> sendTestNotification() async {
    try {
      await _api.post(ApiEndpoints.notificationsTest);
      return true;
    } catch (e) {
      print('Error sending test notification: $e');
      return false;
    }
  }

  /// Unregister from notifications (on logout)
  Future<void> unregister() async {
    try {
      if (_fcmToken != null) {
        await _api.delete(
          ApiEndpoints.notificationsToken,
          data: {'token': _fcmToken},
        );
      }
      _fcmToken = null;
    } catch (e) {
      print('Error unregistering FCM token: $e');
    }
  }
}
