import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';

class UserProfileHeader extends ConsumerWidget {
  const UserProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In Phase 3, this will watch your UserProvider
    // final authState = ref.watch(userProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Avatar with Status Indicator
          const _UserAvatar(
            imageUrl: null, // Replace with authState.user.photoUrl later
            isOnline: true,
          ),
          AppSpacing.hMd,

          // 2. User Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Henry Obi", // authState.user.displayName
                style: AppTextStyles.h3.copyWith(fontSize: 18),
              ),
              Text(
                "henry@pocketflow.dev", // authState.user.email
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final bool isOnline;

  const _UserAvatar({this.imageUrl, this.isOnline = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 35,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
            child: imageUrl == null
                ? Text(
                    "HO",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
        ),
        if (isOnline)
          Positioned(
            right: 4,
            bottom: 4,
            child: Container(
              height: 14,
              width: 14,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
