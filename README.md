# Color Your Mind Flutter

A coloring book mobile (Android/iOS) and web application built with Flutter.

See [ROADMAP.md](ROADMAP.md) for planned milestones and priorities.

## Getting Started

This project is a Flutter application that supports multiple platforms:
- **Mobile**: Android and iOS
- **Web**: Progressive Web App (PWA)

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- For Android development: Android Studio and Android SDK
- For iOS development: Xcode (macOS only)
- For web development: Chrome browser

### Installation

1. Clone the repository:
```bash
git clone https://github.com/junnibear96/coloryourmind_flutter.git
cd coloryourmind_flutter
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:

For mobile (connected device or emulator):
```bash
flutter run
```

For web:
```bash
flutter run -d chrome
```

For specific platforms:
```bash
flutter run -d android
flutter run -d ios
flutter run -d web
```

### Building for Production

**Android APK:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```

## Project Structure

```
lib/
  main.dart           # Application entry point
android/              # Android-specific files
ios/                  # iOS-specific files
web/                  # Web-specific files
test/                 # Test files
```

## Features

- Cross-platform support (Android, iOS, Web)
- Material Design 3 + responsive layout
- Gallery-style home with search + category carousels
- Drawing canvas with brush/eraser, multiple brush styles, and brush size controls
- Undo/redo and reset
- Export to PNG/JPG (download-based on web)
- Basic EN/KR localization toggle

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

See the LICENSE file for details.
