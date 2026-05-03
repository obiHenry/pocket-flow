import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/responsive_helper.dart';
import '../../../../shared/widgets/offline_banner.dart';
import '../widgets/app_drawer.dart';

class DashboardPage extends ConsumerWidget {
  final Widget child;
  const DashboardPage({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    final bool isTablet = ResponsiveHelper.isTablet(context);
    final bool showPermanentSidebar = isDesktop || isTablet;

    return Scaffold(
      // backgroundColor: AppColors.backgroundLight,
      // 1. Only attach the drawer to the Scaffold if we are on Mobile
      drawer: !showPermanentSidebar ? const AppDrawer() : null,

      appBar: !showPermanentSidebar
          ? AppBar(title: const Text("PocketFlow"))
          : null,

      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: Row(
              children: [
                // 2. If Desktop/Tablet, the Sidebar is a permanent part of the Row
                if (showPermanentSidebar)
                  const SizedBox(width: 280, child: AppDrawer(isPermanent: true)),

                // 3. The Main Content (Wallet Core)
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
