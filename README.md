# Super Network Image

A powerful Flutter widget for loading and caching network images, supporting both raster and SVG formats with advanced caching capabilities and precise cache management.

## Features

- **Automatic Image Type Detection**: Automatically detects whether an image is raster or SVG and renders it accordingly.
- **Caching Support**: Caches images to improve performance and reduce network usage.
- **Per-Image and Per-Tag Cache Busting**: Ensures effective cache clearing for specific images or groups of images, even on web platforms.
- **Custom Cache Duration**: Set global or individual cache durations for images.
- **Cache Tags**: Assign tags to images for grouped cache management.
- **Cache Management**: Clear cache by image URL, tag, or entirely, with precise control.
- **Custom Placeholders and Error Widgets**: Provide custom widgets for loading and error states.
- **Image Sizing and Fit**: Control image dimensions and how they fit within their containers.
- **Load Source Callback**: Determine if an image was loaded from the cache or network.
- **Platform Compatibility**: Works seamlessly across mobile and web platforms.

## Getting Started

### Installation

Add `super_network_image` to your project's `pubspec.yaml` file:

```yaml
dependencies:
  super_network_image: 0.0.2
```

Then run:

```bash
flutter pub get
```

### Import

```dart
import 'package:super_network_image/super_network_image.dart';
```

## Usage

### Basic Usage

Load and display a network image:

```dart
SuperNetworkImage(
  url: 'https://example.com/image.jpg',
  width: 300,
  height: 300,
),
```

### SVG Image Support

Automatically handle SVG images:

```dart
SuperNetworkImage(
  url: 'https://example.com/image.svg',
  width: 300,
  height: 300,
),
```

### Custom Cache Duration

Set a custom cache duration for an image:

```dart
SuperNetworkImage(
  url: 'https://example.com/image.jpg',
  cacheDuration: Duration(days: 1),
),
```

Set a global cache duration:

```dart
void main() {
  SuperNetworkImageCache.configure(
    duration: const Duration(days: 7),
  );
  runApp(MyApp());
}
```

### Custom Placeholder and Error Widgets

Provide custom widgets for loading and error states:

```dart
SuperNetworkImage(
  url: 'https://example.com/image.jpg',
  placeholderBuilder: () => Center(
    child: CircularProgressIndicator(),
  ),
  errorBuilder: () => Center(
    child: Text('Failed to load image'),
  ),
),
```

### Using Cache Tags

Assign a tag to an image:

```dart
SuperNetworkImage(
  url: 'https://example.com/image.jpg',
  tag: 'profile_pictures',
),
```

Clear cache for a specific tag:

```dart
await SuperNetworkImageCache.clearCacheForTag('profile_pictures');
```

### Clearing Cache

#### Clear a Specific Image from the Cache

```dart
await SuperNetworkImageCache.clearCachedImage('https://example.com/image.jpg');
```

#### Clear All Cached Images

```dart
await SuperNetworkImageCache.clearAllCachedImages();
```

### Per-Image and Per-Tag Cache Busting

On web platforms, due to browser caching mechanisms, clearing the cache programmatically can be challenging. To address this, `super_network_image` implements per-image and per-tag cache busting:

- **Per-Image Cache Busting**: When you clear the cache for a specific image, only that image's cache busting version is incremented, forcing the browser to fetch a fresh copy.
- **Per-Tag Cache Busting**: When you clear the cache for a tag, only images associated with that tag will have their cache busting versions incremented.

This ensures that cache clearing operations affect only the intended images, providing precise cache management.

**Example: Clearing Cache for a Specific Image**

```dart
await SuperNetworkImageCache.clearCachedImage('https://example.com/image.jpg');
```

**Example: Clearing Cache for a Tag**

```dart
await SuperNetworkImageCache.clearCacheForTag('profile_pictures');
```

### Load Source Callback

Determine if an image was loaded from the cache or network:

```dart
SuperNetworkImage(
  url: 'https://example.com/image.jpg',
  onLoad: (source) {
    if (source == ImageSource.cache) {
      print('Image loaded from cache');
    } else {
      print('Image loaded from network');
    }
  },
),
```

### Image Fit and Sizing

Control how the image fits within its container:

```dart
SuperNetworkImage(
  url: 'https://example.com/image.jpg',
  width: 300,
  height: 200,
  fit: BoxFit.cover,
),
```

### Platform Compatibility

The package handles caching differently based on the platform:

- **Mobile Platforms (Android/iOS)**: Uses the device's file system for caching. Clearing the cache deletes files directly.
- **Web Platform**: Implements cache busting by appending a version query parameter to image URLs. This forces the browser to fetch new versions of images when the cache is cleared.

## Example

A comprehensive example is available in the `example` directory, demonstrating all features of the package, including cache busting and cache management.

You can also view the example code [here](example/lib/main.dart).

## Contributions

Contributions are welcome! Please feel free to submit a pull request or open an issue on [GitHub](https://github.com/ayush221b/super_network_image).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.