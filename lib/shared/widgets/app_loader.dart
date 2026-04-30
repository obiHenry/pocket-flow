import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AppLoader extends StatelessWidget {
  final String? message;

  const AppLoader({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          if (message != null) ...[const SizedBox(height: 12), Text(message!)],
        ],
      ),
    );
  }
}
