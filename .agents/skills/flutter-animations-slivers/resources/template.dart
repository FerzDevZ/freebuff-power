// Custom SliverPersistentHeaderDelegate Template
import 'package:flutter/material.dart';

class CustomHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minExtentHeight;
  final double maxExtentHeight;
  final Widget Function(BuildContext context, double shrinkOffset, bool overlapsContent) builder;

  CustomHeaderDelegate({
    required this.minExtentHeight,
    required this.maxExtentHeight,
    required this.builder,
  });

  @override
  double get minExtent => minExtentHeight;

  @override
  double get maxExtent => maxExtentHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return builder(context, shrinkOffset, overlapsContent);
  }

  @override
  bool shouldRebuild(covariant CustomHeaderDelegate oldDelegate) {
    return minExtentHeight != oldDelegate.minExtentHeight ||
           maxExtentHeight != oldDelegate.maxExtentHeight ||
           builder != oldDelegate.builder;
  }
}
