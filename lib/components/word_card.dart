import 'package:flutter/material.dart';
import 'package:kelime_hazinem/utils/word_db_model.dart';
import 'package:kelime_hazinem/components/word_action_button_row.dart';

class WordCard extends StatefulWidget {
  const WordCard({super.key, required this.word});

  final Word word;

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
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

  void handleSetState(Function() callback) {
    setState(() {
      callback();
    });
  }

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
                Text(widget.word.word, style: wordTextStyle),
                if (widget.word.description != null) const SizedBox(height: 2),
                if (widget.word.description != null) Text(widget.word.description!, style: infoTextStyle),
                const SizedBox(height: 8),
                Text(widget.word.meaning, style: meaningTextStyle),
              ],
            ),
          ),
          const SizedBox(height: 8),
          WordActionButtonRow(
            word: widget.word,
            eachIconSize: 32,
            iconStrokeColor: Colors.white,
            handleSetState: handleSetState,
          ),
        ],
      ),
    );
  }
}
