import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/responsive_helper.dart';

class AppSpacing {
  AppSpacing._();

  // Base spacing scale (8px system)
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // Vertical spaces
  static SizedBox vXs = SizedBox(height: xs.h);
  static SizedBox vSm = SizedBox(height: sm.h);
  static SizedBox vMd = SizedBox(height: md);
  static SizedBox vLg = SizedBox(height: lg);
  static SizedBox vXl = SizedBox(height: xl);
  static SizedBox vXxl = SizedBox(height: xxl);

  // Horizontal spaces
  static SizedBox hXs = SizedBox(width: xs.w);
  static SizedBox hSm = SizedBox(width: sm.w);
  static SizedBox hMd = SizedBox(width: md.w);
  static SizedBox hLg = SizedBox(width: lg.w);
  static SizedBox hXl = SizedBox(width: xl.w);

  // Page / Layout Padding
  static EdgeInsets page = EdgeInsets.all(md.sp);
  static EdgeInsets horizontal(md) => EdgeInsets.symmetric(horizontal: md);
  static EdgeInsets vertical(md) => EdgeInsets.symmetric(vertical: md);

  // Card Padding
  static EdgeInsets card = EdgeInsets.all(md.sp);

  // Button Padding
  static EdgeInsets button = EdgeInsets.symmetric(
    horizontal: lg.w,
    vertical: sm.h,
  );

  static EdgeInsets getHorizontalPadding(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) {
      return const EdgeInsets.symmetric(
        horizontal: 24,
      ); // ← only horizontal, no vertical
    }
    if (ResponsiveHelper.isTablet(context)) {
      return EdgeInsets.symmetric(horizontal: 80.w); // ← only horizontal
    }
    return EdgeInsets.symmetric(horizontal: 24.w); // ← only horizontal
  }

  static double getMaxWidth(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) {
      return 520; // ← fixed width, no .sp
    }
    if (ResponsiveHelper.isTablet(context)) return 500; // ← fixed width, no .sp
    return double.infinity;
  }
}
