import 'package:flutter/material.dart';
import 'package:kelime_hazinem/utils/database.dart';

PageRouteBuilder<T> routeAnimator<T>({required Widget page, Offset? beginOffset}) {
  final Duration animationDuration = KeyValueDatabase.getIsAnimatable() ? const Duration(milliseconds: 300) : Duration.zero;
  
  return PageRouteBuilder<T>(
    settings: RouteSettings(name: page.toString()),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: animationDuration,
    reverseTransitionDuration: animationDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      Animatable<Offset> tween = Tween(
        begin: beginOffset ?? const Offset(1, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.fastEaseInToSlowEaseOut));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
