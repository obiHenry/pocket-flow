import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_colors.dart';

class CustomModal extends StatelessWidget {
  final double? insetPaddingHeight;
  final double? insetPaddingWidth;
  final Widget widget;
  final bool? showExitButton;
  final bool? inPadding;
  final Color? borderColor;
  final Color? backgroundColor;
  final String? icon;

  const CustomModal({
    super.key,
    required this.insetPaddingHeight,
    this.insetPaddingWidth,
    required this.widget,
    this.showExitButton,
    this.inPadding,
    this.borderColor,
    this.backgroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),

          // backgroundColor: backgroundColor ?? AppColors.backgroundColor,
          // insetPadding: EdgeInsets.symmetric(
          //   horizontal: insetPaddingWidth.w,
          //   vertical: insetPaddingHeight.h,
          // ),
          child: Wrap(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  // color: backgroundColor ?? AppColors.backgroundColor,
                  border: Border.all(
                    color: borderColor == null
                        ? AppColors.surfaceLight
                        : borderColor!,
                    width: 0.5.w,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(insetPaddingHeight ?? 8.sp),
                  child: widget,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
