import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/fab.dart';
import 'package:kelime_hazinem/components/page_layout.dart';
import 'package:kelime_hazinem/components/word_card.dart';

class AllWords extends StatelessWidget {
  const AllWords({super.key});

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      FABs: [
        FAB(iconPath: "assets/Plus.svg", onTap: (){}),
      ],
      children: List.generate(21, (index) {
      if (index.isEven) return const WordCard(isRandomWordCard: false);
      return const SizedBox(height: 12);
    }));
  }
}
