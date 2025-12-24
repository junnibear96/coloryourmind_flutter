# Color Your Mind Flutter - Project Summary

## Overview

This is a Flutter-based cross-platform coloring book application supporting:
- **Android**
- **iOS**
- **Web**

For the step-by-step development plan, see [ROADMAP.md](ROADMAP.md).

## Project Structure (current)

```
coloryourmind_flutter/
├── README.md
├── ROADMAP.md
├── GETTING_STARTED.md
├── analysis_options.yaml
├── pubspec.yaml
├── assets/
│   └── images/
├── lib/
│   ├── main.dart                 # App entry + locale wiring
│   ├── screens/                  # Intro + coloring screens
│   ├── widgets/                  # Canvas painters + UI widgets
│   ├── models/                   # Drawing/document models
│   ├── utils/                    # Localization + drawing/shape helpers
│   ├── state/                    # App-wide notifiers (locale, uploads)
│   └── download/                 # Web vs non-web download abstraction
└── test/
   ├── widget_test.dart
   └── coloring_page_test.dart

## Key Features (implemented)

### 1. Cross-Platform Support
- Single codebase for Android, iOS, and Web
- Web download implementation via conditional imports

### 2. Material Design 3 + Responsive UI
- Material 3 theme
- Desktop: tool side panel
- Mobile: bottom tool controls

### 3. Drawing & Export
- Brush + eraser drawing
- Multiple brush styles
- Undo/redo + reset
- Export to PNG/JPG

### 4. Localization
- EN/KR toggle using a simple translation helper

## Current State

The app includes:
- A gallery home screen (`IntroPage`) with search and category carousels
- A full coloring screen (`ColoringPage`) with drawing tools and export

## Next Development Steps

See [ROADMAP.md](ROADMAP.md) for milestone-based planning (foundation refactor, fill/picker tools, persistence, sharing, release readiness).

## Build Commands

### Development
```bash
flutter run                    # Run on available device
flutter run -d android        # Run on Android
flutter run -d ios           # Run on iOS (macOS only)
flutter run -d chrome        # Run on Web
```

### Testing
```bash
flutter test                  # Run all tests
flutter test --coverage      # Run with coverage
```

### Production Builds
```bash
flutter build apk --release              # Android APK
flutter build appbundle --release        # Android App Bundle
flutter build ios --release             # iOS (macOS only)
flutter build web --release             # Web
```

## Dependencies

Current dependencies in `pubspec.yaml`:
- `flutter` (SDK)
- `cupertino_icons` - iOS-style icons
- `flutter_lints` (dev) - Linting rules
- `flutter_test` (dev) - Testing framework

## Technical Specifications

- **Minimum SDK Versions:**
  - Android: API 21 (Android 5.0)
  - iOS: 12.0
  - Web: Modern browsers with ES6 support

- **Build Tools:**
  - Gradle: 8.3
  - Kotlin: 1.9.0
  - Android Gradle Plugin: 8.1.0

## Resources

- Project README: `README.md`
- Setup Guide: `GETTING_STARTED.md`
- Assets Guide: `assets/README.md`
- Android Icons: `android/app/src/main/res/README.md`
- iOS Assets: `ios/Runner/Assets.xcassets/README.md`
- Web Icons: `web/icons/README.md`

## Status

✅ Project initialized
✅ All platforms configured
✅ Basic UI implemented
✅ Tests created
✅ Documentation complete
🚀 Ready for feature development
