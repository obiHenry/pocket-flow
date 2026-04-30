// shared/widgets/skeleton_box.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonBox extends StatelessWidget {
  final double height;
  final double width;
  final BoxShape shape;

  const SkeletonBox({
    super.key,
    required this.height,
    required this.width,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey,
          shape: shape,
          borderRadius: shape == BoxShape.rectangle
              ? BorderRadius.circular(12)
              : null,
        ),
      ),
    );
  }
}
