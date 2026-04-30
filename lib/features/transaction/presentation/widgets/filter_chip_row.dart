import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/transaction_provider.dart';

class FilterChipRow extends ConsumerStatefulWidget {
  const FilterChipRow({super.key});

  @override
  ConsumerState<FilterChipRow> createState() => _FilterChipRowState();
}

class _FilterChipRowState extends ConsumerState<FilterChipRow> {
  // Tracks which chip is currently selected — default is "All".
  int _selectedIndex = 0;

  final _filters = ["All", "Income", "Expense", "Shopping", "Bills"];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filters.length,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(_filters[i]),
            selected: _selectedIndex == i,
            onSelected: (_) {
              setState(() => _selectedIndex = i);
              // Tell the notifier to filter the master list by this chip's label.
              ref
                  .read(transactionProvider.notifier)
                  .filterTransactions(_filters[i]);
            },
            backgroundColor: Colors.white,
            selectedColor: AppColors.primary.withValues(alpha: 0.1),
            labelStyle: TextStyle(
              color: _selectedIndex == i ? AppColors.primary : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
