// File: lib/main.dart
import 'package:flutter/material.dart';
import 'omni_bar.dart';
import 'favorites_bar.dart';
import 'platform_webview.dart'; // Import our new cross-platform widget

void main() {
  // This is still required for the native (desktop/mobile) versions to work.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AuraBrowserApp());
}

class AuraBrowserApp extends StatelessWidget {
  const AuraBrowserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aura Browser',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF2d3748), // bg-gray-800
      ),
      debugShowCheckedModeBanner: false,
      home: const BrowserPage(),
    );
  }
}

class BrowserPage extends StatefulWidget {
  const BrowserPage({super.key});

  @override
  State<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  late final TextEditingController _omniBarController;
  // The state is now just the URL string.
  late String _currentUrl;

  @override
  void initState() {
    super.initState();
    _currentUrl = 'https://example.com';
    _omniBarController = TextEditingController(text: _currentUrl);
  }

  @override
  void dispose() {
    _omniBarController.dispose();
    super.dispose();
  }

  void _navigate() {
    String location = _omniBarController.text.trim();
    if (location.isEmpty) return;

    // Basic protocol check for regular URLs
    if (!location.startsWith('http://') && !location.startsWith('https://')) {
      if (location.contains('.') && !location.contains(' ')) {
        location = 'https://$location';
      }
    }

    // For now, we only handle web URLs
    if (location.startsWith('https://') || location.startsWith('http://')) {
      // Update the state with the new URL, triggering a rebuild.
      setState(() {
        _currentUrl = location;
        _omniBarController.text = location; // Ensure omnibar is in sync
      });
    } else {
      // In the future, you can handle ATProto links here.
      print("ATProto navigation not implemented yet for: $location");
    }
  }

  void _onFavoriteSelected(String location) {
    // Set the omnibar text and navigate
    _omniBarController.text = location;
    _navigate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          OmniBar(controller: _omniBarController, onSubmitted: _navigate),
          FavoritesBar(onFavoriteSelected: _onFavoriteSelected),
          Expanded(
            // Use our new cross-platform widget.
            // It will automatically be an iframe on web and a WebView on desktop.
            child: PlatformWebView(url: _currentUrl),
          ),
        ],
      ),
    );
  }
}
