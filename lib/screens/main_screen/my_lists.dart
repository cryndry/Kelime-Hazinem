import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/fab.dart';
import 'package:kelime_hazinem/components/list_card.dart';
import 'package:kelime_hazinem/components/list_card_grid.dart';
import 'package:kelime_hazinem/components/page_layout.dart';

class MyLists extends StatelessWidget {
  const MyLists({super.key});

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      FABs: [
        FAB(iconPath: "assets/Cloud.svg", onTap: (){}),
        const SizedBox(height: 12),
        FAB(iconPath: "assets/Plus.svg", onTap: (){}),
      ],
      children: [
        ListCardGrid(
          children: [
            ListCard(title: "Seviye 1"),
            ListCard(title: "Seviye 2"),
            ListCard(title: "Seviye 3"),
            ListCard(title: "Seviye 4"),
            ListCard(title: "Seviye 5"),
            ListCard(title: "Seviye 6"),
          ],
        ),
      ],
    );
  }
}
