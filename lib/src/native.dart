// File: lib/src/native.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PlatformWebView extends StatefulWidget {
  final String url;
  const PlatformWebView({super.key, required this.url});

  @override
  State<PlatformWebView> createState() => _PlatformWebViewState();
}

class _PlatformWebViewState extends State<PlatformWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  // When the widget's URL changes, tell the controller to load the new page
  @override
  void didUpdateWidget(covariant PlatformWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.url != oldWidget.url) {
      _controller.loadRequest(Uri.parse(widget.url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
