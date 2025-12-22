import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageViewerScreen extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const ImageViewerScreen({
    super.key,
    required this.imageUrl,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Center(
        child: Hero(
          tag: heroTag,
          child: InteractiveViewer(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              placeholder: (c, u) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (c, u, e) => const Icon(
                Icons.broken_image,
                color: Colors.white54,
                size: 48,
              ),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
