# Technology Stack

## Framework & Language
- **Flutter** (SDK ^3.9.2) - Cross-platform mobile framework
- **Dart** - Primary programming language
- Supports Android, iOS, Web, Windows, Linux, and macOS

## Backend & Database
- **Firebase Core** (^2.32.0) - Backend infrastructure
- **Cloud Firestore** (^4.17.5) - NoSQL database for:
  - User profiles
  - Game units and activities
  - Glossary terms
  - Progress tracking
  - Tutor authentication

## Development Dependencies
- **flutter_lints** (^5.0.0) - Code quality and style enforcement
- **cupertino_icons** (^1.0.8) - iOS-style icons

## Common Commands

### Setup
```bash
# Install dependencies
flutter pub get

# Check Flutter installation
flutter doctor
```

### Development
```bash
# Run on connected device/emulator
flutter run

# Run on specific platform
flutter run -d chrome        # Web
flutter run -d windows       # Windows
flutter run -d android       # Android
```

### Code Quality
```bash
# Analyze code for issues
flutter analyze

# Format code
flutter format .

# Run tests
flutter test
```

### Build
```bash
# Build APK (Android)
flutter build apk

# Build iOS
flutter build ios

# Build web
flutter build web
```

## Firebase Configuration
- Firebase is initialized in `main.dart` with platform-specific options
- Configuration files: `firebase_options.dart`, `firebase.json`
- Android: `google-services.json` in `android/app/`
