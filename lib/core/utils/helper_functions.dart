import 'package:flutter/material.dart';
import 'package:pocketflow/core/utils/responsive_helper.dart';
import 'package:pocketflow/shared/modal/bottom_sheet_custom_widget.dart';

import '../../shared/modal/custom_modal.dart';
import '../constants/app_colors.dart';

class HelperFunctions {
  HelperFunctions._();

  static double getMaxWidth(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) {
      return MediaQuery.of(context).size.width * 0.8; // ← fixed width, no .sp
    }
    if (ResponsiveHelper.isTablet(context)) {
      return MediaQuery.of(context).size.width * 0.68;
    }
    // ← fixed width, no .sp
    return 20;
  }

  static void showSnackBar(String message, context, {bool isError = false}) {
    final maxWidth = getMaxWidth(context);

    // Get the overlay state
    final overlay = Overlay.of(context);

    // Create the entry
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10, // Always at the top notch
        left: maxWidth,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isError ? const Color(0xFFC64132) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
              border: isError
                  ? null
                  : Border.all(color: Colors.green.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isError ? Icons.help_outline : Icons.check_circle_outline,
                    color: isError ? Colors.white : Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isError ? 'Exception' : 'Success',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isError ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        message,
                        style: TextStyle(
                          color: isError
                              ? Colors.white.withValues(alpha: 0.9)
                              : Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => overlayEntry.remove(),
                  child: Icon(
                    Icons.close,
                    color: isError ? Colors.white : Colors.black54,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Insert into the screen
    overlay.insert(overlayEntry);

    // Auto-remove after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  static Future<T?> showCustomBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
    Color backgroundColor = Colors.transparent,
    double? heightFactor, // Optional: if you want a fixed height fraction
    bool enableDrag = true, // Allows dragging to close
    bool isDismissible = true, // Allows tapping outside to close
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: backgroundColor,
      enableDrag: enableDrag,
      isDismissible: isDismissible,

      builder: (BuildContext context) {
        if (heightFactor != null) {
          return FractionallySizedBox(
            heightFactor: heightFactor,
            child: BottomSheetCustomWidget(child: child),
          );
        } else {
          // If no heightFactor, the child determines its own height
          // It's good practice for the child's root widget (e.g., Container or Column)
          // to have mainAxisSize: MainAxisSize.min to prevent it from taking full height.
          return BottomSheetCustomWidget(child: child);
        }
      },
    );
  }

  static showModal({
    required BuildContext context,
    String message = "",
    bool show = true,
    bool barrierDismissible = true,
    bool autoDismiss = false,
    required Widget widget,
    bool? inPadding,
    bool? showExitButton,
    Color? borderColor,
    double? insetPaddingWidth,
    double? insetPaddingHeight,

    Future<bool>? then,
    Color? backgroundColor,
  }) {
    if (show) {
      showDialog(
        context: context,
        barrierDismissible: barrierDismissible,

        builder: (BuildContext context) {
          return CustomModal(
            insetPaddingHeight: insetPaddingHeight,
            insetPaddingWidth: insetPaddingWidth,
            inPadding: inPadding,
            showExitButton: showExitButton,
            borderColor: borderColor,
            backgroundColor: backgroundColor,
            widget: widget,
          );
        },
      );
    } else {
      Navigator.pop(context);
    }
  }
}
