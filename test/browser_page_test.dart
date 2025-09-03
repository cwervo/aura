import 'package:aura/main.dart';
import 'package:aura/platform_webview.dart';
import 'package:aura/services/bsky_api.dart';
import 'package:aura/widgets/at_proto_space_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'mock_api_responses.dart';

void main() {
  // A helper function to create a mock BskyApi
  BskyApi createMockApi(MockClientHandler handler) {
    return BskyApi(client: MockClient(handler));
  }

  // A helper function to pump the BrowserPage with a given mock API
  Future<void> pumpBrowserPage(WidgetTester tester, BskyApi api) async {
    // The AtprotoSpaceView uses NetworkImage, which throws errors in tests.
    // We can use this Image.network override to prevent that.
    await HttpOverrides.runZoned(() async {
      await tester.pumpWidget(
        MaterialApp(
          home: BrowserPage(bskyApi: api),
        ),
      );
    }, createHttpClient: (_) => FakeHttpClient());
  }

  testWidgets('BrowserPage shows webview on initial load', (tester) async {
    final api = createMockApi((request) async => http.Response('', 404));
    await pumpBrowserPage(tester, api);

    expect(find.byType(PlatformWebView), findsOneWidget);
    expect(find.text('https://example.com'), findsOneWidget);
  });

  testWidgets('Navigating to a handle shows AtprotoSpaceView', (tester) async {
    final api = createMockApi((request) async {
      if (request.url.toString().contains('resolveHandle')) {
        return http.Response(resolveHandleResponse, 200, headers: {'content-type': 'application/json'});
      }
      if (request.url.toString().contains('getProfile')) {
        return http.Response(getProfileResponse, 200, headers: {'content-type': 'application/json'});
      }
      if (request.url.toString().contains('getAuthorFeed')) {
        return http.Response(getAuthorFeedResponse, 200, headers: {'content-type': 'application/json'});
      }
      return http.Response('', 404);
    });
    await pumpBrowserPage(tester, api);

    // Enter handle in omnibar
    await tester.enterText(find.byType(TextField), '@mock.bsky.social');
    // Submit
    await tester.testTextInput.receiveAction(TextInputAction.done);
    // Wait for UI to update
    await tester.pumpAndSettle();

    // Verify that AtprotoSpaceView is shown
    expect(find.byType(AtprotoSpaceView), findsOneWidget);
    // Verify that the profile information is displayed
    expect(find.text('Mock User'), findsOneWidget);
    expect(find.text('@mock.bsky.social'), findsOneWidget);
    // Verify that the post is displayed
    expect(find.text('This is a mock post.'), findsOneWidget);
  });

  testWidgets('Navigating to a DID shows AtprotoSpaceView', (tester) async {
    final api = createMockApi((request) async {
      if (request.url.toString().contains('getProfile')) {
        return http.Response(getProfileResponse, 200, headers: {'content-type': 'application/json'});
      }
      if (request.url.toString().contains('getAuthorFeed')) {
        return http.Response(getAuthorFeedResponse, 200, headers: {'content-type': 'application/json'});
      }
      return http.Response('', 404);
    });
    await pumpBrowserPage(tester, api);

    await tester.enterText(find.byType(TextField), 'did:plc:mockdid');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.byType(AtprotoSpaceView), findsOneWidget);
    expect(find.text('Mock User'), findsOneWidget);
  });

  testWidgets('Navigating to a bsky.app URL shows AtprotoSpaceView',
      (tester) async {
    final api = createMockApi((request) async {
      if (request.url.toString().contains('resolveHandle')) {
        return http.Response(resolveHandleResponse, 200, headers: {'content-type': 'application/json'});
      }
      if (request.url.toString().contains('getProfile')) {
        return http.Response(getProfileResponse, 200, headers: {'content-type': 'application/json'});
      }
      if (request.url.toString().contains('getAuthorFeed')) {
        return http.Response(getAuthorFeedResponse, 200, headers: {'content-type': 'application/json'});
      }
      return http.Response('', 404);
    });
    await pumpBrowserPage(tester, api);

    await tester.enterText(
        find.byType(TextField), 'https://bsky.app/profile/mock.bsky.social');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.byType(AtprotoSpaceView), findsOneWidget);
    expect(find.text('Mock User'), findsOneWidget);
    // Also check that the omnibar text was updated to the handle
    expect(find.widgetWithText(TextField, '@mock.bsky.social'), findsOneWidget);
  });

  testWidgets('Switching from ATProto view back to webview works',
      (tester) async {
    final api = createMockApi((request) async {
      if (request.url.toString().contains('getProfile')) {
        return http.Response(getProfileResponse, 200, headers: {'content-type': 'application/json'});
      }
      if (request.url.toString().contains('getAuthorFeed')) {
        return http.Response(getAuthorFeedResponse, 200, headers: {'content-type': 'application/json'});
      }
      return http.Response('', 404);
    });
    await pumpBrowserPage(tester, api);

    // First, navigate to a DID
    await tester.enterText(find.byType(TextField), 'did:plc:mockdid');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.byType(AtprotoSpaceView), findsOneWidget);

    // Then, navigate to a web URL
    await tester.enterText(find.byType(TextField), 'https://flutter.dev');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // Verify that PlatformWebView is shown
    expect(find.byType(PlatformWebView), findsOneWidget);
    // And that AtprotoSpaceView is gone
    expect(find.byType(AtprotoSpaceView), findsNothing);
  });

  testWidgets('did:web fallback works correctly', (tester) async {
    final api = createMockApi((request) async {
      // Simulate a "Profile not found" error
      if (request.url.toString().contains('getProfile')) {
        return http.Response(
            '{"error": "NotFound", "message": "Profile not found"}', 404, headers: {'content-type': 'application/json'});
      }
      return http.Response('', 404);
    });
    await pumpBrowserPage(tester, api);

    await tester.enterText(find.byType(TextField), 'did:web:flutter.dev');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // Verify that the view switched to PlatformWebView
    expect(find.byType(PlatformWebView), findsOneWidget);
    // Verify that the omnibar text was updated to the fallback URL
    expect(
        find.widgetWithText(TextField, 'https://flutter.dev'), findsOneWidget);
  });
}

// A fake HttpClient that does nothing, to prevent NetworkImage from throwing errors in tests.
class FakeHttpClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(
      Stream.fromIterable([]),
      200,
    );
  }
}
