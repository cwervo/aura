import 'package:aura/services/bsky_api.dart';
import 'package:aura/widgets/at_proto_space_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

enum ViewType { webview, atprotoSpace }

class BrowserPage extends StatefulWidget {
  final BskyApi? bskyApi;
  const BrowserPage({super.key, this.bskyApi});

  @override
  State<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  late final TextEditingController _omniBarController;
  late final FocusNode _omniBarFocusNode;
  late final BskyApi _bskyApi;

  ViewType _currentView = ViewType.webview;
  String _currentIdentifier = 'https://example.com';

  @override
  void initState() {
    super.initState();
    _omniBarController = TextEditingController(text: _currentIdentifier);
    _omniBarFocusNode = FocusNode();
    _bskyApi = widget.bskyApi ?? BskyApi();
  }

  @override
  void dispose() {
    _omniBarController.dispose();
    _omniBarFocusNode.dispose();
    super.dispose();
  }

  void _navigate() {
    // Sanitize the input to remove invisible characters that can break API calls.
    String location = _omniBarController.text
        .replaceAll(RegExp(r'[\u200B-\u200D\uFEFF\u202A-\u202E]'), '')
        .trim();
    if (location.isEmpty) return;

    // Check for Bluesky profile/post URLs and extract the identifier or full URL
    final bskyProfileRegex =
        RegExp(r'^https?:\/\/bsky\.app\/profile\/([\w:.-]+)');
    final bskyPostRegex =
        RegExp(r'^https?:\/\/bsky\.app\/profile\/[\w:.-]+\/post\/[a-zA-Z0-9]+');

    final profileMatch = bskyProfileRegex.firstMatch(location);
    final postMatch = bskyPostRegex.firstMatch(location);

    if (profileMatch != null && profileMatch.group(1) != null) {
      // It's a bsky profile URL, we navigate to the identifier directly
      location = profileMatch.group(1)!;
      // Prepend @ if it's a handle, otherwise it's a DID.
      if (!location.startsWith('did:')) {
        location = '@$location';
      }
    } else if (postMatch != null) {
      // This is a post URL, we'll let it be handled by loadWebView
    } else {
      // Basic protocol check for regular URLs
      if (!location.startsWith('http://') &&
          !location.startsWith('https://') &&
          !location.startsWith('@') &&
          !location.startsWith('did:')) {
        if (location.contains('.') && !location.contains(' ')) {
          location = 'https://$location';
        }
      }
    }

    _omniBarController.text = location; // Update bar with corrected URL/identifier
    _loadContent(location);
  }

  void _loadContent(String identifier) {
    if (identifier.startsWith('@') || identifier.startsWith('did:')) {
      setState(() {
        _currentIdentifier = identifier;
        _currentView = ViewType.atprotoSpace;
      });
    } else {
      setState(() {
        _currentIdentifier = identifier;
        _currentView = ViewType.webview;
      });
    }
  }

  void _onFavoriteSelected(String location) {
    // Set the omnibar text and navigate
    _omniBarController.text = location;
    _navigate();
  }

  void _onDidWebFallback(String url) {
    _omniBarController.text = url;
    _loadContent(url);
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(
          Theme.of(context).platform == TargetPlatform.macOS
              ? LogicalKeyboardKey.meta
              : LogicalKeyboardKey.control,
          LogicalKeyboardKey.keyL,
        ): const ActivateIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (ActivateIntent intent) {
              _omniBarFocusNode.requestFocus();
              _omniBarController.selection = TextSelection(
                baseOffset: 0,
                extentOffset: _omniBarController.text.length,
              );
              return null;
            },
          ),
        },
        child: Scaffold(
          body: Column(
            children: [
              OmniBar(
                controller: _omniBarController,
                onSubmitted: _navigate,
                focusNode: _omniBarFocusNode,
              ),
              FavoritesBar(onFavoriteSelected: _onFavoriteSelected),
              Expanded(
                child: _buildContentView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentView() {
    switch (_currentView) {
      case ViewType.atprotoSpace:
        return AtprotoSpaceView(
          identifier: _currentIdentifier,
          onDidWebFallback: _onDidWebFallback,
          api: _bskyApi,
        );
      case ViewType.webview:
      default:
        // Ensure we have a valid URL for the webview
        if (_currentIdentifier.startsWith('http')) {
          return PlatformWebView(url: _currentIdentifier);
        } else {
          // If the identifier is not a valid URL (e.g. a search query), show a message.
          return Center(
              child: Text(
                  "Cannot display '$_currentIdentifier'. Please enter a valid URL, handle, or DID."));
        }
    }
  }
}
