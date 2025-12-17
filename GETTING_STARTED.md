# Getting Started with Color Your Mind Flutter

This guide will help you set up and run the Color Your Mind coloring book app.

## Prerequisites

Before you begin, ensure you have the following installed:

1. **Flutter SDK** (3.0.0 or higher)
   - Download from: https://flutter.dev/docs/get-started/install
   - Add Flutter to your PATH

2. **For Android Development:**
   - Android Studio
   - Android SDK (API level 21 or higher)
   - Java Development Kit (JDK)

3. **For iOS Development (macOS only):**
   - Xcode (latest version)
   - CocoaPods: `sudo gem install cocoapods`

4. **For Web Development:**
   - Chrome browser

## Setup Instructions

### 1. Verify Flutter Installation

```bash
flutter doctor
```

This command checks your environment and displays a report of the status of your Flutter installation.

### 2. Install Dependencies

Navigate to the project directory and run:

```bash
flutter pub get
```

This will download all the required packages specified in `pubspec.yaml`.

### 3. iOS Setup (macOS only)

If you're building for iOS, you need to install CocoaPods dependencies:

```bash
cd ios
pod install
cd ..
```

## Running the App

### Run on All Available Devices

```bash
flutter run
```

Flutter will list all available devices and let you select one.

### Run on Specific Platforms

**Android:**
```bash
flutter run -d android
```

**iOS (macOS only):**
```bash
flutter run -d ios
```

**Web (Chrome):**
```bash
flutter run -d chrome
```

**Web (Edge):**
```bash
flutter run -d edge
```

## Building for Production

### Android APK

```bash
flutter build apk --release
```

The APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (recommended for Play Store)

```bash
flutter build appbundle --release
```

The bundle will be located at: `build/app/outputs/bundle/release/app-release.aab`

### iOS (macOS only)

```bash
flutter build ios --release
```

Then open `ios/Runner.xcworkspace` in Xcode to archive and distribute.

### Web

```bash
flutter build web --release
```

The web build will be located at: `build/web/`

## Testing

Run all tests:

```bash
flutter test
```

Run tests with coverage:

```bash
flutter test --coverage
```

## Troubleshooting

### "Flutter SDK not found"

Make sure Flutter is in your PATH. Add this to your `.bashrc` or `.zshrc`:

```bash
export PATH="$PATH:/path/to/flutter/bin"
```

### Android build fails

1. Check that you have the Android SDK installed
2. Run `flutter doctor` to diagnose issues
3. Update Android SDK tools if needed

### iOS build fails

1. Run `pod install` in the `ios` directory
2. Open `ios/Runner.xcworkspace` in Xcode and check for issues
3. Ensure you have a valid signing certificate

### Web build fails

1. Ensure you're using Flutter 2.0 or higher
2. Try `flutter clean` then `flutter pub get`

## Next Steps

- Add custom app icons (see platform-specific README files)
- Implement coloring book features
- Add more screens and navigation
- Integrate state management (Provider, Riverpod, or Bloc)
- Add animations and interactions

## Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Flutter Cookbook](https://flutter.dev/docs/cookbook)
- [Material Design Guidelines](https://material.io/design)

## Support

For issues and questions, please open an issue on the GitHub repository.
