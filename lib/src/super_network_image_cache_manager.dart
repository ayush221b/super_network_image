import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';
import 'dart:async';

class SuperNetworkImageCacheManager extends CacheManager {
  static String _key = 'superNetworkImageCache';

  static Duration cacheDuration = const Duration(days: 30);

  static SuperNetworkImageCacheManager? _instance;

  // Static variable to hold SharedPreferences instance
  static SharedPreferences? _sharedPreferences;

  // Completer to handle async initialization
  static Completer<void>? _prefsCompleter;

  // Prefix for cache busting versions
  static const String _cacheBustingVersionPrefix = 'cacheBustingVersion_';

  factory SuperNetworkImageCacheManager() {
    _instance ??= SuperNetworkImageCacheManager._internal();
    return _instance!;
  }

  SuperNetworkImageCacheManager._internal()
      : super(
          Config(
            _key,
            stalePeriod: cacheDuration,
            maxNrOfCacheObjects: 200,
          ),
        ) {
    // Initialize SharedPreferences if not already initialized
    if (_sharedPreferences == null) {
      _prefsCompleter = Completer<void>();
      _initSharedPreferences();
    }
  }

  static SuperNetworkImageCacheManager get instance {
    _instance ??= SuperNetworkImageCacheManager._internal();
    return _instance!;
  }

  void configure({
    String? cacheKey,
    Duration? duration,
  }) {
    if (cacheKey != null && cacheKey.trim().isNotEmpty) {
      _key = cacheKey;
    }
    if (duration != null) {
      cacheDuration = duration;
    }

    // Reconfigure the cache manager with the new duration
    _instance = SuperNetworkImageCacheManager._internal();
  }

  Future<void> _initSharedPreferences() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    if (_prefsCompleter!.isCompleted) {
      return;
    }
    _prefsCompleter!.complete();
  }

  Future<void> _ensurePrefsReady() async {
    if (_sharedPreferences == null) {
      await _prefsCompleter!.future;
    }
  }

  // Get cache busting version for a specific URL
  Future<int> getCacheBustingVersion(String url) async {
    await _ensurePrefsReady();
    return _sharedPreferences!.getInt('$_cacheBustingVersionPrefix$url') ?? 0;
  }

  // Initialise a version for cache busting
  Future<void> _initCacheBustingVersion(String url) async {
    await _ensurePrefsReady();
    await _sharedPreferences!.setInt(
      '$_cacheBustingVersionPrefix$url',
      0,
    );
  }

  // Increment cache busting version for a specific URL
  Future<void> _incrementCacheBustingVersion(String url) async {
    await _ensurePrefsReady();
    int version = await getCacheBustingVersion(url);
    version++;
    await _sharedPreferences!
        .setInt('$_cacheBustingVersionPrefix$url', version);
  }

  // Increment cache busting versions for all URLs associated with a tag
  Future<void> _incrementCacheBustingVersionsForTag(String tag) async {
    final urls = await _getUrlsForTag(tag);
    for (final url in urls) {
      await _incrementCacheBustingVersion(url);
    }
  }

  // Increment cache busting versions for all images (used in emptyCache)
  Future<void> _incrementCacheBustingVersionsForAllImages() async {
    await _ensurePrefsReady();
    final prefs = _sharedPreferences!;
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_cacheBustingVersionPrefix)) {
        // Get URL from key
        final url = key.substring(_cacheBustingVersionPrefix.length);
        await _incrementCacheBustingVersion(url);
      }
    }
  }

  Future<void> _addUrlToTag(String tag, String url) async {
    await _ensurePrefsReady();
    final prefs = _sharedPreferences!;
    final tagKey = 'tag_$tag';
    final urls = prefs.getStringList(tagKey) ?? [];
    if (!urls.contains(url)) {
      urls.add(url);
      await prefs.setStringList(tagKey, urls);
    }
  }

  Future<List<String>> _getUrlsForTag(String tag) async {
    await _ensurePrefsReady();
    final prefs = _sharedPreferences!;
    final tagKey = 'tag_$tag';
    return prefs.getStringList(tagKey) ?? [];
  }

  Future<void> _removeTag(String tag) async {
    await _ensurePrefsReady();
    final prefs = _sharedPreferences!;
    final tagKey = 'tag_$tag';
    await prefs.remove(tagKey);
  }

  Future<void> putFileWithTag(
    String url,
    Uint8List fileBytes, {
    required Duration maxAge,
    String? tag,
  }) async {
    await putFile(
      url,
      fileBytes,
      maxAge: maxAge,
    );
    if (tag != null) {
      await _addUrlToTag(tag, url);
    }
    if (kIsWeb) {
      _initCacheBustingVersion(url);
    }
  }

  @override
  Future<void> emptyCache() async {
    if (kIsWeb) {
      // On web, increment cache busting versions for all images
      await _incrementCacheBustingVersionsForAllImages();
    } else {
      // On mobile platforms, proceed with normal cache clearing
      await super.emptyCache();
    }
  }

  Future<void> clearCacheForTag(String tag) async {
    if (kIsWeb) {
      // Increment cache busting versions for images with this tag
      await _incrementCacheBustingVersionsForTag(tag);
    } else {
      final urls = await _getUrlsForTag(tag);
      for (final url in urls) {
        await removeFile(url);
      }
      await _removeTag(tag);
    }
  }

  Future<void> clearAllCachedImages() async {
    await emptyCache();
    await _ensurePrefsReady();
    final prefs = _sharedPreferences!;
    final keys = prefs.getKeys().where((key) => key.startsWith('tag_'));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  Future<void> clearSpecificImage(String url) async {
    if (kIsWeb) {
      // Increment cache busting version for this image
      await _incrementCacheBustingVersion(url);
    } else {
      await removeFile(url);
      await _ensurePrefsReady();
      final prefs = _sharedPreferences!;
      final keys = prefs.getKeys().where((key) => key.startsWith('tag_'));
      for (final key in keys) {
        final urls = prefs.getStringList(key) ?? [];
        if (urls.contains(url)) {
          urls.remove(url);
          if (urls.isEmpty) {
            await prefs.remove(key);
          } else {
            await prefs.setStringList(key, urls);
          }
        }
      }
    }
  }
}
