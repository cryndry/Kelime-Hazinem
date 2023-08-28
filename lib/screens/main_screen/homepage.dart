import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/buttons/icon.dart';
import 'package:kelime_hazinem/components/words_and_lists/list_card.dart';
import 'package:kelime_hazinem/components/layouts/list_card_grid.dart';
import 'package:kelime_hazinem/components/layouts/page_layout.dart';
import 'package:kelime_hazinem/components/others/performance.dart';
import 'package:kelime_hazinem/components/words_and_lists/random_word_card.dart';
import 'package:kelime_hazinem/utils/app_info.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';
import 'package:kelime_hazinem/utils/get_time_string.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      children: [
        const RandomWordCard(),
        if (AppInfo.installationTime.compareTo(GetTimeString.oneWeekBefore) < 0) ...const [
          SizedBox(height: 12),
          MyPerformance(),
        ],
        const SizedBox(height: 12),
        const ListCardGrid(
          children: [
            ListCard(title: "Temel Seviye", isDefaultList: true),
            ListCard(title: "Orta Seviye", isDefaultList: true),
            ListCard(title: "İleri Seviye", isDefaultList: true),
            ListCard(
                title: "Öğrenecek\u200blerim",
                dbTitle: "willLearn",
                isDefaultList: true,
                color: MyColors.red,
                icon: ActionButton(
                  icon: MySvgs.willLearn,
                  fillColor: MyColors.red,
                  size: 32,
                )),
            ListCard(
                title: "F\ufeffa\ufeffv\ufeffo\ufeffr\ufeffi\ufeffl\ufeffe\ufeffr\ufeffi\ufeffm",
                dbTitle: "favorite",
                isDefaultList: true,
                color: MyColors.amber,
                icon: ActionButton(
                  icon: MySvgs.favorites,
                  fillColor: MyColors.amber,
                  size: 32,
                )),
            ListCard(
                title: "Öğrendik\u200blerim",
                dbTitle: "learned",
                isDefaultList: true,
                color: MyColors.green,
                icon: ActionButton(
                  icon: MySvgs.learned,
                  fillColor: MyColors.green,
                  size: 32,
                )),
            ListCard(
                title: "Hazinem",
                dbTitle: "memorized",
                isDefaultList: true,
                color: MyColors.darkGreen,
                icon: ActionButton(
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
