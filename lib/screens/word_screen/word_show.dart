import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/sheets_and_dialogs/add_word_to_lists.dart';
import 'package:kelime_hazinem/components/app_bars/app_bar.dart';
import 'package:kelime_hazinem/components/buttons/icon.dart';
import 'package:kelime_hazinem/components/layouts/nonscrollable_page_layout.dart';
import 'package:kelime_hazinem/components/sheets_and_dialogs/share_word.dart';
import 'package:kelime_hazinem/components/words_and_lists/word_action_button_row.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';
import 'package:kelime_hazinem/utils/word_db_model.dart';

class WordShow extends StatefulWidget {
  const WordShow({super.key, required this.word});

  final Word word;

  @override
  WordShowState createState() => WordShowState();
}

class WordShowState extends State<WordShow> {
  List<ActionButton> appBarButtons = [];

  void handleSetState(Function() callback) {
    setState(() {
      callback();
    });
  }

  @override
  void initState() {
    appBarButtons = [
      ActionButton(
        icon: MySvgs.add2List,
        size: 32,
        semanticsLabel: "Listelere Ekle",
        onTap: () {
          addWordToLists(context: context, wordId: widget.word.id);
        },
      ),
      ActionButton(
        icon: MySvgs.edit,
        size: 32,
        semanticsLabel: "Düzenle",
        onTap: () async {
          final result = await Navigator.of(context).pushNamed(
            "WordEdit",
            arguments: {"word": widget.word},
          );
          if (result != null && (result as Map)["deleted"]) {
            Navigator.of(context).pop(result);
          } else {
            setState(() {});
          }
        },
      ),
      ActionButton(
        icon: MySvgs.share,
        size: 32,
        semanticsLabel: "Kelimeyi Paylaş",
        onTap: () {
          shareWord(context: context, word: widget.word);
        },
      ),
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(title: widget.word.word, buttons: appBarButtons),
        body: NonScrollablePageLayout(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: MyColors.darkBlue.withOpacity(0.7),
                width: 2,
              ),
            ),
            child: PageView(
              children: [
                WordShowPage(
                  currentWord: widget.word,
                  handleSetState: handleSetState,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WordShowPage extends StatelessWidget {
  const WordShowPage({
    super.key,
    required this.currentWord,
    required this.handleSetState,
  });

  final Word currentWord;
  final void Function(void Function()) handleSetState;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                children: [
                  const Flexible(child: FractionallySizedBox(heightFactor: 0.4)),
                  Text(currentWord.word, style: MyTextStyles.font_28_36_600),
                  if (currentWord.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        currentWord.description,
                        style: MyTextStyles.font_16_20_500.merge(TextStyle(
                          color: Colors.black.withOpacity(0.6),
                        )),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 64),
                    child: Text(
                      currentWord.meaning,
                      textAlign: TextAlign.center,
                      style: MyTextStyles.font_20_24_500.merge(TextStyle(
                        color: Colors.black.withOpacity(0.8),
                      )),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 36,
          child: WordActionButtonRow(
            word: currentWord,
            eachIconSize: 36,
            iconStrokeColor: Colors.black,
            handleSetState: handleSetState,
          ),
        ),
      ],
    );
  }
}
