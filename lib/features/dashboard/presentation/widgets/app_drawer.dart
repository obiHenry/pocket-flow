import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketflow/core/constants/app_spacing.dart';
import 'package:pocketflow/features/dashboard/presentation/widgets/drawer_tile.dart';

import '../../../../core/config/router/route_names.dart';
import '../../../../core/utils/helper_functions.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../../profile/presentation/widgets/user_profile_header.dart';
import '../providers/dashbaord_provider.dart';

class AppDrawer extends ConsumerWidget {
  final bool isPermanent;
  const AppDrawer({super.key, this.isPermanent = false});

  Future<void> _onLogoutTap(BuildContext context, WidgetRef ref) async {
    final state = ref.read(authNotifierProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          state.status == AuthStatus.loading &&
                  state.loadingAction == AuthLoadingAction.logout
              ? CircularProgressIndicator()
              : TextButton(
                  onPressed: () async {
                    await ref.read(authNotifierProvider.notifier).logout();

                    if (!context.mounted) return;

                    if (state.errorMessage != null) {
                      HelperFunctions.showSnackBar(
                        state.errorMessage!,
                        context,
                        isError: true,
                      );
                    } else {
                      Navigator.of(ctx).pop(true);
                      context.pushReplacement(RouteNames.login);
                      HelperFunctions.showSnackBar(
                        'Logged out successfully',
                        context,
                        isError: false,
                      );
                    }
                  },
                  child: const Text('Logout'),
                ),
        ],
      ),
    );

    // if (confirmed == true) {}
  }

  void _onTap(BuildContext context, WidgetRef ref, int index, String route) {
    ref.read(navigationIndexProvider.notifier).state = index;
    context.go(route);
    if (!isPermanent) Navigator.pop(context); // Close drawer on mobile
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationIndexProvider);
    return Drawer(
      elevation: 0,
      child: Column(
        children: [
          const UserProfileHeader(),

          AppSpacing.vMd,
          DrawerTile(
            icon: Icons.account_balance_wallet,
            label: "Dashboard",
            isSelected: selectedIndex == 0,
            onTap: () => _onTap(context, ref, 0, RouteNames.home),
          ),

          DrawerTile(
            icon: Icons.wallet,
            label: "Wallet",
            isSelected: selectedIndex == 1,
            onTap: () => _onTap(context, ref, 1, RouteNames.wallet),
          ),

          DrawerTile(
            icon: Icons.history,
            label: "Transactions",
            isSelected: selectedIndex == 2,
            onTap: () => _onTap(context, ref, 2, RouteNames.transaction),
          ),

          DrawerTile(
            icon: Icons.person,
            label: "Profile",
            isSelected: selectedIndex == 3,
            onTap: () => _onTap(context, ref, 3, RouteNames.profile),
          ),

          const Spacer(),
          DrawerTile(
            icon: Icons.logout,
            label: "Logout",
            isSelected: selectedIndex == 4,
            onTap: () => _onLogoutTap(context, ref),
          ),
          AppSpacing.vLg,
        ],
      ),
    );
  }
}
