import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AnimationHelper {
  /// Fade transition
  static CustomTransitionPage fade({
    required GoRouterState state,
    required Widget child,
    int durationMs = 300,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: Duration(milliseconds: durationMs),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  /// Slide from right
  static Widget fadeInSlide({required Widget child, int delay = 0}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Scale + Fade (nice for dialogs / auth)
  static CustomTransitionPage scale({
    required GoRouterState state,
    required Widget child,
    int durationMs = 300,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: Duration(milliseconds: durationMs),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }
}
