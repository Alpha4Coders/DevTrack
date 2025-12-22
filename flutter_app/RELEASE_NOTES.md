# DevTrack Mobile App v1.0.0-beta.1 🚀

**Pre-release** | December 22, 2025

The first beta release of DevTrack for Android! Track your developer journey on the go.

---

## ✨ What's New

### Core Features
- 📊 **Dashboard** - View learning logs, GitHub commits, and streak stats
- 📚 **Learning Tracker** - Log daily learning sessions with tags and mood tracking
- 🛠️ **Project Management** - Track projects with GitHub integration
- 📅 **Calendar & Tasks** - Manage tasks with due dates and priorities
- 🤖 **AI Chat** - Get coding help via Gemini/Groq AI integration
- 🔥 **Streak Tracking** - Build consistency with visual streak indicators

### Authentication
- 🔐 Sign in via DevTrack web app with GitHub
- 📱 Easy token copy from web dashboard for mobile login
- 🔒 Secure token storage with Flutter Secure Storage

### Design
- 🌙 Beautiful dark theme optimized for developers
- ✨ Smooth animations with Flutter Animate
- 📱 Responsive layouts for all screen sizes

---

## 📥 Installation

1. Download `app-release.apk` from Assets below
2. Transfer to your Android device
3. Enable "Install from Unknown Sources" in Settings
4. Open the APK and install
5. Log in using the web app token (instructions in-app)

---

## 🔗 Getting Your Login Token

1. Open [devtrack-pwkj.onrender.com](https://devtrack-pwkj.onrender.com)
2. Sign in with GitHub
3. Go to Dashboard → scroll to **"📱 Mobile App Login"** card
4. Tap **"Get Session Token"** → **"Copy Token"**
5. Paste in the mobile app

---

## 📋 Requirements

- Android 5.0 (API 21) or higher
- ~52 MB storage space
- Internet connection for sync

---

## ⚠️ Known Issues

- Firebase push notifications require manual configuration
- Offline sync queues operations but requires reconnection to sync
- Token expires after ~7 days (re-login from web app)

---

## 🛠️ Tech Stack

- **Framework**: Flutter 3.x
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **HTTP Client**: Dio
- **Storage**: Flutter Secure Storage, Hive, SharedPreferences
- **Animations**: Flutter Animate

---

## 📝 Full Changelog

### Added
- Initial Flutter app structure with MVVM architecture
- Authentication service with Clerk integration
- API service with Dio and auth interceptors
- Learning log CRUD operations
- Project management with AI analysis
- Task management with calendar view
- AI chat with Gemini/Groq
- GitHub profile and commits display
- Offline operation queue
- Connectivity monitoring
- Onboarding flow
- Settings screen with notification preferences

---

## 🙏 Feedback

This is a **pre-release** - please report bugs and feedback via GitHub Issues!

---

**Built with ❤️ by the DevTrack Team**
