import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/color_animated_icon.dart';
import 'package:kelime_hazinem/components/icon.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';
import 'package:kelime_hazinem/utils/database.dart';
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
    final isAnimatable = KeyValueDatabase.getIsAnimatable();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: isAnimatable
            ? <AnimatedActionButton>[
                AnimatedActionButton(
                  duration: 300,
                  size: eachIconSize,
                  icon: MySvgs.willLearn,
                  isActive: intAsBool(word.willLearn),
                  activeFillColor: MyColors.red,
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
                  activeFillColor: MyColors.amber,
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
                  activeFillColor: MyColors.green,
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
                  activeFillColor: MyColors.darkGreen,
                  strokeColor: iconStrokeColor,
                  semanticsLabel: "Hazineme Ekle",
                  onTap: () {
                    handleSetState(word.memorizedToggle);
                  },
                ),
              ]
            : <ActionButton>[
                ActionButton(
                  size: eachIconSize,
                  icon: MySvgs.willLearn,
                  fillColor: intAsBool(word.willLearn) ? MyColors.red : Colors.transparent,
                  strokeColor: iconStrokeColor,
                  semanticsLabel: "Öğreneceklerime Ekle",
                  onTap: () {
                    handleSetState(word.willLearnToggle);
                  },
                ),
                ActionButton(
                  size: eachIconSize,
                  icon: MySvgs.favorites,
                  fillColor: intAsBool(word.favorite) ? MyColors.amber : Colors.transparent,
                  strokeColor: iconStrokeColor,
                  semanticsLabel: "Favorilerime Ekle",
                  onTap: () {
                    handleSetState(word.favoriteToggle);
                  },
                ),
                ActionButton(
                  size: eachIconSize,
                  icon: MySvgs.learned,
                  fillColor: intAsBool(word.learned) ? MyColors.green : Colors.transparent,
                  strokeColor: iconStrokeColor,
                  semanticsLabel: "Öğrendiklerime Ekle",
                  onTap: () {
                    handleSetState(word.learnedToggle);
                  },
                ),
                ActionButton(
                  size: eachIconSize,
                  icon: MySvgs.memorized,
                  fillColor: intAsBool(word.memorized) ? MyColors.darkGreen : Colors.transparent,
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
