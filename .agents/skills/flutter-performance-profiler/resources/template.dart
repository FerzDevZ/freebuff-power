// Memory-optimized Image Widget
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OptimizedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;

  const OptimizedNetworkImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      // Restrict memory cache footprint
      memCacheWidth: (width * MediaQuery.devicePixelRatioOf(context)).round(),
      memCacheHeight: (height * MediaQuery.devicePixelRatioOf(context)).round(),
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      errorWidget: (context, url, error) => const Icon(Icons.broken_image),
    );
  }
}
