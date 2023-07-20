import 'package:flutter/material.dart';

class MyNavigatorObserver extends NavigatorObserver {
  static final stack = [];

  @override
  void didPop(Route route, Route? previousRoute) {
    stack.removeAt(0);

    super.didPop(route, previousRoute);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    stack.insert(0, route.settings.name);

    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    stack.first = newRoute!.settings.name;

    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}
