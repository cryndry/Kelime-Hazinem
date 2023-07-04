import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

class ListCardGrid extends StatelessWidget {
  const ListCardGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: LayoutGrid(
        columnSizes: repeat(3, [1.fr]),
        rowSizes: repeat((children.length ~/ 3) + 1, [auto]),
        rowGap: 20,
        columnGap: 12,
        children: children,
      ),
    );
  }
}
