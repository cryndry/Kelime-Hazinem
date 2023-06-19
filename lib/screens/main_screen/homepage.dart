import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/icon.dart';
import 'package:kelime_hazinem/components/list_card.dart';
import 'package:kelime_hazinem/components/list_card_grid.dart';
import 'package:kelime_hazinem/components/page_layout.dart';
import 'package:kelime_hazinem/components/word_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return PageLayout(
      children: [
        const WordCard(isRandomWordCard: true),
        const SizedBox(height: 12),
        ListCardGrid(
          children: [
            ListCard(title: "Temel Seviye"),
            ListCard(title: "Orta Seviye"),
            ListCard(title: "İleri Seviye"),
            ListCard(
                title: "Öğrenecek\u200blerim",
                color: const Color(0xFFB3261E),
                icon: const ActionButton(
                  path: "assets/Will Learn.svg",
                  fillColor: Color(0xFFB3261E),
                  strokeColor: Color(0xFFFFFFFF),
                  size: 32,
                )),
            ListCard(
                title: "Favorilerim".split('').join('\ufeff'),
                color: const Color(0xFFFFD000),
                icon: const ActionButton(
                  path: "assets/Favorites.svg",
                  fillColor: Color(0xFFFFD000),
                  strokeColor: Color(0xFFFFFFFF),
                  size: 32,
                )),
            ListCard(
                title: "Öğrendik\u200blerim",
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
      ],
    );
  }
}
