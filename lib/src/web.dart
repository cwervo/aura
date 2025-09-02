// File: lib/src/web.dart
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'dart:ui_web' as ui;

class PlatformWebView extends StatefulWidget {
  final String url;
  const PlatformWebView({super.key, required this.url});

  @override
  State<PlatformWebView> createState() => _PlatformWebViewState();
}

class _PlatformWebViewState extends State<PlatformWebView> {
  final _iframeElement = html.IFrameElement();

  @override
  void initState() {
    super.initState();

    _iframeElement
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..src = widget.url;

    // Register the iframe element with a static view type
    ui.platformViewRegistry.registerViewFactory(
      'iframe-view',
      (int viewId) => _iframeElement,
    );
  }

  // When the widget's URL changes, update the iframe's src
  @override
  void didUpdateWidget(covariant PlatformWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.url != oldWidget.url) {
      _iframeElement.src = widget.url;
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(
      key: UniqueKey(), // Use a unique key to ensure rebuilds
      viewType: 'iframe-view',
    );
  }
}
