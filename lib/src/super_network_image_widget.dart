import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:async';
import 'package:super_network_image/src/super_network_image_cache_manager.dart';

enum ImageSource {
  network,
  cache,
}

class SuperNetworkImage extends StatefulWidget {
  final String url;
  final double? width;
  final double? height;
  final bool cache;
  final Duration? cacheDuration;
  final BoxFit? fit;
  final String? tag;
  final Widget Function()? placeholderBuilder;
  final Widget Function()? errorBuilder;
  final void Function(ImageSource source)? onLoad;

  const SuperNetworkImage({
    required this.url,
    this.width,
    this.height,
    this.cache = true,
    this.cacheDuration,
    this.fit = BoxFit.cover,
    this.tag,
    this.placeholderBuilder,
    this.errorBuilder,
    this.onLoad,
    super.key,
  });

  @override
  _SuperNetworkImageState createState() => _SuperNetworkImageState();
}

class _SuperNetworkImageState extends State<SuperNetworkImage> {
  late Future<Widget> _imageFuture;

  @override
  void initState() {
    super.initState();
    _imageFuture = _loadImage(widget.url);
  }

  String _appendCacheBustingQuery(String url, int version) {
    if (version == 0) {
      return url;
    }
    final uri = Uri.parse(url);
    final queryParameters = Map<String, String>.from(uri.queryParameters);
    queryParameters['cb'] = version.toString();
    final newUri = uri.replace(queryParameters: queryParameters);
    return newUri.toString();
  }

  Future<Widget> _loadImage(String url) async {
    final cacheManager = widget.cache
        ? SuperNetworkImageCacheManager.instance
        : DefaultCacheManager();

    // Apply cache busting on web if needed
    if (kIsWeb && widget.cache) {
      final cacheBustingVersion = await SuperNetworkImageCacheManager.instance
          .getCacheBustingVersion(url);
      url = _appendCacheBustingQuery(url, cacheBustingVersion);
    }

    // Try to get the file from cache
    FileInfo? fileInfo = await cacheManager.getFileFromCache(url);

    Uint8List imageData;
    String? contentType;

    if (fileInfo != null) {
      // File is in cache
      imageData = await fileInfo.file.readAsBytes();
      // Can't get 'content-type' from cache, so set to null
      contentType = null;
      // Notify that image was loaded from cache
      widget.onLoad?.call(ImageSource.cache);
    } else {
      // File is not in cache, download it
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        imageData = response.bodyBytes;
        contentType = response.headers['content-type'];

        // Save to cache asynchronously with tag
        unawaited(
          SuperNetworkImageCacheManager.instance
              .putFileWithTag(
            url,
            imageData,
            maxAge: widget.cacheDuration ??
                SuperNetworkImageCacheManager.cacheDuration,
            tag: widget.tag,
          )
              .catchError((error) {
            // Handle caching error if necessary
            print('Failed to cache image: $error');
          }),
        );
        // Notify that image was loaded from network
        widget.onLoad?.call(ImageSource.network);
      } else {
        throw Exception('Failed to load image');
      }
    }

    // Determine image type
    if (contentType != null && contentType.contains('svg')) {
      // It's an SVG
      return SvgPicture.memory(
        imageData,
        width: widget.width,
        height: widget.height,
        fit: widget.fit ?? BoxFit.cover,
      );
    } else if (_isSvgData(imageData)) {
      // Fallback: Check if data starts with '<svg'
      return SvgPicture.memory(
        imageData,
        width: widget.width,
        height: widget.height,
        fit: widget.fit ?? BoxFit.cover,
      );
    } else {
      // It's a raster image
      return Image.memory(
        imageData,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
      );
    }
  }

  bool _isSvgData(Uint8List data) {
    // Efficiently check if data starts with '<svg'
    const maxBytesToRead = 500;
    final length = data.length < maxBytesToRead ? data.length : maxBytesToRead;
    final dataString = String.fromCharCodes(data.sublist(0, length));
    return dataString.trimLeft().startsWith('<svg');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildPlaceholder();
        } else if (snapshot.hasError) {
          return _buildErrorWidget();
        } else {
          return snapshot.data!;
        }
      },
    );
  }

  Widget _buildPlaceholder() {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: widget.placeholderBuilder?.call() ??
          Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.grey.withOpacity(0.2),
            ),
          ),
    );
  }

  Widget _buildErrorWidget() {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: widget.errorBuilder?.call() ??
          const Center(
            child: Icon(Icons.error),
          ),
    );
  }
}
