import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

class ListCardGrid extends StatelessWidget {
  const ListCardGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final gridWidth = (screenWidth > 400) ? screenWidth - 80 : screenWidth - 56;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: (screenWidth > 400) ? 24 : 12),
      child: LayoutGrid(
        columnSizes: repeat(3, [1.fr]),
        rowSizes: repeat((children.length ~/ 3) + 1, [auto]),
        rowGap: 20,
        columnGap: (gridWidth < 300)
            ? 12
            : (gridWidth > 348)
                ? (gridWidth - 300) / 2
                : 24,
        children: children,
      ),
    );
  }
}
