import 'package:flutter/material.dart';
import 'package:pocketflow/features/profile/data/models/user_model.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';

class ProfileHero extends StatelessWidget {
  final UserModel user;
  const ProfileHero({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: const Text(
                  "HO",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.edit, size: 16, color: Colors.white),
              ),
            ],
          ),
          AppSpacing.vMd,
          Text(user.displayName ?? "Henry Obi", style: AppTextStyles.h2),
          Text(
            user.email ?? "henry@pocketflow.dev",
            style: AppTextStyles.bodySmall,
          ),
          AppSpacing.vMd,
          SubscriptionBadge(),
        ],
      ),
    );
  }
}

class SubscriptionBadge extends StatelessWidget {
  final bool isPro;
  const SubscriptionBadge({super.key, this.isPro = true});

  @override
  Widget build(BuildContext context) {
    // In Phase 3, you'll check user.isPremium from the userProvider

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isPro
              ? [
                  const Color(0xFFFFD700),
                  const Color(0xFFFFA500),
                ] // Gold for Pro
              : [
                  Colors.grey.shade300,
                  Colors.grey.shade400,
                ], // Silver/Grey for Free
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          if (isPro)
            BoxShadow(
              color: const Color(0xFFFFA500).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPro ? Icons.auto_awesome : Icons.lock_outline,
            size: 14,
            color: isPro ? Colors.white : Colors.black54,
          ),
          const SizedBox(width: 6),
          Text(
            isPro ? "POCKETFLOW PRO" : "UPGRADE TO PRO",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: isPro ? Colors.white : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
