import 'package:flutter/material.dart';

class AppSizes {
  AppSizes._();

  // =====================
  // Border Radius
  // =====================
  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;

  static const BorderRadius c = BorderRadius.all(Radius.circular(radiusXs));
  static const BorderRadius brSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius brMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius brLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius brXl = BorderRadius.all(Radius.circular(radiusXl));

  // =====================
  // Icon Sizes
  // =====================
  static const double iconXs = 16;
  static const double iconSm = 20;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 40;

  // =====================
  // Button Sizes
  // =====================
  static const double buttonHeightSm = 40;
  static const double buttonHeightMd = 48;
  static const double buttonHeightLg = 56;

  // =====================
  // Input Field Sizes
  // =====================
  static const double inputHeight = 56;

  // =====================
  // Avatar Sizes
  // =====================
  static const double avatarSm = 32;
  static const double avatarMd = 48;
  static const double avatarLg = 72;

  // =====================
  // AppBar
  // =====================
  static const double appBarHeight = kToolbarHeight;
}
