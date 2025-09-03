import 'package:aura/models/at_proto_feed.dart';
import 'package:aura/models/at_proto_profile.dart';
import 'package:aura/services/bsky_api.dart';
import 'package:aura/widgets/post_view.dart';
import 'package:flutter/material.dart';

class AtprotoSpaceView extends StatefulWidget {
  final String identifier; // Can be a handle or a DID
  final Function(String url) onDidWebFallback;
  final BskyApi api;

  const AtprotoSpaceView(
      {super.key,
      required this.identifier,
      required this.onDidWebFallback,
      required this.api});

  @override
  State<AtprotoSpaceView> createState() => _AtprotoSpaceViewState();
}

class _AtprotoSpaceViewState extends State<AtprotoSpaceView> {
  Future<Map<String, dynamic>>? _dataFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant AtprotoSpaceView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.identifier != oldWidget.identifier) {
      _loadData();
    }
  }

  void _loadData() {
    setState(() {
      _dataFuture = _fetchData();
    });
  }

  Future<Map<String, dynamic>> _fetchData() async {
    try {
      String did = widget.identifier;
      if (did.startsWith('@')) {
        did = await widget.api.resolveHandle(did.substring(1));
      }

      final profileData = await widget.api.getProfile(did);
      final feedData = await widget.api.getAuthorFeed(did);

      final profile = AtprotoProfile.fromJson(profileData);
      final feed = AtprotoFeed.fromJson(feedData);

      return {'profile': profile, 'feed': feed};
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          if (widget.identifier.startsWith('did:web:') &&
              snapshot.error
                  .toString()
                  .toLowerCase()
                  .contains('profile not found')) {
            final domain = widget.identifier.substring(8);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.onDidWebFallback('https://$domain');
            });
            return const Center(
                child: Text("Profile not found, falling back to website..."));
          }
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                snapshot.error.toString(),
                textAlign: TextAlign.center,
              ),
            ),
          );
        } else if (snapshot.hasData) {
          final profile = snapshot.data!['profile'] as AtprotoProfile;
          final feed = snapshot.data!['feed'] as AtprotoFeed;

          return ListView(
            children: [
              _buildProfileHeader(profile),
              const Divider(),
              if (feed.feed.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("This user has no posts yet."),
                  ),
                ),
              ...feed.feed.map((post) => PostView(post: post)),
            ],
          );
        } else {
          return const Center(child: Text('No data.'));
        }
      },
    );
  }

  Widget _buildProfileHeader(AtprotoProfile profile) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage:
                profile.avatar != null ? NetworkImage(profile.avatar!) : null,
            child: profile.avatar == null
                ? const Icon(Icons.person, size: 40)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.displayName ?? profile.handle,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  '@${profile.handle}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                if (profile.description != null) ...[
                  const SizedBox(height: 8),
                  Text(profile.description!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
