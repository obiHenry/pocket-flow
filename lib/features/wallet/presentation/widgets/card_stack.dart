import 'package:flutter/material.dart';
import 'package:pocketflow/core/constants/app_text_styles.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_helper.dart';

class CardStack extends StatelessWidget {
  final double balance;
  final double monthlyExpense;
  final double monthlyIncome;

  const CardStack({
    super.key,
    required this.balance,
    this.monthlyExpense = 0,
    this.monthlyIncome = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    final total = monthlyIncome + monthlyExpense;
    final spendingProgress = total > 0 ? (monthlyExpense / total).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Primary Wallet",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const Icon(Icons.contactless, color: Colors.white, size: 28),
                  ],
                ),
                const Spacer(),
                Text(
                  "₦${balance.toStringAsFixed(2)}",
                  style: AppTextStyles.h1.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                  ),
                ),
                const Spacer(),
                Text(
                  "**** **** **** 4290",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),

          if (isDesktop) ...[
            const VerticalDivider(
              color: Colors.white24,
              indent: 10,
              endIndent: 10,
            ),
            const SizedBox(width: 32),
            _CardStats(
              label: "This Month",
              value: "₦${monthlyExpense.toStringAsFixed(0)}",
              sublabel: "of ₦${(monthlyIncome).toStringAsFixed(0)} income",
              progress: spendingProgress,
            ),
          ],
        ],
      ),
    );
  }
}

class _CardStats extends StatelessWidget {
  final String label;
  final String value;
  final String sublabel;
  final double progress;

  const _CardStats({
    required this.label,
    required this.value,
    required this.sublabel,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 10,
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.h3.copyWith(color: Colors.white, fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(
          sublabel,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 120,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
