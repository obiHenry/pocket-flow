import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketflow/core/config/router/route_names.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../main.dart';
import '../../../../shared/widgets/app_button.dart' show AppButton;

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController controller = PageController();
  int currentIndex = 0;

  final pages = [
    {
      "image": Icons.savings,
      "title": "Track Your Money",
      "desc": "Monitor your income and expenses in real time",
    },
    {
      "image": Icons.analytics,
      "title": "Smart Insights",
      "desc": "Understand your spending habits with analytics",
    },
    {
      "image": Icons.security,
      "title": "Secure & Reliable",
      "desc": "Your financial data is safe and encrypted",
    },
  ];

  void nextPage() async {
    if (currentIndex < pages.length - 1) {
      controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      final localService = ref.read(localStorageProvider);
      await localService.saveOnboardingStatus();

      context.push(RouteNames.signUp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppSpacing.getHorizontalPadding(context);
    final maxWidth = AppSpacing.getMaxWidth(context);
    return Scaffold(
      // backgroundColor: AppColors.backgroundLight,
      // Wrap the body in a Center to handle Web/Desktop wide screens
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: padding,
            child: Column(
              children: [
                AppSpacing.vXxl,
                Expanded(
                  child: PageView.builder(
                    controller: controller,
                    itemCount: pages.length,
                    onPageChanged: (i) => setState(() => currentIndex = i),
                    itemBuilder: (_, index) {
                      final page = pages[index];
                      // Wrap the inner content in a SingleChildScrollView
                      // to prevent vertical overflow on small mobile screens
                      return SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              page["image"] as IconData,
                              size: 120,
                              color: AppColors.primary,
                            ),
                            AppSpacing.vLg,
                            Text(
                              page["title"] as String,
                              style: AppTextStyles.bodyLarge,
                            ),
                            AppSpacing.vMd,
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Text(
                                page["desc"] as String,
                                style: AppTextStyles.bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    pages.length,
                    (index) => Container(
                      margin: const EdgeInsets.all(4),
                      width: currentIndex == index ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: currentIndex == index
                            ? Colors.blue
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
                AppSpacing.vMd,

                // ... (Progress Indicators)
                AppButton(
                  text: currentIndex == pages.length - 1
                      ? "Get Started"
                      : "Next",
                  onPressed: nextPage,
                ),

                AppSpacing.vLg,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
