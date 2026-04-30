import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketflow/shared/widgets/app_scaffold.dart';

import '../../../../core/animations/animation_helper.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../providers/user_provider.dart';
import '../widgets/profile_hero.dart';
import '../widgets/profile_loading_skeleton.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider); // Your Auth/User Notifier
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return AppScaffold(
      body: userAsync.when(
        loading: () => const ProfileLoadingSkeleton(),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (user) => Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 900 : double.infinity,
            ),
            child: CustomScrollView(
              slivers: [
                // 1. The Hero Header (Profile Info)
                SliverToBoxAdapter(
                  child: AnimationHelper.fadeInSlide(
                    child: ProfileHero(user: user!),
                  ),
                ),

                // 2. The Settings Sections
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: isDesktop
                      ? _buildDesktopGrid() // Desktop: 2-column grid
                      : _buildMobileList(), // Mobile: 1-column list
                ),

                // Footer
                const SliverToBoxAdapter(child: SizedBox(height: 50)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileList() {
    return SliverList(
      delegate: SliverChildListDelegate([
        SettingsSection(
          title: "Account",
          items: [
            SettingsTile(
              icon: Icons.lock_outline,
              title: "Change Password",
              onTap: () {},
            ),
            SettingsTile(
              icon: Icons.payments_outlined,
              title: "Primary Currency",
              trailing: Text(
                "USD",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        AppSpacing.vMd,
        SettingsSection(
          title: "Preferences",
          items: [
            SettingsTile(
              icon: Icons.dark_mode_outlined,
              title: "Dark Mode",
              trailing: Switch.adaptive(value: false, onChanged: (v) {}),
            ),
            SettingsTile(
              icon: Icons.notifications_none,
              title: "Alerts & Notifications",
              onTap: () {},
            ),
          ],
        ),
        AppSpacing.vMd,
        SettingsSection(
          title: "Data",
          items: [
            SettingsTile(
              icon: Icons.file_download_outlined,
              title: "Export Statement (CSV)",
              onTap: () {},
            ),
            SettingsTile(
              icon: Icons.delete_outline,
              title: "Delete Account",
              iconColor: Colors.red,
              onTap: () {},
            ),
          ],
        ),
      ]),
    );
  }

  Widget _buildDesktopGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 220,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      delegate: SliverChildListDelegate([
        SettingsSection(
          title: "Security & Access",
          items: [
            SettingsTile(
              icon: Icons.lock_outline,
              title: "Change Password",
              onTap: () {},
            ),
            SettingsTile(
              icon: Icons.payments_outlined,
              title: "Primary Currency",
              trailing: Text(
                "USD",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        SettingsSection(
          title: "App Customization",
          items: [
            SettingsTile(
              icon: Icons.dark_mode_outlined,
              title: "Dark Mode",
              trailing: Switch.adaptive(value: false, onChanged: (v) {}),
            ),
            SettingsTile(
              icon: Icons.notifications_none,
              title: "Alerts & Notifications",
              onTap: () {},
            ),
          ],
        ),
        SettingsSection(
          title: "Account Management",
          items: [
            SettingsTile(
              icon: Icons.file_download_outlined,
              title: "Export Statement (CSV)",
              onTap: () {},
            ),
            SettingsTile(
              icon: Icons.delete_outline,
              title: "Delete Account",
              iconColor: Colors.red,
              onTap: () {},
            ),
          ],
        ),
      ]),
    );
  }
}
