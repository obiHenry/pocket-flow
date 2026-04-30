import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';

class AssetAllocationSection extends ConsumerWidget {
  const AssetAllocationSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionProvider).valueOrNull ?? [];

    final totalIncome = transactions
        .where((tx) => tx.type == 'Credit')
        .fold(0.0, (s, tx) => s + tx.amount);
    final totalExpense = transactions
        .where((tx) => tx.type == 'Debit')
        .fold(0.0, (s, tx) => s + tx.amount);
    final total = totalIncome + totalExpense;

    final spendingPct = total > 0 ? totalExpense / total : 0.5;
    final savingsPct = total > 0 ? totalIncome / total : 0.5;

    final spendingLabel = '${(spendingPct * 100).toStringAsFixed(0)}%';
    final savingsLabel = '${(savingsPct * 100).toStringAsFixed(0)}%';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: spendingPct,
                      color: AppColors.primary,
                      radius: 10,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      value: savingsPct,
                      color: Colors.orange,
                      radius: 10,
                      showTitle: false,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AllocationLegend(
                    label: "Spending",
                    percent: spendingLabel,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 8),
                  _AllocationLegend(
                    label: "Income",
                    percent: savingsLabel,
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllocationLegend extends StatelessWidget {
  final String label;
  final String percent;
  final Color color;

  const _AllocationLegend({
    required this.label,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 12,
          width: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.bodyMedium),
        const Spacer(),
        Text(
          percent,
          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
