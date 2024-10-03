import 'package:flutter/material.dart';
import 'package:super_network_image/super_network_image.dart';

class CustomPlaceholderErrorScreen extends StatelessWidget {
  final String invalidImageUrl = 'https://example.com/invalid-image.jpg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Placeholder and Error Widgets'),
      ),
      body: Center(
        child: SuperNetworkImage(
          url: invalidImageUrl,
          width: 300,
          height: 300,
          placeholderBuilder: () => const Center(
            child:
                Text('Custom Loading...', style: TextStyle(color: Colors.grey)),
          ),
          errorBuilder: () => const Center(
            child: Text('Custom Error: Failed to load image',
                style: TextStyle(color: Colors.red)),
          ),
        ),
      ),
    );
  }
}
