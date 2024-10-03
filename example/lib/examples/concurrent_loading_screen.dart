import 'package:flutter/material.dart';
import 'package:super_network_image/super_network_image.dart';

class ConcurrentLoadingScreen extends StatefulWidget {
  @override
  _ConcurrentLoadingScreenState createState() =>
      _ConcurrentLoadingScreenState();
}

class _ConcurrentLoadingScreenState extends State<ConcurrentLoadingScreen> {
  final String imageUrl =
      'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg';

  final String tagConcurrent = 'concurrent';

  List<bool> _loadedFromCache = List.filled(6, false);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Concurrent Image Loading'),
      ),
      body: Center(
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(6, (index) {
            return Stack(
              alignment: Alignment.center,
              children: [
                SuperNetworkImage(
                  url: imageUrl,
                  width: 100,
                  height: 100,
                  cacheDuration: Duration(minutes: index),
                  tag: tagConcurrent,
                  onLoad: (source) {
                    setState(() {
                      _loadedFromCache[index] = source == ImageSource.cache;
                    });
                  },
                ),
                Positioned(
                  bottom: 4,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    color: Colors.black54,
                    child: Text(
                      _loadedFromCache[index] ? 'Cache' : 'Network',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await SuperNetworkImageCache.clearCacheForTag(tagConcurrent);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cache cleared for tag: $tagConcurrent')),
          );
          setState(() {
            _loadedFromCache = List.filled(6, false);
          });
        },
        tooltip: 'Clear Cache',
        child: const Icon(Icons.delete),
      ),
    );
  }
}
