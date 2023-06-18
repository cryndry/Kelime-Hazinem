import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:kelime_hazinem/components/icon.dart';
import 'package:kelime_hazinem/components/list_card.dart';

class ListCardGrid extends StatefulWidget {
  const ListCardGrid({super.key});

  @override
  State<ListCardGrid> createState() => _ListCardGridState();
}

class _ListCardGridState extends State<ListCardGrid> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: LayoutGrid(
        columnSizes: repeat(3, [1.fr]),
        rowSizes: repeat((7 ~/ 3) + 1, [auto]),
        rowGap: 20,
        children: [
          ListCard(title: "Temel Seviye"),
          ListCard(title: "Orta Seviye"),
          ListCard(title: "İleri Seviye"),
          ListCard(
              title: "Öğreneceklerim",
              color: const Color(0xFFB3261E),
              icon: const ActionButton(
                path: "assets/Will Learn.svg",
                fillColor: Color(0xFFB3261E),
                strokeColor: Color(0xFFFFFFFF),
                size: 32,
              )),
          ListCard(
              title: "Favorilerim",
              color: const Color(0xFFFFD000),
              icon: const ActionButton(
                path: "assets/Favorites.svg",
                fillColor: Color(0xFFFFD000),
                strokeColor: Color(0xFFFFFFFF),
                size: 32,
              )),
          ListCard(
              title: "Öğrendiklerim",
              color: const Color(0xFF70E000),
              icon: const ActionButton(
                path: "assets/Learned.svg",
                fillColor: Color(0xFF70E000),
                strokeColor: Color(0xFFFFFFFF),
                size: 32,
              )),
          ListCard(
              title: "Hazinem",
              color: const Color(0xFF008000),
              icon: const ActionButton(
                path: "assets/Memorized.svg",
                fillColor: Color(0xFF008000),
                strokeColor: Color(0xFFFFFFFF),
                size: 32,
              )),
        ],
      ),
    );
  }
}
