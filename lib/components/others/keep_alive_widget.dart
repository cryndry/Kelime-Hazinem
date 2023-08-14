import 'package:flutter/material.dart';

class KeepAliveWidget extends StatefulWidget {
  const KeepAliveWidget({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  KeepAliveWidgetState createState() => KeepAliveWidgetState();
}

class KeepAliveWidgetState extends State<KeepAliveWidget> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return widget.child;
  }
}
