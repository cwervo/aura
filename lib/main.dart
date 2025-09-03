import 'package:aura/services/bsky_api.dart';
import 'package:aura/omni_bar.dart';
import 'package:aura/widgets/at_proto_space_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'favorites_bar.dart';
import 'platform_webview.dart';

void main() {
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
  bool _isEditingOmniBar = false;

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

  void _navigate(String location) {
    if (location.isEmpty) {
      setState(() => _isEditingOmniBar = false);
      return;
    }

    final bskyProfileRegex =
        RegExp(r'^https?:\/\/bsky\.app\/profile\/([\w:.-]+)');
    final profileMatch = bskyProfileRegex.firstMatch(location);

    if (profileMatch != null) {
      String identifier = profileMatch.group(1)!;
      if (!identifier.startsWith('did:')) {
        identifier = '@$identifier';
      }
      _omniBarController.text = identifier;
      _loadContent(identifier);
    } else if (location.startsWith('@') || location.startsWith('did:')) {
      _loadContent(location);
    } else if (location.startsWith('https://') ||
        location.startsWith('http://')) {
      _loadContent(location);
    } else if (location.contains('.') && !location.contains(' ')) {
      final url = 'https://$location';
      _omniBarController.text = url;
      _loadContent(url);
    } else {
      _loadContent(location);
    }
    setState(() => _isEditingOmniBar = false);
  }

  void _loadContent(String identifier) {
    _omniBarController.text = identifier;
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
    _navigate(location);
  }

  void _onDidWebFallback(String url) {
    _navigate(url);
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
              setState(() => _isEditingOmniBar = true);
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
              _buildOmniBar(),
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

  Widget _buildOmniBar() {
    if (_isEditingOmniBar) {
      return Container(
        color: const Color(0xFF1a202c),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: TextField(
          controller: _omniBarController,
          focusNode: _omniBarFocusNode,
          autofocus: true,
          onSubmitted: _navigate,
          onTapOutside: (_) => setState(() => _isEditingOmniBar = false),
          style: const TextStyle(color: Color(0xFFe2e8f0)),
          decoration: InputDecoration(
            hintText: 'Enter a URL, ATProto handle, or DID...',
            hintStyle: const TextStyle(color: Color(0xFFa0aec0)),
            filled: true,
            fillColor: const Color(0xFF4a5568),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide:
                  const BorderSide(color: Color(0xFF4299e1), width: 2.0),
            ),
          ),
        ),
      );
    }
    return SemanticOmniBar(
      identifier: _currentIdentifier,
      onTap: () {
        setState(() {
          _isEditingOmniBar = true;
        });
        _omniBarFocusNode.requestFocus();
      },
      onNavigate: _navigate,
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
        if (_currentIdentifier.startsWith('http')) {
          return PlatformWebView(url: _currentIdentifier);
        } else {
          return Center(
              child: Text(
                  "Cannot display '$_currentIdentifier'. Please enter a valid URL, handle, or DID."));
        }
    }
  }
}
