import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelime_hazinem/main.dart';

abstract class StateWithRefreshOnPopNext<T extends StatefulWidget> extends State<T> with RouteAware {
  Function onPopNextCallback = () {};
  void setOnPopNextCallback(Function callback) {
    setState(() {
      onPopNextCallback = callback;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      routeObserver.subscribe(this, ModalRoute.of(context)!);
    });
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      routeObserver.unsubscribe(this);
    });
    super.dispose();
  }

  @override
  void didPopNext() {
    setState(() {
      onPopNextCallback();
    });
  }
}

abstract class ConsumerStateWithRefreshOnPopNext<T extends ConsumerStatefulWidget> extends ConsumerState<T>
    with RouteAware {
  Function onPopNextCallback = () {};
  void setOnPopNextCallback(Function callback) => onPopNextCallback = callback;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      routeObserver.subscribe(this, ModalRoute.of(context)!);
    });
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      routeObserver.unsubscribe(this);
    });
    super.dispose();
  }

  @override
  void didPopNext() {
    setState(() {
      onPopNextCallback();
    });
  }
}
