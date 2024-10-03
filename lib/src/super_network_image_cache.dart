import 'package:super_network_image/src/super_network_image_cache_manager.dart';

class SuperNetworkImageCache {
  /// Set the global cache duration for all images.
  static void configure({String? cacheKey, Duration? duration}) {
    SuperNetworkImageCacheManager.instance.configure(
      cacheKey: cacheKey,
      duration: duration,
    );
  }

  /// Clear a specific image from the cache.
  static Future<void> clearCachedImage(String url) async {
    await SuperNetworkImageCacheManager.instance.clearSpecificImage(url);
  }

  /// Clear all cached images.
  static Future<void> clearAllCachedImages() async {
    await SuperNetworkImageCacheManager.instance.clearAllCachedImages();
  }

  /// Clear cached images associated with a specific tag.
  static Future<void> clearCacheForTag(String tag) async {
    await SuperNetworkImageCacheManager.instance.clearCacheForTag(tag);
  }
}
