// File: lib/platform_webview.dart

// This file uses conditional exports to provide the correct implementation
// of PlatformWebView depending on the compilation target.
export 'src/unsupported.dart'
    if (dart.library.html) 'src/web.dart'
    if (dart.library.io) 'src/native.dart';
