// File: lib/omni_bar.dart
import 'package:flutter/material.dart';

class OmniBar extends StatelessWidget {
  final TextEditingController controller;
  // This callback allows the parent to know when the user presses "Enter".
  final VoidCallback onSubmitted;

  const OmniBar({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1a202c), // bg-gray-900
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Row(
        children: [
          Row(
            children: [
              _buildTrafficLight(const Color(0xFFff5f56)), // Red
              const SizedBox(width: 6),
              _buildTrafficLight(const Color(0xFFffbd2e)), // Yellow
              const SizedBox(width: 6),
              _buildTrafficLight(const Color(0xFF27c93f)), // Green
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              // Add the onSubmitted handler to trigger navigation
              onSubmitted: (_) => onSubmitted(),
              style: const TextStyle(color: Color(0xFFe2e8f0)), // text-gray-200
              decoration: InputDecoration(
                hintText: 'Enter a URL, ATProto handle, or DID...',
                hintStyle: const TextStyle(
                  color: Color(0xFFa0aec0),
                ), // text-gray-400
                filled: true,
                fillColor: const Color(0xFF4a5568), // bg-gray-700
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: Color(0xFF4299e1),
                    width: 2.0,
                  ), // ring-blue-500
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrafficLight(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
