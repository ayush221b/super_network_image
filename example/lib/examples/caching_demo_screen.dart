import 'package:flutter/material.dart';
import 'package:super_network_image/super_network_image.dart';

class CachingDemoScreen extends StatefulWidget {
  @override
  _CachingDemoScreenState createState() => _CachingDemoScreenState();
}

class _CachingDemoScreenState extends State<CachingDemoScreen> {
  final String imageUrl =
      'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg';

  bool _loadedFromCache = false;

  @override
  void initState() {
    super.initState();
  }

  void _clearCache() async {
    await SuperNetworkImageCache.clearCachedImage(imageUrl);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache cleared for image')),
    );
    setState(() {
      _loadedFromCache = false; // Reset the indicator
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caching Demonstration'),
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SuperNetworkImage(
              url: imageUrl,
              width: 300,
              height: 300,
              onLoad: (source) {
                setState(() {
                  _loadedFromCache = source == ImageSource.cache;
                });
              },
            ),
            Positioned(
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: Colors.black54,
                child: Text(
                  _loadedFromCache
                      ? 'Loaded from Cache'
                      : 'Loaded from Network',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _clearCache,
        tooltip: 'Clear Cache',
        child: const Icon(Icons.delete),
      ),
    );
  }
}
