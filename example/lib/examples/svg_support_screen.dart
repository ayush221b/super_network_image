import 'package:flutter/material.dart';
import 'package:super_network_image/super_network_image.dart';

class SvgSupportScreen extends StatelessWidget {
  final String svgImageUrl =
      'https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/410.svg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SVG Support'),
      ),
      body: Center(
        child: SuperNetworkImage(
          url: svgImageUrl,
          width: 300,
          height: 300,
        ),
      ),
    );
  }
}
