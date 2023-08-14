import 'package:flutter/material.dart';

class NonScrollablePageLayout extends StatelessWidget {
  const NonScrollablePageLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        )
      ],
    );
  }
}
