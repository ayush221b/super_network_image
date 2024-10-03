import 'package:flutter/material.dart';
import 'package:super_network_image/super_network_image.dart';

class BasicUsageScreen extends StatelessWidget {
  final String imageUrl =
      'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic Usage'),
      ),
      body: Center(
        child: SuperNetworkImage(
          url: imageUrl,
          width: 300,
          height: 300,
        ),
      ),
    );
  }
}
