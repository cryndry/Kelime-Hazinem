import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/icon.dart';
import 'package:kelime_hazinem/components/word_card.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';
import 'package:kelime_hazinem/utils/word_db_model.dart';

class RandomWordCard extends StatefulWidget {
  const RandomWordCard({super.key});

  @override
  State<RandomWordCard> createState() => _RandomWordCardState();
}

class _RandomWordCardState extends State<RandomWordCard> {
  Word word = Word(
    id: -1,
    word: "Yükleniyor...",
    meaning: "Yükleniyor...",
    description: "Yükleniyor...",
    wordSearch: "",
    descriptionSearch: "",
    willLearn: 0,
    favorite: 0,
    learned: 0,
    memorized: 0,
  );

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
    return Stack(
      children: [
        WordCard(word: word),
        Positioned(
          top: 16,
          right: 16,
          width: 32,
          height: 32,
          child: ActionButton(
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
