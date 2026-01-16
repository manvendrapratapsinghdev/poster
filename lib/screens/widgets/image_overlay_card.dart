import 'package:flutter/material.dart';

class ImageOverlayCard extends StatelessWidget {
  final String backgroundUrl;
  final String foregroundUrl;
  final IconData topIcon;
  final VoidCallback? onIconTap;

  const ImageOverlayCard({
    super.key,
    required this.backgroundUrl,
    required this.foregroundUrl,
    this.topIcon = Icons.favorite,
    this.onIconTap,
  });

  @override
  Widget build(BuildContext context) {
    const double cardHeight = 200; // total card height
    const double foregroundRatio = 0.15; // 20% of height
    final double foregroundHeight = cardHeight * foregroundRatio;

    return SizedBox(
      height: cardHeight,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              backgroundUrl,
              width: double.infinity,
              height: cardHeight,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                width: double.infinity,
                height: cardHeight,
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 50),
              ),
            ),
          ),

          // Foreground Image (full width, 20% height, aligned bottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
              child: Image.network(
                foregroundUrl,
                height: foregroundHeight,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  width: double.infinity,
                  height: foregroundHeight,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image),
                ),
              ),
            ),
          ),

          // Top-right Icon
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onIconTap,
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.7),
                child: Icon(topIcon, color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
