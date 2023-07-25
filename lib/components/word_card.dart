import 'package:flutter/material.dart';
import 'package:kelime_hazinem/utils/colors_text_styles_patterns.dart';
import 'package:kelime_hazinem/utils/word_db_model.dart';
import 'package:kelime_hazinem/components/word_action_button_row.dart';

class WordCard extends StatefulWidget {
  const WordCard({super.key, required this.word, this.wordRemove});

  final Word word;
  final void Function(int)? wordRemove;

  @override
  State<WordCard> createState() => WordCardState();
}

class WordCardState extends State<WordCard> {
  final TextStyle wordTextStyle = MyTextStyles.font_20_24_600.apply(color: Colors.white);
  final TextStyle infoTextStyle = MyTextStyles.font_14_16_500.apply(color: Colors.white60);
  final TextStyle meaningTextStyle = MyTextStyles.font_16_20_500.apply(color: Colors.white.withOpacity(0.9));

  int intBoolInvert(int value) => (value == 1) ? 0 : 1;
  bool intAsBool(int value) => (value == 1);

  void handleSetState(Function() callback) {
    setState(() {
      callback();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(context).pushNamed(
          "WordShow",
          arguments: {"word": widget.word},
        );
        if (result != null && (result as Map)["deleted"] && widget.wordRemove != null) {
          widget.wordRemove!(widget.word.id);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: MyColors.lightBlue,
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
                  if (widget.word.description.isNotEmpty) const SizedBox(height: 2),
                  if (widget.word.description.isNotEmpty) Text(widget.word.description, style: infoTextStyle),
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
      ),
    );
  }
}
