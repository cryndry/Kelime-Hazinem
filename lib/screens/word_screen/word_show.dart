import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/add_word_to_lists.dart';
import 'package:kelime_hazinem/components/app_bar.dart';
import 'package:kelime_hazinem/components/icon.dart';
import 'package:kelime_hazinem/components/nonscrollable_page_layout.dart';
import 'package:kelime_hazinem/screens/word_screen/word_learn.dart';
import 'package:kelime_hazinem/utils/colors_text_styles_patterns.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';
import 'package:kelime_hazinem/utils/word_db_model.dart';

class WordShow extends StatefulWidget {
  const WordShow({super.key, required this.word});

  final Word word;

  @override
  State<WordShow> createState() => WordShowState();
}

class WordShowState extends State<WordShow> {
  List<ActionButton> appBarButtons = [];

  @override
  void initState() {
    appBarButtons = [
      ActionButton(
        icon: MySvgs.add2List,
        size: 32,
        semanticsLabel: "Add This Word To Lists",
        onTap: () {
          addWordToLists(context: context, wordId: widget.word.id);
        },
      ),
      ActionButton(
        icon: MySvgs.edit,
        size: 32,
        semanticsLabel: "Edit The Word Entry",
        onTap: () async {
          final result = await Navigator.of(context).pushNamed(
            "WordEdit",
            arguments: {"word": widget.word},
          );
          if (result != null && (result as Map)["deleted"]) {
            Navigator.of(context).pop(result);
          }
        },
      ),
    ];

    super.initState();
  }

  int intBoolInvert(int value) => (value == 1) ? 0 : 1;
  bool intAsBool(int value) => (value == 1);

  void handleSetState(Function() callback) {
    setState(() {
      callback();
    });
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
                WordLearnPage(
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
