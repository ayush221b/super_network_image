import 'package:flutter/material.dart';
import 'examples/basic_usage_screen.dart';
import 'examples/svg_support_screen.dart';
import 'examples/caching_demo_screen.dart';
import 'examples/custom_placeholder_error_screen.dart';
import 'examples/cache_tags_screen.dart';
import 'examples/image_fit_sizing_screen.dart';
import 'examples/concurrent_loading_screen.dart';
import 'package:super_network_image/super_network_image.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set a global cache duration (optional)
  SuperNetworkImageCache.setGlobalCacheDuration(const Duration(days: 7));

  runApp(SuperNetworkImageExampleApp());
}

class SuperNetworkImageExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Super Network Image Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatelessWidget {
  final List<ExampleItem> examples = [
    ExampleItem('Basic Usage', BasicUsageScreen()),
    ExampleItem('SVG Support', SvgSupportScreen()),
    ExampleItem('Caching Demonstration', CachingDemoScreen()),
    ExampleItem(
        'Custom Placeholder and Error Widgets', CustomPlaceholderErrorScreen()),
    ExampleItem('Cache Tags', CacheTagsScreen()),
    ExampleItem('Image Fit and Sizing', ImageFitSizingScreen()),
    ExampleItem('Concurrent Image Loading', ConcurrentLoadingScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Network Image Examples'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await SuperNetworkImageCache.clearAllCachedImages();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cache cleared for all images')),
          );
        },
        tooltip: 'Clear All Cache',
        child: const Icon(Icons.delete),
      ),
      body: ListView.builder(
        itemCount: examples.length,
        itemBuilder: (context, index) {
          final example = examples[index];
          return ListTile(
            title: Text(example.title),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => example.screen),
              );
            },
          );
        },
      ),
    );
  }
}

class ExampleItem {
  final String title;
  final Widget screen;

  ExampleItem(this.title, this.screen);
}
