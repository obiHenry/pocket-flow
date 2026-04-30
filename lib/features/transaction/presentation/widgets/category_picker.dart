import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class CategoryPicker extends StatefulWidget {
  final ValueChanged<String> onChanged;
  // initialValue lets the edit form pre-select the existing category.
  final String initialValue;

  const CategoryPicker({
    super.key,
    required this.onChanged,
    this.initialValue = 'Shopping',
  });

  @override
  State<CategoryPicker> createState() => CategoryPickerState();
}

class CategoryPickerState extends State<CategoryPicker> {
  late int selectedIndex;
  final categories = [
    {'icon': Icons.shopping_cart, 'name': 'Shopping'},
    {'icon': Icons.restaurant, 'name': 'Food'},
    {'icon': Icons.directions_bus, 'name': 'Transport'},
    {'icon': Icons.receipt, 'name': 'Bills'},
  ];

  @override
  void initState() {
    super.initState();
    // Find the index of the pre-selected category, default to 0 if not found.
    final index = categories.indexWhere(
      (c) => c['name'] == widget.initialValue,
    );
    selectedIndex = index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Category",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, i) {
              final isSelected = selectedIndex == i;
              return GestureDetector(
                onTap: () {
                  setState(() => selectedIndex = i);
                  widget.onChanged(categories[i]['name'] as String);
                },
                child: Container(
                  width: 70,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        categories[i]['icon'] as IconData,
                        color: isSelected ? Colors.white : Colors.grey,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        categories[i]['name'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected ? Colors.white : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
