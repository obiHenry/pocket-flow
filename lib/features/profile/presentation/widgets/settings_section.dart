import 'package:flutter/material.dart';

import '../../../../core/constants/app_text_styles.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const SettingsSection({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            // color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }
}
