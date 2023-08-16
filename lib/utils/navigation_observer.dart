import 'package:flutter/material.dart';
import 'package:kelime_hazinem/utils/analytics.dart';

class MyNavigatorObserver extends NavigatorObserver {
  static final stack = <String?>[];

  @override
  void didPop(Route route, Route? previousRoute) {
    stack.removeAt(0);

    super.didPop(route, previousRoute);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    final routeName = route.settings.name;
    stack.insert(0, routeName);
    if (routeName != null) {
      Analytics.logRouteChange(routeName);
    }

    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    final routeName = newRoute!.settings.name;
    stack.first = routeName;
    if (routeName != null) {
      Analytics.logRouteChange(routeName);
    }

    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}
