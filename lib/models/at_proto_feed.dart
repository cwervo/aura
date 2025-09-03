class AtprotoFeed {
  final List<FeedPost> feed;

  AtprotoFeed({required this.feed});

  factory AtprotoFeed.fromJson(Map<String, dynamic> json) {
    final List<dynamic> feedList = json['feed'];
    return AtprotoFeed(
      feed: feedList.map((item) => FeedPost.fromJson(item['post'])).toList(),
    );
  }
}

class FeedPost {
  final String uri;
  final Author author;
  final PostRecord record;
  final Embed? embed;

  FeedPost({
    required this.uri,
    required this.author,
    required this.record,
    this.embed,
  });

  factory FeedPost.fromJson(Map<String, dynamic> json) {
    return FeedPost(
      uri: json['uri'],
      author: Author.fromJson(json['author']),
      record: PostRecord.fromJson(json['record']),
      embed: json['embed'] != null ? Embed.fromJson(json['embed']) : null,
    );
  }
}

class Author {
  final String did;
  final String handle;
  final String? displayName;
  final String? avatar;

  Author({
    required this.did,
    required this.handle,
    this.displayName,
    this.avatar,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      did: json['did'],
      handle: json['handle'],
      displayName: json['displayName'],
      avatar: json['avatar'],
    );
  }
}

class PostRecord {
  final String text;
  final DateTime createdAt;

  PostRecord({required this.text, required this.createdAt});

  factory PostRecord.fromJson(Map<String, dynamic> json) {
    return PostRecord(
      text: json['text'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class Embed {
  final String type;
  final List<EmbedImage>? images;

  Embed({required this.type, this.images});

  factory Embed.fromJson(Map<String, dynamic> json) {
    List<EmbedImage>? images;
    if (json['images'] != null) {
      final List<dynamic> imageList = json['images'];
      images = imageList.map((item) => EmbedImage.fromJson(item)).toList();
    }
    return Embed(
      type: json[r'$type'],
      images: images,
    );
  }
}

class EmbedImage {
  final String thumb;
  final String alt;

  EmbedImage({required this.thumb, required this.alt});

  factory EmbedImage.fromJson(Map<String, dynamic> json) {
    return EmbedImage(
      thumb: json['thumb'],
      alt: json['alt'] ?? '',
    );
  }
}
