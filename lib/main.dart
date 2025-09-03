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

  final List<String> _history = [];
  int _historyIndex = -1;

  @override
  void initState() {
    super.initState();
    _omniBarController = TextEditingController(text: _currentIdentifier);
    _omniBarFocusNode = FocusNode();
    _bskyApi = widget.bskyApi ?? BskyApi();
    // Initialize history
    _history.add(_currentIdentifier);
    _historyIndex = 0;
  }

  @override
  void dispose() {
    _omniBarController.dispose();
    _omniBarFocusNode.dispose();
    super.dispose();
  }

  void _handleNavigationIntent(String location) {
    if (location.isEmpty) {
      setState(() => _isEditingOmniBar = false);
      return;
    }

    final bskyProfileRegex =
        RegExp(r'^https?:\/\/bsky\.app\/profile\/([\w:.-]+)');
    final profileMatch = bskyProfileRegex.firstMatch(location);

    String finalLocation = location;

    if (profileMatch != null) {
      String identifier = profileMatch.group(1)!;
      if (!identifier.startsWith('did:')) {
        identifier = '@$identifier';
      }
      finalLocation = identifier;
    } else if (!location.startsWith('@') &&
        !location.startsWith('did:') &&
        !location.startsWith('https://') &&
        !location.startsWith('http://')) {
      if (location.contains('.') && !location.contains(' ')) {
        finalLocation = 'https://$location';
      }
    }

    _navigateTo(finalLocation);
    setState(() => _isEditingOmniBar = false);
  }

  void _navigateTo(String location) {
    if (location == _currentIdentifier) return;

    setState(() {
      if (_historyIndex < _history.length - 1) {
        _history.removeRange(_historyIndex + 1, _history.length);
      }
      _history.add(location);
      _historyIndex++;
      _loadContent(location);
    });
  }

  void _goBack() {
    if (_historyIndex > 0) {
      setState(() {
        _historyIndex--;
        _loadContent(_history[_historyIndex]);
      });
    }
  }

  void _goForward() {
    if (_historyIndex < _history.length - 1) {
      setState(() {
        _historyIndex++;
        _loadContent(_history[_historyIndex]);
      });
    }
  }

  void _loadContent(String identifier) {
    _omniBarController.text = identifier;
    _currentIdentifier = identifier;
    if (identifier.startsWith('@') || identifier.startsWith('did:')) {
      _currentView = ViewType.atprotoSpace;
    } else {
      _currentView = ViewType.webview;
    }
  }

  void _onFavoriteSelected(String location) {
    _handleNavigationIntent(location);
  }

  void _onDidWebFallback(String url) {
    _handleNavigationIntent(url);
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
              _buildTopBar(),
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

  Widget _buildTopBar() {
    return Container(
      color: const Color(0xFF1a202c),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _historyIndex > 0 ? _goBack : null,
            color: Colors.white,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _historyIndex < _history.length - 1 ? _goForward : null,
            color: Colors.white,
          ),
          Expanded(child: _buildOmniBar()),
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () => _handleNavigationIntent('https://example.com'),
            color: Colors.white,
            tooltip: 'New Tab',
          ),
        ],
      ),
    );
  }

  Widget _buildOmniBar() {
    if (_isEditingOmniBar) {
      return SizedBox(
        height: 36,
        child: TextField(
          controller: _omniBarController,
          focusNode: _omniBarFocusNode,
          autofocus: true,
          onSubmitted: _handleNavigationIntent,
          onTapOutside: (_) => setState(() => _isEditingOmniBar = false),
          style: const TextStyle(color: Color(0xFFe2e8f0), fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Enter a URL, ATProto handle, or DID...',
            hintStyle:
                const TextStyle(color: Color(0xFFa0aec0), fontSize: 14),
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
      onNavigate: _handleNavigationIntent,
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
