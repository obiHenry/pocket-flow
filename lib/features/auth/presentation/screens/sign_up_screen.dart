import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketflow/core/utils/app_validator.dart';
import '../../../../core/config/router/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/helper_functions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/social_button.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';

class SignUpScreen extends ConsumerWidget {
  SignUpScreen({super.key});

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final padding = AppSpacing.getHorizontalPadding(context);
    final maxWidth = AppSpacing.getMaxWidth(context);

    final authState = ref.watch(authNotifierProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);

    ref.listen(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        HelperFunctions.showSnackBar(
          next.errorMessage!,
          context,
          isError: true,
        );
      }
      if (next.status == AuthStatus.authenticated) {
        if (next.errorMessage != null) {
          HelperFunctions.showSnackBar(next.errorMessage!, context, isError: true);
        } else {
          HelperFunctions.showSnackBar('Success', context, isError: false);
        }
        context.go(RouteNames.home);
      }
    });
    final isLoading = authState.status == AuthStatus.loading;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacing.vXl,
                  Text("Create Account", style: AppTextStyles.h1),
                  AppSpacing.vLg,

                  AppTextField(
                    hint: "Full Name",
                    controller: nameController,
                    validator: AppValidator.name,
                  ),

                  AppSpacing.vMd,

                  AppTextField(
                    hint: "Email",
                    controller: emailController,
                    validator: AppValidator.email,
                  ),

                  AppSpacing.vMd,

                  AppTextField(
                    hint: "Password",
                    controller: passwordController,
                    obscureText: true,
                    validator: AppValidator.password,
                  ),

                  AppSpacing.vLg,

                  AppButton(
                    text: "Sign Up",
                    isLoading:
                        isLoading &&
                        authState.loadingAction == AuthLoadingAction.signUp,
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      if (_formKey.currentState?.validate() ?? false) {
                        authNotifier.signUp(
                          name: nameController.text.trim(),
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                        );
                      }
                    },
                  ),

                  AppSpacing.vLg,

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already registered? ",
                        style: AppTextStyles.bodySmall,
                      ),
                      GestureDetector(
                        onTap: () {
                          context.pushNamed(
                            RouteNames.login,
                          ); // or your route name
                        },
                        child: Text(
                          "Sign In",
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  AppSpacing.vLg,

                  const Center(child: Text("OR")),

                  AppSpacing.vMd,

                  SocialButton.google(
                    isLoading:
                        isLoading &&
                        authState.loadingAction == AuthLoadingAction.google,
                    () {
                      authNotifier.signInWithGoogle();
                    },
                  ),

                  if (kIsWeb || (!kIsWeb && Platform.isIOS)) ...[
                    AppSpacing.vMd,
                    SocialButton.apple(
                      isLoading:
                          isLoading &&
                          authState.loadingAction == AuthLoadingAction.apple,
                      () => authNotifier.signInWithApple(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
