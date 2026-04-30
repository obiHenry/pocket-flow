import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketflow/core/constants/app_sizes.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../shared/widgets/skeleton_box.dart';
import '../../../transaction/data/models/transaction_model.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';
import '../../data/models/weekly_transaction_model.dart';

class ExpenseChart extends ConsumerWidget {
  const ExpenseChart({super.key});

  List<WeeklyTransactionData> _buildWeeklyData(
    List<TransactionModel> transactions,
  ) {
    final now = DateTime.now();
    const labels = ['Mn', 'Te', 'Wd', 'Tu', 'Fr', 'St', 'Sn'];

    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final dayTxs = transactions.where(
        (tx) =>
            tx.date.year == day.year &&
            tx.date.month == day.month &&
            tx.date.day == day.day,
      );
      return WeeklyTransactionData(
        label: labels[day.weekday - 1],
        income: dayTxs
            .where((tx) => tx.type == 'Credit')
            .fold(0.0, (s, tx) => s + tx.amount),
        expense: dayTxs
            .where((tx) => tx.type == 'Debit')
            .fold(0.0, (s, tx) => s + tx.amount),
      );
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final transactionAsync = ref.watch(transactionProvider);

    return transactionAsync.when(
      loading: () =>
          SkeletonBox(height: isDesktop ? 400 : 250, width: double.infinity),
      error: (err, _) =>
          const Center(child: Text("Failed to load activity")),
      data: (transactions) {
        final weeklyData = _buildWeeklyData(transactions);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Financial Activity", style: AppTextStyles.h3),
            AppSpacing.vSm,
            if (isDesktop)
              Row(
                children: [
                  Expanded(child: TransactionsBarChart(data: weeklyData)),
                ],
              )
            else
              TransactionsBarChart(data: weeklyData),
          ],
        );
      },
    );
  }
}

// ── 3. CHART WIDGET ──────────────────────────────────────────────────────────
class TransactionsBarChart extends StatelessWidget {
  final List<WeeklyTransactionData> data;
  final Color incomeColor;
  final Color expenseColor;
  final Color backgroundColor;

  const TransactionsBarChart({
    super.key,
    required this.data,
    this.incomeColor = const Color(0xFF00E5CC), // cyan
    this.expenseColor = const Color(0xFFFF4D7E), // pink/red
    this.backgroundColor = const Color(0xFF1B2A4A),
  });

  // Convert your data list to BarChartGroupData dynamically
  List<BarChartGroupData> _buildBarGroups() {
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      return BarChartGroupData(
        x: index,
        barsSpace: 4, // space between income and expense bar
        barRods: [
          // Income bar (cyan)
          BarChartRodData(
            toY: item.income,
            color: incomeColor,
            width: 6,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
          // Expense bar (pink)
          BarChartRodData(
            toY: item.expense,
            color: expenseColor,
            width: 6,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }

  // Calculate max Y value dynamically from your data
  double _getMaxY() {
    double max = 0;
    for (final item in data) {
      if (item.income > max) max = item.income;
      if (item.expense > max) max = item.expense;
    }
    return max * 1.2; // add 20% padding on top
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.bar_chart, color: Colors.white70, size: 20),
              AppSpacing.vSm,
              const Text(
                'Transactions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'this week',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Chart ─────────────────────────────────────────────────────────
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: _getMaxY(),
                minY: 0,
                barGroups: _buildBarGroups(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _getMaxY() / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withValues(alpha: 0.08),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  // ── Y axis (left) — shows 1K, 5K, 10K ──────────────────
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: _getMaxY() / 4,
                      getTitlesWidget: (value, meta) {
                        String label;
                        if (value >= 1000) {
                          label = '${(value / 1000).toStringAsFixed(0)}K';
                        } else {
                          label = value.toStringAsFixed(0);
                        }
                        return Text(
                          label,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),
                  // ── X axis (bottom) — shows Mn, Te, Wd etc ──────────────
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= data.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            data[index].label,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 11,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Hide top and right axes
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                // ── Tooltip on tap ─────────────────────────────────────────
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF0D1B35),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final isIncome = rodIndex == 0;
                      return BarTooltipItem(
                        '${isIncome ? '↑ Income' : '↓ Expense'}\n',
                        TextStyle(
                          color: isIncome ? incomeColor : expenseColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),

                        children: [
                          TextSpan(
                            text: '₦${rod.toY.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
