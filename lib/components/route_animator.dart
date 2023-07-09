import 'package:flutter/material.dart';

PageRouteBuilder<T> routeAnimator<T>({required Widget page, Offset? beginOffset}) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      Animatable<Offset> tween = Tween(
        begin: beginOffset ?? const Offset(1, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.ease));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
