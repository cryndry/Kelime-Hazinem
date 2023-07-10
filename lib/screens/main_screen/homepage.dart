import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/icon.dart';
import 'package:kelime_hazinem/components/keep_alive_widget.dart';
import 'package:kelime_hazinem/components/list_card.dart';
import 'package:kelime_hazinem/components/list_card_grid.dart';
import 'package:kelime_hazinem/components/page_layout.dart';
import 'package:kelime_hazinem/components/random_word_card.dart';
import 'package:kelime_hazinem/utils/colors_text_styles_patterns.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      children: [
        const KeepAliveWidget(child: RandomWordCard()),
        const SizedBox(height: 12),
        ListCardGrid(
          children: [
            ListCard(title: "Temel Seviye"),
            ListCard(title: "Orta Seviye"),
            ListCard(title: "İleri Seviye"),
            ListCard(
                title: "Öğrenecek\u200blerim",
                dbTitle: "willLearn",
                color: MyColors.red,
                icon: const ActionButton(
                  icon: MySvgs.willLearn,
                  fillColor: MyColors.red,
                  size: 32,
                )),
            ListCard(
                title: "Favorilerim".split('').join('\ufeff'),
                dbTitle: "favorite",
                color: MyColors.amber,
                icon: const ActionButton(
                  icon: MySvgs.favorites,
                  fillColor: MyColors.amber,
                  size: 32,
                )),
            ListCard(
                title: "Öğrendik\u200blerim",
                dbTitle: "learned",
                color: MyColors.green,
                icon: const ActionButton(
                  icon: MySvgs.learned,
                  fillColor: MyColors.green,
                  size: 32,
                )),
            ListCard(
                title: "Hazinem",
                dbTitle: "memorized",
                color: MyColors.darkGreen,
                icon: const ActionButton(
                  icon: MySvgs.memorized,
                  fillColor: MyColors.darkGreen,
                  size: 32,
                )),
          ],
        ),
      ],
    );
  }
}
