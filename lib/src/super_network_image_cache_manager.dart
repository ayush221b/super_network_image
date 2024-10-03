import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';
import 'dart:async';

class SuperNetworkImageCacheManager extends CacheManager {
  static const key = 'superNetworkImageCache';

  static Duration cacheDuration = const Duration(days: 30);

  static SuperNetworkImageCacheManager? _instance;

  // Static variable to hold SharedPreferences instance
  static SharedPreferences? _sharedPreferences;

  // Completer to handle async initialization
  static Completer<void>? _prefsCompleter;

  factory SuperNetworkImageCacheManager() {
    _instance ??= SuperNetworkImageCacheManager._internal();
    return _instance!;
  }

  SuperNetworkImageCacheManager._internal()
      : super(
          Config(
            key,
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

  void setGlobalCacheDuration(Duration duration) {
    cacheDuration = duration;
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

  Future<void> clearCacheForTag(String tag) async {
    final urls = await _getUrlsForTag(tag);
    for (final url in urls) {
      await removeFile(url);
    }
    await _removeTag(tag);
  }

  Future<void> putFileWithTag(
    String url,
    Uint8List fileBytes, {
    String? eTag,
    required Duration maxAge,
    String? tag,
  }) async {
    await putFile(
      url,
      fileBytes,
      eTag: eTag,
      maxAge: maxAge,
    );
    if (tag != null) {
      await _addUrlToTag(tag, url);
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
