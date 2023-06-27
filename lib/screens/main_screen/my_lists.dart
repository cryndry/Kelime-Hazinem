import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/fab.dart';
import 'package:kelime_hazinem/components/list_card.dart';
import 'package:kelime_hazinem/components/list_card_grid.dart';
import 'package:kelime_hazinem/components/page_layout.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';

class MyLists extends StatelessWidget {
  const MyLists({super.key});
  // TODO: after dynamic implementation of this page, AutomaticKeepAliveClientMixin state will be added like other tabs,

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      FABs: [
        FAB(icon: MySvgs.cloud, onTap: (){}),
        const SizedBox(height: 12),
        FAB(icon: MySvgs.plus, onTap: (){}),
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
