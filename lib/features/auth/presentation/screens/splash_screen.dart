import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketflow/core/config/router/route_names.dart';
import 'package:pocketflow/main.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/local_storage/local_storage_services.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fade = Tween(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _bootstrap();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    try {
      print('🚀 bootstrap started');

      final authNotifier = ref.read(authNotifierProvider.notifier);
      final localService = ref.read(localStorageProvider);

      print('⏳ checking session...');
      await authNotifier.checkSession();
      print('✅ session checked');

      final status = ref.read(authNotifierProvider).status;
      print('📌 auth status: $status');

      final hasSeenOnboarding = await localService.getOnboardingStatus();
      print('📌 hasSeenOnboarding: $hasSeenOnboarding');

      if (!mounted) {
        return;
      }

      if (!hasSeenOnboarding) {
        context.go(RouteNames.onboarding);
      } else if (status == AuthStatus.authenticated) {
        context.go(RouteNames.home);
      } else {
        context.go(RouteNames.login);
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print('💥 bootstrap error: $e');
      }
      if (kDebugMode) {
        print(stack);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: FadeTransition(
        opacity: _fade,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_balance, size: 80, color: Colors.white),

              AppSpacing.vLg,
              Text(
                "PocketFlow",
                style: AppTextStyles.h1.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
