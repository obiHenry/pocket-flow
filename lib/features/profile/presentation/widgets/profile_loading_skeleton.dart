import 'package:flutter/material.dart';

import '../../../../shared/widgets/skeleton_box.dart';

class ProfileLoadingSkeleton extends StatelessWidget {
  const ProfileLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const SkeletonBox(
            height: 120,
            width: 120,
            // borderRadius: 60,
          ), // Avatar
          const SizedBox(height: 16),
          const SkeletonBox(height: 20, width: 150), // Name
          const SizedBox(height: 40),
          // Section Skeletons
          ...List.generate(
            3,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: SkeletonBox(
                height: 180,
                width: double.infinity,
                // borderRadius: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
