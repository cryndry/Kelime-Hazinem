import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/icon.dart';
import 'package:kelime_hazinem/components/word_card.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';
import 'package:kelime_hazinem/utils/word_db_model.dart';

class RandomWordCard extends StatefulWidget {
  const RandomWordCard({super.key});

  @override
  RandomWordCardState createState() => RandomWordCardState();
}

class RandomWordCardState extends State<RandomWordCard> {
  double turns = 0;
  Word word = Word.placeholder();

  void getRandomWord() {
    SqlDatabase.getRandomWord().then((randomWord) {
      setState(() {
        word = randomWord;
      });
    });
  }

  @override
  void initState() {
    getRandomWord();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isAnimatable = KeyValueDatabase.getIsAnimatable();
    return Stack(
      children: [
        WordCard(
          word: word,
          key: ValueKey(word.id),
          wordChange: getRandomWord,
        ),
        Positioned(
          top: 16,
          right: 16,
          width: 32,
          height: 32,
          child: isAnimatable
              ? AnimatedRotation(
                  turns: turns,
                  duration: MyDurations.millisecond300,
                  onEnd: getRandomWord,
                  child: ActionButton(
                    icon: MySvgs.refresh,
                    size: 32,
                    semanticsLabel: "Kelimeyi Yenile",
                    onTap: () {
                      setState(() {
                        turns += 0.5;
                      });
                    },
                  ),
                )
              : ActionButton(
                  icon: MySvgs.refresh,
                  size: 32,
                  semanticsLabel: "Kelimeyi Yenile",
                  onTap: getRandomWord,
                ),
        ),
      ],
    );
  }
}
