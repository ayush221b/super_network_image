import 'package:flutter/material.dart';
import 'package:super_network_image/super_network_image.dart';

class ImageFitSizingScreen extends StatelessWidget {
  final String imageUrl =
      'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Fit and Sizing'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          const Text('BoxFit.cover'),
          SuperNetworkImage(
            url: imageUrl,
            width: 300,
            height: 100,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 16),
          const Text('BoxFit.contain'),
          SuperNetworkImage(
            url: imageUrl,
            width: 300,
            height: 100,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
