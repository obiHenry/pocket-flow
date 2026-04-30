import 'package:flutter/material.dart';

import '../../../../shared/widgets/skeleton_box.dart';

class TransactionsLoadingSkeleton extends StatelessWidget {
  const TransactionsLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SkeletonBox(
            height: 50,
            width: double.infinity,
          ), // Search bar shimmer
          const SizedBox(height: 20),
          Row(
            children: List.generate(
              3,
              (i) => const Padding(
                padding: EdgeInsets.only(right: 10),
                child: SkeletonBox(height: 35, width: 80), // Filter chips
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class TransactionSkeleton extends StatelessWidget {
  const TransactionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: 8,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            const SkeletonBox(height: 48, width: 48), // Icon
            const SizedBox(width: 16),
            const Expanded(
              child: SkeletonBox(height: 20, width: double.infinity),
            ),
            const SizedBox(width: 40),
            const SkeletonBox(height: 20, width: 60), // Amount
          ],
        ),
      ),
    );
  }
}
