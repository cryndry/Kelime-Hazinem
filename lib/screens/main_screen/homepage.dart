import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/icon.dart';
import 'package:kelime_hazinem/components/list_card.dart';
import 'package:kelime_hazinem/components/list_card_grid.dart';
import 'package:kelime_hazinem/components/page_layout.dart';
import 'package:kelime_hazinem/components/random_word_card.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin<HomePage> {
  @override
  bool get wantKeepAlive => true; // when tabbar's selected tab changes, state will be remembered

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return PageLayout(
      children: [
        const RandomWordCard(),
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
                  icon: MySvgs.willLearn,
                  fillColor: Color(0xFFB3261E),
                  size: 32,
                )),
            ListCard(
                title: "Favorilerim".split('').join('\ufeff'),
                color: const Color(0xFFFFD000),
                icon: const ActionButton(
                  icon: MySvgs.favorites,
                  fillColor: Color(0xFFFFD000),
                  size: 32,
                )),
            ListCard(
                title: "Öğrendik\u200blerim",
                color: const Color(0xFF70E000),
                icon: const ActionButton(
                  icon: MySvgs.learned,
                  fillColor: Color(0xFF70E000),
                  size: 32,
                )),
            ListCard(
                title: "Hazinem",
                color: const Color(0xFF008000),
                icon: const ActionButton(
                  icon: MySvgs.memorized,
                  fillColor: Color(0xFF008000),
                  size: 32,
                )),
          ],
        ),
      ],
    );
  }
}
