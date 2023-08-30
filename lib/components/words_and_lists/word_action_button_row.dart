import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/buttons/color_animated_icon.dart';
import 'package:kelime_hazinem/components/buttons/icon.dart';
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

  bool intAsBool(int value) => (value != 0);

  @override
  Widget build(BuildContext context) {
    final isAnimatable = KeyValueDatabase.getIsAnimatable();

    return SizedBox(
      height: eachIconSize + 16,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                handleSetState(word.willLearnToggle);
              },
              behavior: HitTestBehavior.opaque,
              child: Align(
                child: isAnimatable
                    ? AnimatedActionButton(
                        duration: 300,
                        size: eachIconSize,
                        icon: MySvgs.willLearn,
                        isActive: intAsBool(word.willLearn),
                        activeFillColor: MyColors.red,
                        strokeColor: iconStrokeColor,
                        semanticsLabel: "Öğreneceklerime Ekle",
                      )
                    : ActionButton(
                        size: eachIconSize,
                        icon: MySvgs.willLearn,
                        fillColor: intAsBool(word.willLearn) ? MyColors.red : Colors.transparent,
                        strokeColor: iconStrokeColor,
                        semanticsLabel: "Öğreneceklerime Ekle",
                      ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                handleSetState(word.favoriteToggle);
              },
              behavior: HitTestBehavior.opaque,
              child: Align(
                child: isAnimatable
                    ? AnimatedActionButton(
                        duration: 300,
                        size: eachIconSize,
                        icon: MySvgs.favorites,
                        isActive: intAsBool(word.favorite),
                        activeFillColor: MyColors.amber,
                        strokeColor: iconStrokeColor,
                        semanticsLabel: "Favorilerime Ekle",
                      )
                    : ActionButton(
                        size: eachIconSize,
                        icon: MySvgs.favorites,
                        fillColor: intAsBool(word.favorite) ? MyColors.amber : Colors.transparent,
                        strokeColor: iconStrokeColor,
                        semanticsLabel: "Favorilerime Ekle",
                      ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                handleSetState(word.learnedToggle);
              },
              behavior: HitTestBehavior.opaque,
              child: Align(
                child: isAnimatable
                    ? AnimatedActionButton(
                        duration: 300,
                        size: eachIconSize,
                        icon: MySvgs.learned,
                        isActive: intAsBool(word.learned),
                        activeFillColor: MyColors.green,
                        strokeColor: iconStrokeColor,
                        semanticsLabel: "Öğrendiklerime Ekle",
                      )
                    : ActionButton(
                        size: eachIconSize,
                        icon: MySvgs.learned,
                        fillColor: intAsBool(word.learned) ? MyColors.green : Colors.transparent,
                        strokeColor: iconStrokeColor,
                        semanticsLabel: "Öğrendiklerime Ekle",
                      ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                handleSetState(word.memorizedToggle);
              },
              behavior: HitTestBehavior.opaque,
              child: Align(
                child: isAnimatable
                    ? AnimatedActionButton(
                        duration: 300,
                        size: eachIconSize,
                        icon: MySvgs.memorized,
                        isActive: intAsBool(word.memorized),
                        activeFillColor: MyColors.darkGreen,
                        strokeColor: iconStrokeColor,
                        semanticsLabel: "Hazineme Ekle",
                      )
                    : ActionButton(
                        size: eachIconSize,
                        icon: MySvgs.memorized,
                        fillColor: intAsBool(word.memorized) ? MyColors.darkGreen : Colors.transparent,
                        strokeColor: iconStrokeColor,
                        semanticsLabel: "Hazineme Ekle",
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
