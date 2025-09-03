const String resolveHandleResponse = '''
{
  "did": "did:plc:mockdid"
}
''';

const String getProfileResponse = '''
{
  "did": "did:plc:mockdid",
  "handle": "mock.bsky.social",
  "displayName": "Mock User",
  "description": "This is a mock user for testing.",
  "avatar": "https://pds.vsky.app/img/banner/plain/ai/x-Z55Z-Z55Z-Z55Z/bafkreic7a2v7t3ncsj2qg3z4z6y5z6y5z6y5z6y5z6y5z6y5z6y5/1080x1080"
}
''';

const String getAuthorFeedResponse = '''
{
  "feed": [
    {
      "post": {
        "uri": "at://did:plc:mockdid/app.bsky.feed.post/3kpt3tq6j2l2q",
        "cid": "bafyreih3s2n25gqg6d5qkz4qg3z4z6y5z6y5z6y5z6y5z6y5z6y5",
        "author": {
          "did": "did:plc:mockdid",
          "handle": "mock.bsky.social",
          "displayName": "Mock User",
          "avatar": "https://pds.vsky.app/img/banner/plain/ai/x-Z55Z-Z55Z-Z55Z/bafkreic7a2v7t3ncsj2qg3z4z6y5z6y5z6y5z6y5z6y5z6y5z6y5/1080x1080"
        },
        "record": {
          "text": "This is a mock post.",
          "createdAt": "2023-10-27T19:53:08.539Z"
        }
      }
    }
  ]
}
''';

const String getEmptyAuthorFeedResponse = '''
{
  "feed": []
}
''';
