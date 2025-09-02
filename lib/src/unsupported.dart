// File: lib/src/unsupported.dart
import 'package:flutter/material.dart';

class PlatformWebView extends StatelessWidget {
  final String url;
  const PlatformWebView({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('WebView is not supported on this platform.'),
    );
  }
}
