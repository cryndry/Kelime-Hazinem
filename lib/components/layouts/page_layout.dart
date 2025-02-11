import 'package:flutter/material.dart';

class PageLayout extends StatelessWidget {
  const PageLayout({super.key, required this.children, this.FABs});

  final List<Widget> children;
  final List<Widget>? FABs;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ),
        if (FABs != null)
          Positioned(
            bottom: 48,
            right: 16,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                children: FABs!,
              ),
            ),
          ),
      ],
    );
  }
}
