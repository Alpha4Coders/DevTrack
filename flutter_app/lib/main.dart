import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_options.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/sync_service.dart';
import 'services/api_service.dart';
import 'services/deep_link_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D0D0D),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('🔥 Firebase initialized');

    // Initialize notifications
    await NotificationService().initialize();
    print('🔔 Notifications initialized');
  } catch (e) {
    print('Firebase/Notification init error: $e');
  }

  // Initialize storage
  try {
    await StorageService().initialize();
    print('💾 Storage initialized');
  } catch (e) {
    print('Storage init error: $e');
  }

  // Initialize deep link service for OAuth callbacks
  try {
    await DeepLinkService().initialize();
    print('🔗 Deep link service initialized');
  } catch (e) {
    print('Deep link init error: $e');
  }

  // Initialize sync service for data synchronization
  try {
    await SyncService().initialize();
    print('🔄 Sync service initialized');
    
    // Check session validity and perform initial sync if authenticated
    final apiService = ApiService();
    final isAuth = await apiService.isAuthenticated();
    
    if (isAuth) {
      print('✅ Valid session found, performing initial sync...');
      final remainingTime = await apiService.getRemainingSessionTime();
      if (remainingTime != null) {
        print('⏰ Session expires in: ${remainingTime.inDays} days, ${remainingTime.inHours % 24} hours');
      }
      
      // Perform background sync
      SyncService().fullSync().then((result) {
        print('🔄 Initial sync: ${result.message}');
      });
    } else {
      print('🔐 No valid session, user needs to login');
    }
  } catch (e) {
    print('Sync service init error: $e');
  }

  runApp(
    const ProviderScope(
      child: DevTrackApp(),
    ),
  );
}
