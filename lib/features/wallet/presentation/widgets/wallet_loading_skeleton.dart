import 'package:flutter/material.dart';

import '../../../../shared/widgets/skeleton_box.dart';

class WalletLoadingSkeleton extends StatelessWidget {
  const WalletLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          // Card Skeleton
          const SkeletonBox(height: 220, width: double.infinity),
          const SizedBox(height: 32),

          // Chart Section Skeleton
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const SkeletonBox(height: 80, width: 80), // Circle Shimmer
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: List.generate(
                      2,
                      (i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: const SkeletonBox(
                          height: 15,
                          width: double.infinity,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          const SkeletonBox(height: 25, width: 100), // "Activity" Text
          const SizedBox(height: 20),

          // List Item Skeletons
          Column(
            children: List.generate(
              4,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    const SkeletonBox(height: 50, width: 50),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SkeletonBox(height: 15, width: 120),
                          const SizedBox(height: 8),
                          const SkeletonBox(height: 10, width: 80),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
