class AtprotoProfile {
  final String did;
  final String handle;
  final String? displayName;
  final String? description;
  final String? avatar;

  AtprotoProfile({
    required this.did,
    required this.handle,
    this.displayName,
    this.description,
    this.avatar,
  });

  factory AtprotoProfile.fromJson(Map<String, dynamic> json) {
    return AtprotoProfile(
      did: json['did'],
      handle: json['handle'],
      displayName: json['displayName'],
      description: json['description'],
      avatar: json['avatar'],
    );
  }
}
