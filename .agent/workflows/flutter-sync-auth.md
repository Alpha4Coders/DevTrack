---
description: Flutter App Database Sync and Persistent Authentication Setup
---

# Flutter App Database Sync & Persistent Authentication

This workflow sets up the Flutter app to:
1. Sync data with the web dashboard (shared Firestore database)
2. Keep users signed in for a week using session tokens
3. Enable seamless GitHub sign-in via deep linking

## Prerequisites
- Flutter SDK installed and in PATH
- DevTrack server running
- Firebase/Clerk configuration complete
- Web client deployed with /mobile-auth route

## Architecture Overview

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Flutter App    │────▶│  DevTrack API   │◀────│   Web Client    │
│                 │     │   (Clerk Auth)  │     │                 │
│ - DeepLinkSvc   │     │                 │     │ - MobileAuth    │
│ - SyncService   │     │   Firestore     │     │   Page          │
│ - ApiService    │     │   Database      │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
        │                                               │
        │         ┌─────────────────────┐              │
        └────────▶│   Deep Link Flow    │◀─────────────┘
                  │  devtrack://auth    │
                  └─────────────────────┘
```

## Files Modified/Created

### Flutter App (`flutter_app/`)
- `lib/services/api_service.dart` - Token expiry management (7 days)
- `lib/services/sync_service.dart` - **NEW** - Data synchronization
- `lib/services/deep_link_service.dart` - **NEW** - OAuth callback handling
- `lib/services/auth_service.dart` - Updated for deep link flow
- `lib/main.dart` - Initialize deep link and sync services
- `android/app/src/main/AndroidManifest.xml` - Deep link intent filters
- `pubspec.yaml` - Added app_links package

### Web Client (`client/src/`)
- `pages/MobileAuth.jsx` - **NEW** - Handles mobile app auth
- `pages/MobileAuth.css` - **NEW** - Styles for mobile auth page
- `App.jsx` - Added /mobile-auth route

## Authentication Flow

1. **User taps "Sign in with GitHub"** in Flutter app
2. **App opens browser** to `https://devtrack-pwkj.onrender.com/mobile-auth`
3. **Web page triggers Clerk sign-in** modal
4. **User signs in with GitHub**
5. **Web page gets session token** from Clerk
6. **Web page redirects** to `devtrack://auth/callback?token=xxx`
7. **Flutter app receives deep link** with token
8. **App stores token** with 7-day expiry
9. **App syncs data** from server

## Session Persistence

- Session tokens are stored with a 7-day expiry timestamp
- On each API call, the app checks if the session is still valid
- If expired, user is prompted to re-authenticate
- Session info is stored in FlutterSecureStorage (encrypted)

## Data Synchronization

- **On Login**: Full sync of user data, logs, tasks, projects
- **On App Resume**: Incremental sync
- **Offline Support**: Changes are queued and synced when online

## Steps to Build

// turbo-all

### 1. Install Flutter dependencies
```bash
cd d:\hdd\DevTrack\flutter_app
flutter pub get
```

### 2. Build the release APK
```bash
cd d:\hdd\DevTrack\flutter_app
flutter build apk --release
```

### 3. Deploy the web client
Ensure the web client is deployed with the new `/mobile-auth` route.

## Testing the Deep Link

### On Android Emulator/Device:
```bash
adb shell am start -W -a android.intent.action.VIEW -d "devtrack://auth/callback?token=test_token" com.devtrack.devtrack_app
```

### Manual Test:
1. Open Flutter app
2. Tap "Sign in with GitHub"
3. Browser opens to mobile-auth page
4. Sign in with GitHub
5. Should automatically redirect back to app
6. App should be logged in

## Troubleshooting

### Deep link not working
- Check AndroidManifest.xml has correct intent filters
- Ensure app is installed (not just running in debug)
- Test with adb command above

### Token expired too quickly
- Check the `sessionDuration` in `api_service.dart` (default: 7 days)
- Verify system time is correct on device

### Sync not working
- Check internet connectivity
- Verify API endpoints in `api_config.dart`
- Check server logs for errors
