import 'dart:convert';
import 'package:http/http.dart' as http;

class BskyApi {
  static const String _bskyPublicApi = 'https://public.api.bsky.app/xrpc';
  final http.Client _client;

  BskyApi({http.Client? client}) : _client = client ?? http.Client();

  Future<String> resolveHandle(String handle) async {
    final uri =
        Uri.parse('$_bskyPublicApi/com.atproto.identity.resolveHandle?handle=$handle');
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['did'];
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(
          'Could not resolve handle @$handle. Server says: ${errorData['message'] ?? 'Not Found'}');
    }
  }

  Future<Map<String, dynamic>> getProfile(String did) async {
    final uri = Uri.parse('$_bskyPublicApi/app.bsky.actor.getProfile?actor=$did');
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(
          'Profile not found for $did. Server says: ${errorData['message']}');
    }
  }

  Future<Map<String, dynamic>> getAuthorFeed(String did) async {
    final uri =
        Uri.parse('$_bskyPublicApi/app.bsky.feed.getAuthorFeed?actor=$did&limit=50');
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // It's possible for a user to have a profile but no posts, which can sometimes result in an error.
      // We'll return an empty feed in case of an error to be safe.
      return {'feed': []};
    }
  }
}
