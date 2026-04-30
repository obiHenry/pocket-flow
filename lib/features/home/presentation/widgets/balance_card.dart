import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/skeleton_box.dart';
import '../../../profile/presentation/providers/user_provider.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';

class BalanceCard extends ConsumerWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final transactions = ref.watch(transactionProvider).valueOrNull ?? [];

    return userAsync.when(
      loading: () => const SkeletonBox(height: 200, width: double.infinity),
      error: (err, _) => const Center(child: Text("Failed to load balance")),
      data: (user) {
        final balance = user?.balance ?? 0.0;

        final now = DateTime.now();
        final monthTxs = transactions.where(
          (tx) => tx.date.year == now.year && tx.date.month == now.month,
        );
        final income = monthTxs
            .where((tx) => tx.type == 'Credit')
            .fold(0.0, (sum, tx) => sum + tx.amount);
        final expense = monthTxs
            .where((tx) => tx.type == 'Debit')
            .fold(0.0, (sum, tx) => sum + tx.amount);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total Balance",
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
              ),
              AppSpacing.vSm,
              Text(
                "₦${balance.toStringAsFixed(2)}",
                style: AppTextStyles.h1.copyWith(
                  color: Colors.white,
                  fontSize: 32,
                ),
              ),
              AppSpacing.vLg,
              Row(
                children: [
                  _SummaryChip(
                    icon: Icons.arrow_upward,
                    color: Colors.greenAccent,
                    label: "Income",
                    value: "₦${income.toStringAsFixed(0)}",
                  ),
                  const SizedBox(width: 24),
                  _SummaryChip(
                    icon: Icons.arrow_downward,
                    color: Colors.redAccent,
                    label: "Expense",
                    value: "₦${expense.toStringAsFixed(0)}",
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  const _SummaryChip({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
