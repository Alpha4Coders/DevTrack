# DevTrack Flutter App

A Flutter mobile application for DevTrack - Track your developer journey.

## Getting Started

### Prerequisites

- Flutter SDK 3.2.0 or higher
- Dart SDK 3.2.0 or higher
- Android Studio / Xcode (for running on emulators)

### Installation

1. **Install Flutter SDK**
   Follow the official guide: https://docs.flutter.dev/get-started/install

2. **Navigate to the Flutter app directory**
   ```bash
   cd flutter_app
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Configure Firebase**
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase (use your Firebase project)
   flutterfire configure --project=YOUR_PROJECT_ID
   ```

5. **Update API Configuration**
   Edit `lib/config/api_config.dart` with your backend URL and GitHub OAuth credentials.

6. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart              # Entry point
├── app.dart               # App configuration
├── config/                # Configuration files
│   ├── api_config.dart    # API endpoints
│   ├── router.dart        # GoRouter navigation
│   ├── theme.dart         # App theming
│   └── firebase_options.dart
├── providers/             # Riverpod state management
│   └── auth_provider.dart
├── screens/               # App screens
│   ├── splash/
│   ├── auth/
│   ├── onboarding/
│   ├── dashboard/
│   ├── learning/
│   ├── projects/
│   ├── chat/
│   ├── calendar/
│   └── settings/
├── widgets/               # Reusable components
│   ├── common/
│   ├── charts/
│   └── heatmap/
└── services/              # API services (TODO)
```

## Features

- 📊 Dashboard with stats and activity charts
- 📚 Learning log tracker
- 🛠️ Project management with AI analysis
- 💬 AI Chat assistant
- 📅 Calendar-based task management
- 🔔 Push notifications (FCM)
- 🐙 GitHub OAuth authentication

## Tech Stack

- **Framework**: Flutter 3.x
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **HTTP Client**: Dio
- **Charts**: fl_chart
- **Animations**: flutter_animate
- **Firebase**: Cloud Messaging, Analytics

## Backend

This app connects to the existing DevTrack Node.js backend at:
- Development: `http://localhost:5000/api`
- Production: `https://devtrack-pwkj.onrender.com/api`

## Building

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

---

Built with ❤️ by Alpha Coders
