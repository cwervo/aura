# Aura Browser Prototype

This project is a prototype of a web browser with experimental support for decentralized identity through the AT Protocol.

## Browser Prototype Functionality

The Aura Browser has the following features:

*   **Hybrid View:** Can render standard web pages using a webview, or a native-like "ATProto Space" view for decentralized identity content.
*   **Advanced OmniBar:** The address bar can handle:
    *   Standard URLs (e.g., `https://example.com`)
    *   AT Protocol handles (e.g., `@alice.bsky.social`)
    *   AT Protocol DIDs (e.g., `did:plc:..`)
    *   Bluesky profile URLs (e.g., `https://bsky.app/profile/alice.bsky.social`)
*   **ATProto Space View:** When you navigate to an AT Protocol identifier, the browser renders a custom view that displays the user's profile and a feed of their recent posts, fetched directly from the Bluesky public API.
*   **did:web Fallback:** If a `did:web:` profile is not found on the AT Protocol, the browser automatically falls back to displaying the corresponding website.
*   **Favorites Bar with Tooltips:** The favorites bar provides quick access to a few sample locations. Hover over them to see a tooltip describing the link type.
*   **Keyboard Shortcuts:** Press `Cmd+L` (on macOS) or `Ctrl+L` (on other platforms) to quickly focus the address bar.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
