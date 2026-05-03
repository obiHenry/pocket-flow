import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/connectivity_notifier.dart';

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    final showBanner = isOnline.when(
      data: (online) => !online,
      loading: () => false,
      error: (_, __) => false,
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) =>
          SizeTransition(sizeFactor: animation, child: child),
      child: showBanner
          ? Container(
              key: const ValueKey('offline'),
              width: double.infinity,
              color: Colors.orange.shade800,
              padding:
                  const EdgeInsets.symmetric(vertical: 7, horizontal: 16),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off_rounded, color: Colors.white, size: 15),
                  SizedBox(width: 8),
                  Text(
                    "You're offline — showing cached data",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(key: ValueKey('online')),
    );
  }
}
