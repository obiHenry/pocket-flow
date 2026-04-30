// lib/utils/app_validator.dart

class AppValidator {
  // ── EMAIL ──────────────────────────────────────────────────────────────────
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email cannot be empty';
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  // ── PASSWORD ───────────────────────────────────────────────────────────────
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password cannot be empty';
    if (value.length < 8) return 'Password must be at least 8 characters long';
    return null;
  }

  // ── STRONG PASSWORD ────────────────────────────────────────────────────────
  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password cannot be empty';
    if (value.length < 8) return 'Password must be at least 8 characters long';
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Must contain at least one number';
    }
    if (!value.contains(RegExp(r'[!@#\$&*~%^()_\-+=]'))) {
      return 'Must contain at least one special character';
    }
    return null;
  }

  // ── CONFIRM PASSWORD ───────────────────────────────────────────────────────
  static String? Function(String?) confirmPassword(String? original) {
    return (String? value) {
      if (value == null || value.isEmpty) return 'Please confirm your password';
      if (value != original) return 'Passwords do not match';
      return null;
    };
  }

  // ── TEXT (generic required field) ──────────────────────────────────────────
  static String? text(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName cannot be empty';
    }
    return null;
  }

  // ── NAME ───────────────────────────────────────────────────────────────────
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name cannot be empty';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    if (value.contains(RegExp(r'[0-9]'))) return 'Name cannot contain numbers';
    return null;
  }

  // ── PHONE ──────────────────────────────────────────────────────────────────
  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number cannot be empty';
    final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  // ── OPTIONAL (allow empty but validate format if filled) ───────────────────
  static String? Function(String?) optional(
    String? Function(String?) validator,
  ) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) return null;
      return validator(value);
    };
  }
}
