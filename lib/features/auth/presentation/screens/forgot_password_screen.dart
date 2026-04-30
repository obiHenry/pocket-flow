import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketflow/core/constants/app_spacing.dart';
import 'package:pocketflow/core/utils/app_validator.dart';
import 'package:pocketflow/core/utils/helper_functions.dart';
import '../../../../core/config/router/route_names.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';

class ForgotPasswordScreen extends ConsumerWidget {
  ForgotPasswordScreen({super.key});

  final TextEditingController emailController = TextEditingController();
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
      if (next.status == AuthStatus.initial) {
        HelperFunctions.showSnackBar(
          'If this email is registered, you will receive a reset link shortly.',
          context,
          isError: false,
        );
        context.go(RouteNames.login);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: padding,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Reset your password",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Enter your email and we’ll send you a reset link.",
                    ),

                    const SizedBox(height: 24),

                    AppTextField(
                      controller: emailController,
                      hint: "Email",
                      keyboardType: TextInputType.emailAddress,
                      validator: AppValidator.email,
                    ),

                    const SizedBox(height: 24),

                    AppButton(
                      text: "Send Reset Link",
                      isLoading: authState.status == AuthStatus.loading,
                      onPressed: authState.status == AuthStatus.loading
                          ? null
                          : () {
                              FocusScope.of(context).unfocus();
                              if (_formKey.currentState?.validate() ?? false) {
                                authNotifier.forgotPassword(
                                  emailController.text.trim(),
                                );
                              }
                            },
                    ),
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
