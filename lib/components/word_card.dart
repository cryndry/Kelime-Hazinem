import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/color_animated_icon.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/word_db_model.dart';

class WordCard extends StatefulWidget {
  const WordCard({super.key, required this.word});

  final Word word;

  final TextStyle wordTextStyle = const TextStyle(
    fontSize: 20,
    height: 24 / 20,
    fontWeight: FontWeight.w600,
    color: Color.fromRGBO(255, 255, 255, 1),
  );

  final TextStyle infoTextStyle = const TextStyle(
    fontSize: 14,
    height: 16 / 14,
    fontWeight: FontWeight.w500,
    color: Color.fromRGBO(255, 255, 255, 0.6),
  );

  final TextStyle meaningTextStyle = const TextStyle(
    fontSize: 16,
    height: 20 / 16,
    fontWeight: FontWeight.w500,
    color: Color.fromRGBO(255, 255, 255, 0.9),
  );

  int intBoolInvert(int value) => (value == 1) ? 0 : 1;
  bool intAsBool(int value) => (value == 1);

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color.fromARGB(255, 75, 161, 255),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(widget.word.word, style: widget.wordTextStyle),
                if (widget.word.description != null) const SizedBox(height: 2),
                if (widget.word.description != null) Text(widget.word.description!, style: widget.infoTextStyle),
                const SizedBox(height: 8),
                Text(widget.word.meaning, style: widget.meaningTextStyle),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <AnimatedActionButton>[
                AnimatedActionButton(
                  duration: 300,
                  size: 32,
                  path: "assets/Will Learn.svg",
                  isActive: widget.intAsBool(widget.word.willLearn),
                  activeFillColor: const Color(0xFFB3261E),
                  strokeColor: const Color(0xFFFFFFFF),
                  semanticsLabel: "Öğreneceklerime Ekle",
                  onTap: () {
                    setState(() {
                      widget.word.willLearn = widget.intBoolInvert(widget.word.willLearn);
                      var changes = {"willLearn": widget.word.willLearn};
                      if (widget.word.willLearn == 1) {
                        if (widget.intAsBool(widget.word.learned)) {
                          widget.word.learned = 0;
                          changes["learned"] = 0;
                        } else if (widget.intAsBool(widget.word.memorized)) {
                          widget.word.memorized = 0;
                          changes["memorized"] = 0;
                        }
                      }
                      SqlDatabase.updateWord(widget.word.id, changes);
                    });
                  },
                ),
                AnimatedActionButton(
                  duration: 300,
                  size: 32,
                  path: "assets/Favorites.svg",
                  isActive: widget.intAsBool(widget.word.favorite),
                  activeFillColor: const Color(0xFFFFD000),
                  strokeColor: const Color(0xFFFFFFFF),
                  semanticsLabel: "Favorilerime Ekle",
                  onTap: () {
                    setState(() {
                      widget.word.favorite = widget.intBoolInvert(widget.word.favorite);
                      SqlDatabase.updateWord(widget.word.id, {"favorite": widget.word.favorite});
                    });
                  },
                ),
                AnimatedActionButton(
                  duration: 300,
                  size: 32,
                  path: "assets/Learned.svg",
                  isActive: widget.intAsBool(widget.word.learned),
                  activeFillColor: const Color(0xFF70E000),
                  strokeColor: const Color(0xFFFFFFFF),
                  semanticsLabel: "Öğrendiklerime Ekle",
                  onTap: () {
                    setState(() {
                      widget.word.learned = widget.intBoolInvert(widget.word.learned);
                      var changes = {"learned": widget.word.learned};
                      if (widget.word.learned == 1) {
                        if (widget.intAsBool(widget.word.willLearn)) {
                          widget.word.willLearn = 0;
                          changes["willLearn"] = 0;
                        } else if (widget.intAsBool(widget.word.memorized)) {
                          widget.word.memorized = 0;
                          changes["memorized"] = 0;
                        }
                      }
                      SqlDatabase.updateWord(widget.word.id, changes);
                    });
                  },
                ),
                AnimatedActionButton(
                  duration: 300,
                  size: 32,
                  path: "assets/Memorized.svg",
                  isActive: widget.intAsBool(widget.word.memorized),
                  activeFillColor: const Color(0xFF008000),
                  strokeColor: const Color(0xFFFFFFFF),
                  semanticsLabel: "Hazineme Ekle",
                  onTap: () {
                    setState(() {
                      widget.word.memorized = widget.intBoolInvert(widget.word.memorized);
                      var changes = {"memorized": widget.word.memorized};
                      if (widget.word.memorized == 1) {
                        if (widget.intAsBool(widget.word.willLearn)) {
                          widget.word.willLearn = 0;
                          changes["willLearn"] = 0;
                        } else if (widget.intAsBool(widget.word.learned)) {
                          widget.word.learned = 0;
                          changes["learned"] = 0;
                        }
                      }
                      SqlDatabase.updateWord(widget.word.id, changes);
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
