import 'package:flutter/material.dart';

// A simple data class for our favorite items
class FavoriteItem {
  final String display;
  final String location;
  final String emoji;
  final String tooltip;

  FavoriteItem({
    required this.display,
    required this.location,
    required this.emoji,
    required this.tooltip,
  });
}

class FavoritesBar extends StatelessWidget {
  // A callback function that the parent will give us.
  // When a button is pressed, we'll call this function with the location.
  final Function(String) onFavoriteSelected;

  FavoritesBar({super.key, required this.onFavoriteSelected});

  // Hardcoded list of favorites from your prototype
  final List<FavoriteItem> _favorites = [
    FavoriteItem(
      display: 'example.com',
      location: 'https://example.com',
      emoji: '🌐',
      tooltip: 'Web Address',
    ),
    FavoriteItem(
      display: 'Alice',
      location: 'did:plc:by3jhwdqgbtrcc7q4tkkv3cf',
      emoji: '✨',
      tooltip: 'DID',
    ),
    FavoriteItem(
      display: 'alice.mosphere.at',
      location: '@alice.mosphere.at',
      emoji: '🦋',
      tooltip: 'Bluesky Handle',
    ),
    FavoriteItem(
      display: 'cwervo',
      location: '@cwervo.bsky.social',
      emoji: '🦋',
      tooltip: 'Bluesky Handle',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
      decoration: const BoxDecoration(
        color: Color(0xFF1a202c), // bg-gray-900
        border: Border(
          top: BorderSide(color: Color(0x802d3748)),
        ), // border-gray-800/50
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _favorites.map((item) {
            return Tooltip(
              message: item.tooltip,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: TextButton(
                  onPressed: () {
                    // When pressed, call the callback with the item's location
                    onFavoriteSelected(item.location);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor:
                        const Color(0xFFcbd5e0), // text-gray-300
                    backgroundColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 6.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                  ).copyWith(
                    overlayColor: MaterialStateProperty.all(
                      const Color(0x804a5568),
                    ), // hover:bg-gray-700/50
                  ),
                  child: Text('${item.emoji} ${item.display}'),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
