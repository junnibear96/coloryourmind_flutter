# Assets Directory

This directory contains app assets like images, fonts, and other resources.

## Directory Structure

- `images/` - Image assets (PNG, JPG, SVG, etc.)
- `fonts/` - Custom font files (TTF, OTF)

## Using Assets

1. Place your asset files in the appropriate subdirectory
2. Declare them in `pubspec.yaml` under the `flutter:` section:

```yaml
flutter:
  assets:
    - assets/images/
    - assets/fonts/
  
  fonts:
    - family: CustomFont
      fonts:
        - asset: assets/fonts/CustomFont-Regular.ttf
        - asset: assets/fonts/CustomFont-Bold.ttf
          weight: 700
```

3. Use them in your code:

```dart
// For images
Image.asset('assets/images/my_image.png')

// For fonts (after declaring in pubspec.yaml)
Text(
  'Hello',
  style: TextStyle(fontFamily: 'CustomFont'),
)
```

## Best Practices

- Use vector graphics (SVG) when possible for scalability
- Optimize images for mobile (compress, resize)
- Provide multiple resolutions (1x, 2x, 3x) for raster images
- Keep assets organized by feature or screen
