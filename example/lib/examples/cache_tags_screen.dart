import 'package:flutter/material.dart';
import 'package:super_network_image/super_network_image.dart';

class CacheTagsScreen extends StatefulWidget {
  @override
  _CacheTagsScreenState createState() => _CacheTagsScreenState();
}

class _CacheTagsScreenState extends State<CacheTagsScreen> {
  final String imageUrl1 =
      'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg';
  final String imageUrl2 =
      'https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/410.svg';

  final String tagAnimals = 'animals';
  final String tagGraphics = 'graphics';

  bool _loadedFromCache1 = false;
  bool _loadedFromCache2 = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cache Tags'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text('Image with Tag: $tagAnimals'),
            _buildImageWithCacheIndicator(
              imageUrl1,
              tagAnimals,
              (loadedFromCache) {
                setState(() {
                  _loadedFromCache1 = loadedFromCache;
                });
              },
            ),
            const SizedBox(height: 16),
            Text('Image with Tag: $tagGraphics'),
            _buildImageWithCacheIndicator(
              imageUrl2,
              tagGraphics,
              (loadedFromCache) {
                setState(() {
                  _loadedFromCache2 = loadedFromCache;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await SuperNetworkImageCache.clearCacheForTag(tagAnimals);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Cache cleared for tag: $tagAnimals')),
                );
                setState(() {
                  _loadedFromCache1 = false;
                });
              },
              child: Text('Clear Cache for $tagAnimals'),
            ),
            ElevatedButton(
              onPressed: () async {
                await SuperNetworkImageCache.clearCacheForTag(tagGraphics);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Cache cleared for tag: $tagGraphics')),
                );
                setState(() {
                  _loadedFromCache2 = false;
                });
              },
              child: Text('Clear Cache for $tagGraphics'),
            ),
            ElevatedButton(
              onPressed: () async {
                await SuperNetworkImageCache.clearAllCachedImages();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All cache cleared')),
                );
                setState(() {
                  _loadedFromCache1 = false;
                  _loadedFromCache2 = false;
                });
              },
              style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Clear All Cache'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWithCacheIndicator(
      String url, String tag, Function(bool) onLoadCallback) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SuperNetworkImage(
          url: url,
          width: 200,
          height: 200,
          tag: tag,
          onLoad: (source) {
            onLoadCallback(source == ImageSource.cache);
          },
        ),
        Positioned(
          bottom: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: Colors.black54,
            child: Text(
              (tag == tagAnimals && _loadedFromCache1) ||
                      (tag == tagGraphics && _loadedFromCache2)
                  ? 'Loaded from Cache'
                  : 'Loaded from Network',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
