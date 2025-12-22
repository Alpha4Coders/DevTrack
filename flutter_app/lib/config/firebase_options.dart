import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration for DevTrack
/// Project: devtrack-7c798
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError('macOS is not supported');
      case TargetPlatform.windows:
        return web; // Use web config for Windows desktop
      case TargetPlatform.linux:
        throw UnsupportedError('Linux is not supported');
      default:
        throw UnsupportedError('Unknown platform');
    }
  }

  // Web configuration from client/.env
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCkI_Nzpsc_J78xZ3TYZ5-T7d1S-XGoLmE',
    appId: '1:629682965288:web:824486fce7d84227961e1d',
    messagingSenderId: '629682965288',
    projectId: 'devtrack-7c798',
    authDomain: 'devtrack-7c798.firebaseapp.com',
    storageBucket: 'devtrack-7c798.firebasestorage.app',
  );

  // Android configuration
  // TODO: Run `flutterfire configure` to generate the actual google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCkI_Nzpsc_J78xZ3TYZ5-T7d1S-XGoLmE',
    appId: '1:629682965288:android:PLACEHOLDER_ANDROID_APP_ID',
    messagingSenderId: '629682965288',
    projectId: 'devtrack-7c798',
    storageBucket: 'devtrack-7c798.firebasestorage.app',
  );

  // iOS configuration
  // TODO: Run `flutterfire configure` to generate the actual GoogleService-Info.plist
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCkI_Nzpsc_J78xZ3TYZ5-T7d1S-XGoLmE',
    appId: '1:629682965288:ios:PLACEHOLDER_IOS_APP_ID',
    messagingSenderId: '629682965288',
    projectId: 'devtrack-7c798',
    storageBucket: 'devtrack-7c798.firebasestorage.app',
    iosBundleId: 'com.devtrack.app',
  );
}

/// Firebase Cloud Messaging configuration
class FCMConfig {
  static const String vapidKey = 'BL0jMtx3bjNaZUT6ax3_GffRpDTItbUoT8w7zl08NCsRdKpxYLdaIVGOHI7zovS6o3fwVTVnwj_JOcwOBp6v5ck';
}
