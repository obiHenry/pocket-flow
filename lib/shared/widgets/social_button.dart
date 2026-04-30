import 'package:flutter/material.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_text_styles.dart';

class SocialButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isLoading; // ← add this

  const SocialButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.isLoading = false, // ← default false
  });

  factory SocialButton.google(
    VoidCallback onPressed, {
    bool isLoading = false,
  }) {
    return SocialButton(
      text: "Continue with Google",
      icon: Icons.g_mobiledata,
      onPressed: onPressed,
      isLoading: isLoading,
    );
  }

  factory SocialButton.apple(VoidCallback onPressed, {bool isLoading = false}) {
    return SocialButton(
      text: "Continue with Apple",
      icon: Icons.apple,
      onPressed: onPressed,
      isLoading: isLoading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.buttonHeightMd,
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon),
        label: Text(
          isLoading ? "Please wait..." : text,
          style: AppTextStyles.button,
        ),
        onPressed: isLoading ? null : onPressed, // ← disable while loading
      ),
    );
  }
}
