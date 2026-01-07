import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

import 'auth_service.dart';
import 'api_service.dart';
import '../models/user.dart';

/// Service for handling deep links, primarily for OAuth callbacks
/// Supports both custom scheme (devtrack://) and HTTPS deep links
class DeepLinkService {
  static DeepLinkService? _instance;
  final AppLinks _appLinks = AppLinks();
  final AuthService _authService = AuthService();
  
  /// Stream controller for auth state changes from deep links
  final _authStateController = StreamController<DeepLinkAuthState>.broadcast();
  Stream<DeepLinkAuthState> get authStateStream => _authStateController.stream;
  
  /// Subscription for link stream
  StreamSubscription<Uri>? _linkSubscription;
  
  /// Whether the service is initialized
  bool _initialized = false;

  DeepLinkService._internal();

  factory DeepLinkService() {
    _instance ??= DeepLinkService._internal();
    return _instance!;
  }

  /// Initialize the deep link service
  /// Call this once in main.dart or app.dart
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // Handle initial link (app opened via deep link)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        print('🔗 Initial deep link: $initialUri');
        await _handleDeepLink(initialUri);
      }
    } catch (e) {
      print('⚠️ Error getting initial deep link: $e');
    }

    // Handle subsequent links (app already running)
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        print('🔗 Received deep link: $uri');
        _handleDeepLink(uri);
      },
      onError: (e) {
        print('⚠️ Deep link stream error: $e');
      },
    );

    print('✅ Deep link service initialized');
  }

  /// Handle incoming deep link
  Future<void> _handleDeepLink(Uri uri) async {
    print('🔍 Processing deep link: $uri');
    print('   Scheme: ${uri.scheme}');
    print('   Host: ${uri.host}');
    print('   Path: ${uri.path}');
    print('   Query: ${uri.queryParameters}');

    // Handle OAuth callback
    if (_isAuthCallback(uri)) {
      await _handleAuthCallback(uri);
    }
  }

  /// Check if the URI is an auth callback
  bool _isAuthCallback(Uri uri) {
    // Custom scheme: devtrack://auth/callback?token=xxx
    if (uri.scheme == 'devtrack' && uri.host == 'auth') {
      return true;
    }
    
    // HTTPS scheme: https://devtrack-pwkj.onrender.com/mobile-callback?token=xxx
    if (uri.scheme == 'https' && 
        uri.host == 'devtrack-pwkj.onrender.com' &&
        uri.path.startsWith('/mobile-callback')) {
      return true;
    }
    
    return false;
  }

  /// Handle authentication callback from deep link
  Future<void> _handleAuthCallback(Uri uri) async {
    _authStateController.add(DeepLinkAuthState.processing);
    
    try {
      // Extract session token from query parameters
      final token = uri.queryParameters['token'];
      
      if (token == null || token.isEmpty) {
        // Check for error
        final error = uri.queryParameters['error'];
        if (error != null) {
          print('❌ Auth callback error: $error');
          _authStateController.add(DeepLinkAuthState.failed);
          return;
        }
        
        print('❌ No token in auth callback');
        _authStateController.add(DeepLinkAuthState.failed);
        return;
      }

      print('🔐 Received auth token from deep link');
      
      // Login with the token
      final user = await _authService.loginWithToken(token);
      
      if (user != null) {
        print('✅ Deep link auth successful: ${user.name}');
        _authStateController.add(DeepLinkAuthState.success);
      } else {
        print('❌ Deep link auth failed: Invalid token');
        _authStateController.add(DeepLinkAuthState.failed);
      }
    } catch (e) {
      print('❌ Deep link auth error: $e');
      _authStateController.add(DeepLinkAuthState.failed);
    }
  }

  /// Generate the web auth URL that will redirect back to the app
  /// Call this when user taps "Sign in with GitHub"
  String getWebAuthUrl() {
    // The web app will handle Clerk auth and redirect to the mobile callback
    const baseUrl = 'https://devtrack-pwkj.onrender.com';
    const mobileCallback = '/mobile-auth';
    
    // The web app's mobile-auth page will:
    // 1. Trigger Clerk sign-in
    // 2. After success, redirect to devtrack://auth/callback?token=xxx
    return '$baseUrl$mobileCallback';
  }

  /// Get the custom scheme callback URL
  /// Use this in Clerk's redirect configuration
  String getCallbackUrl() {
    return 'devtrack://auth/callback';
  }

  /// Dispose resources
  void dispose() {
    _linkSubscription?.cancel();
    _authStateController.close();
  }
}

/// States for deep link authentication
enum DeepLinkAuthState {
  idle,
  processing,
  success,
  failed,
}
