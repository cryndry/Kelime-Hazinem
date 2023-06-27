import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/color_animated_icon.dart';
import 'package:kelime_hazinem/utils/word_db_model.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';

class WordActionButtonRow extends StatelessWidget {
  const WordActionButtonRow({
    super.key,
    required this.word,
    required this.eachIconSize,
    required this.iconStrokeColor,
    required this.handleSetState,
  });

  final Word word;
  final double eachIconSize;
  final Color iconStrokeColor;
  final void Function(void Function()) handleSetState;

  int intBoolInvert(int value) => (value == 1) ? 0 : 1;
  bool intAsBool(int value) => (value == 1);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <AnimatedActionButton>[
          AnimatedActionButton(
            duration: 300,
            size: eachIconSize,
            icon: MySvgs.willLearn,
            isActive: intAsBool(word.willLearn),
            activeFillColor: const Color(0xFFB3261E),
            strokeColor: iconStrokeColor,
            semanticsLabel: "Öğreneceklerime Ekle",
            onTap: () {
              handleSetState(word.willLearnToggle);
            },
          ),
          AnimatedActionButton(
            duration: 300,
            size: eachIconSize,
            icon: MySvgs.favorites,
            isActive: intAsBool(word.favorite),
            activeFillColor: const Color(0xFFFFD000),
            strokeColor: iconStrokeColor,
            semanticsLabel: "Favorilerime Ekle",
            onTap: () {
              handleSetState(word.favoriteToggle);
            },
          ),
          AnimatedActionButton(
            duration: 300,
            size: eachIconSize,
            icon: MySvgs.learned,
            isActive: intAsBool(word.learned),
            activeFillColor: const Color(0xFF70E000),
            strokeColor: iconStrokeColor,
            semanticsLabel: "Öğrendiklerime Ekle",
            onTap: () {
              handleSetState(word.learnedToggle);
            },
          ),
          AnimatedActionButton(
            duration: 300,
            size: eachIconSize,
            icon: MySvgs.memorized,
            isActive: intAsBool(word.memorized),
            activeFillColor: const Color(0xFF008000),
            strokeColor: iconStrokeColor,
            semanticsLabel: "Hazineme Ekle",
            onTap: () {
              handleSetState(word.memorizedToggle);
            },
          ),
        ],
      ),
    );
  }
}
