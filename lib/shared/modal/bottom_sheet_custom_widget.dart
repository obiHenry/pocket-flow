import 'package:flutter/material.dart';

class BottomSheetCustomWidget extends StatelessWidget {
  final Widget child;

  const BottomSheetCustomWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: child,
    );
  }
}
