import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  static bool isInLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;
}

Size getSizeForDevice(BuildContext context) {
  if (ResponsiveHelper.isMobile(context)) {
    return ResponsiveHelper.isInLandscape(context)
        ? const Size(812, 375) // Mobile Landscape (width, height swapped)
        : const Size(375, 812); // Mobile Portrait
  } else if (ResponsiveHelper.isTablet(context)) {
    return ResponsiveHelper.isInLandscape(context)
        ? const Size(1112, 834) // Tablet Landscape (width, height swapped)
        : const Size(834, 1112); // Tablet Portrait
  } else {
    return const Size(1440, 1024); // Desktop (usually landscape)
  }
}
