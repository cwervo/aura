import 'package:aura/models/at_proto_feed.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class PostView extends StatelessWidget {
  final FeedPost post;

  const PostView({super.key, required this.post});

  // Utility to launch a URL
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Could show a snackbar or toast
      print('Could not launch $url');
    }
  }

  // Utility to format text with markdown links
  List<TextSpan> _formatPostText(BuildContext context, String text) {
    final List<TextSpan> spans = [];
    final linkRegex = RegExp(r'\[([^\]]+)\]\((https?:\/\/[^\s)]+)\)');

    text.splitMapJoin(
      linkRegex,
      onMatch: (m) {
        final linkText = m.group(1)!;
        final url = m.group(2)!;
        spans.add(
          TextSpan(
            text: linkText,
            style: const TextStyle(color: Colors.blue),
            recognizer: TapGestureRecognizer()..onTap = () => _launchUrl(url),
          ),
        );
        return '';
      },
      onNonMatch: (n) {
        spans.add(TextSpan(text: n));
        return '';
      },
    );

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final rkey = post.uri.split('/').last;
    final postUrl = 'https://bsky.app/profile/${post.author.handle}/post/$rkey';
    final createdAt =
        DateFormat.yMd().add_jm().format(post.record.createdAt.toLocal());

    return Card(
      elevation: 0,
      color: const Color(0xFF1A202C), // bg-gray-900
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF4A5568), width: 0.5), // border-gray-600
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Header
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: post.author.avatar != null
                      ? NetworkImage(post.author.avatar!)
                      : null,
                  child: post.author.avatar == null
                      ? const Icon(Icons.person, size: 20)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author.displayName ?? post.author.handle,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      InkWell(
                        onTap: () => _launchUrl(postUrl),
                        child: Text(
                          createdAt,
                          style:
                              TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.open_in_new,
                      size: 16, color: Colors.grey[400]),
                  onPressed: () => _launchUrl(postUrl),
                  tooltip: 'Open post in browser',
                )
              ],
            ),
            const SizedBox(height: 12),

            // Post Body
            if (post.record.text.isNotEmpty)
              RichText(
                text: TextSpan(
                  style:
                      DefaultTextStyle.of(context).style.copyWith(fontSize: 15),
                  children: _formatPostText(context, post.record.text),
                ),
              ),

            // Post Embed
            if (post.embed?.images != null && post.embed!.images!.isNotEmpty)
              _buildEmbedImages(post.embed!.images!),
          ],
        ),
      ),
    );
  }

  Widget _buildEmbedImages(List<EmbedImage> images) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: images.length > 1 ? 2 : 1,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: images.length,
          itemBuilder: (context, index) {
            final image = images[index];
            return Image.network(
              image.thumb,
              fit: BoxFit.cover,
              // Add a placeholder and error widget for better UX
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(child: Icon(Icons.error));
              },
            );
          },
        ),
      ),
    );
  }
}
