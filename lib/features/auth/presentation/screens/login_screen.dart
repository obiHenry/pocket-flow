import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketflow/core/config/router/route_names.dart';
import 'package:pocketflow/core/utils/app_validator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/helper_functions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/social_button.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';

class SignInScreen extends ConsumerWidget {
  SignInScreen({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, ref) {
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
        HelperFunctions.showSnackBar('Login success!', context, isError: false);
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

            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSpacing.vXl,
                    Text("Welcome Back", style: AppTextStyles.h1),
                    AppSpacing.vLg,

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
                      text: "Sign In",
                      isLoading:
                          isLoading &&
                          authState.loadingAction == AuthLoadingAction.login,
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        if (_formKey.currentState?.validate() ?? false) {
                          authNotifier.login(
                            emailController.text.trim(),
                            passwordController.text.trim(),
                          );
                        }
                      },
                    ),
                    AppSpacing.vSm,

                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          context.push(
                            RouteNames.forgotPassword,
                          ); // or your route name
                        },
                        child: Text(
                          "Forgot Your Password?",
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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
                    AppSpacing.vLg,

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Not registered? ",
                          style: AppTextStyles.bodySmall,
                        ),
                        GestureDetector(
                          onTap: () {
                            context.push(
                              RouteNames.signUp,
                            ); // or your route name
                          },
                          child: Text(
                            "Get started",
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    AppSpacing.vXl,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
