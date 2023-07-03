import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/fab.dart';
import 'package:kelime_hazinem/components/list_card.dart';
import 'package:kelime_hazinem/components/list_card_grid.dart';
import 'package:kelime_hazinem/components/page_layout.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';

class MyLists extends StatefulWidget {
  const MyLists({super.key});

  @override
  State<MyLists> createState() => _MyListsState();
}

class _MyListsState extends State<MyLists> {
  List<String> lists = [];

  @override
  void initState() {
    // TODO: implement get and show added lists
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      FABs: [
        FAB(icon: MySvgs.cloud, onTap: () {}),
        const SizedBox(height: 12),
        FAB(icon: MySvgs.plus, onTap: () {}),
      ],
      children: [
        ListCardGrid(
          children: lists.map<ListCard>((e) => ListCard(title: e)).toList(),
        ),
      ],
    );
  }
}
