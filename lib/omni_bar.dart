import 'package:flutter/material.dart';

enum Sigil { web, did, bluesky, atproto }

class SemanticOmniBar extends StatelessWidget {
  final String identifier;
  final VoidCallback onTap;
  final Function(String) onNavigate;

  const SemanticOmniBar({
    super.key,
    required this.identifier,
    required this.onTap,
    required this.onNavigate,
  });

  Sigil _getSigil(String identifier) {
    if (identifier.startsWith('did:')) {
      return Sigil.did;
    }
    if (identifier.startsWith('@')) {
      return Sigil.bluesky;
    }
    if (identifier.startsWith('at:')) {
      return Sigil.atproto;
    }
    return Sigil.web;
  }

  String _getSigilIcon(Sigil sigil) {
    switch (sigil) {
      case Sigil.did:
        return '❈';
      case Sigil.bluesky:
        return '🦋';
      case Sigil.atproto:
        return '@';
      case Sigil.web:
      default:
        return '🌐';
    }
  }

  @override
  Widget build(BuildContext context) {
    final sigil = _getSigil(identifier);
    final sigilIcon = _getSigilIcon(sigil);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: const Color(0xFF1a202c), // bg-gray-900
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: const Color(0xFF4a5568), // bg-gray-700
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              Text(sigilIcon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 12),
              _buildBreadcrumbs(context, identifier),
              const SizedBox(width: 12),
              _buildQueryInspector(context, identifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQueryInspector(BuildContext context, String identifier) {
    if (!identifier.startsWith('http')) {
      return const SizedBox.shrink(); // No query params for non-http
    }
    try {
      final uri = Uri.parse(identifier);
      if (uri.queryParameters.isEmpty) {
        return const SizedBox.shrink();
      }

      return TextButton(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Query Parameters'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: uri.queryParameters.entries.length,
                    itemBuilder: (context, index) {
                      final entry =
                          uri.queryParameters.entries.elementAt(index);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${entry.key}: ',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Expanded(child: Text(entry.value)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  )
                ],
              );
            },
          );
        },
        child: Text('? Query (${uri.queryParameters.length})'),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildBreadcrumbs(BuildContext context, String identifier) {
    if (!identifier.startsWith('http')) {
      return Expanded(
        child: Text(
          identifier,
          style: const TextStyle(color: Color(0xFFe2e8f0), fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    try {
      final uri = Uri.parse(identifier);
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();

      if (segments.isEmpty) {
        // No path, just show hostname
        return Expanded(
          child: Text(
            uri.host,
            style: const TextStyle(color: Color(0xFFe2e8f0), fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }

      List<Widget> breadcrumbWidgets = [];
      breadcrumbWidgets.add(
        InkWell(
          onTap: () => onNavigate(uri.replace(path: '').toString()),
          child: Text(uri.host,
              style: const TextStyle(color: Color(0xFFe2e8f0), fontSize: 14)),
        ),
      );

      String currentPath = '';
      for (final segment in segments) {
        currentPath += '/$segment';
        final newUrl = uri.replace(path: currentPath).toString();

        breadcrumbWidgets
            .add(const Text(' / ', style: TextStyle(color: Colors.grey)));
        breadcrumbWidgets.add(
          InkWell(
            onTap: () => onNavigate(newUrl),
            child: Text(
              segment,
              style: const TextStyle(color: Color(0xFFe2e8f0), fontSize: 14),
            ),
          ),
        );
      }

      return Expanded(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: breadcrumbWidgets),
        ),
      );
    } catch (e) {
      // Fallback for invalid URI
      return Expanded(
        child: Text(
          identifier,
          style: const TextStyle(color: Color(0xFFe2e8f0), fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
  }
}
