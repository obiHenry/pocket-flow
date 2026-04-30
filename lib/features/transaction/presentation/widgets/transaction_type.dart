import 'package:flutter/material.dart';

class TransactionTypeSelector extends StatefulWidget {
  final ValueChanged<String> onChanged;
  // initialValue lets the edit form pre-select the existing type.
  final String initialValue;
  const TransactionTypeSelector({
    super.key,
    required this.onChanged,
    this.initialValue = 'Expense',
  });
  @override
  State<TransactionTypeSelector> createState() =>
      TransactionTypeSelectorState();
}

class TransactionTypeSelectorState extends State<TransactionTypeSelector> {
  late String selectedType;

  @override
  void initState() {
    super.initState();
    selectedType = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildToggleItem("Expense", Colors.red),
          _buildToggleItem("Income", Colors.green),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, Color activeColor) {
    final bool isSelected = selectedType == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => selectedType = label);
          widget.onChanged(label); // Pass value to parent
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? activeColor : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
