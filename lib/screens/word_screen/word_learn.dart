import 'dart:math' show min;
import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/app_bar.dart';
import 'package:kelime_hazinem/components/icon.dart';
import 'package:kelime_hazinem/components/nonscrollable_page_layout.dart';
import 'package:kelime_hazinem/components/word_action_button_row.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';
import 'package:kelime_hazinem/utils/word_db_model.dart';

class WordLearn extends StatefulWidget {
  const WordLearn({super.key, required this.listName, required this.dbTitle});

  final String listName;
  final String dbTitle;

  @override
  State<WordLearn> createState() => _WordLearnState();
}

class _WordLearnState extends State<WordLearn> {
  int currentPage = 0;
  final int listLength = SharedPreferencesDatabase.db.getInt("wordLearnListLength")!;
  final PageController pageController = PageController();
  final TextEditingController textEditingController = TextEditingController(text: "1");
  final FocusNode textInputFocus = FocusNode();
  final counterTextStyle = const TextStyle(
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w500,
  );

  List<Word> words = [];
  List<ActionButton> appBarButtons = [];

  int intBoolInvert(int value) => (value == 1) ? 0 : 1;
  bool intAsBool(int value) => (value == 1);

  void handleSetState(Function() callback) {
    setState(() {
      callback();
    });
  }

  void animateToPageHandler() {
    textInputFocus.unfocus();

    int currentValue = int.parse(textEditingController.text);
    if (currentValue > 0 && currentValue <= words.length) {
      pageController.animateToPage(
        currentValue - 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.bounceOut,
      );
    } else {
      textEditingController.text = (pageController.page! + 1).toInt().toString();
    }
  }

  @override
  void initState() {
    SqlDatabase.getWordsQuery(listLength, widget.dbTitle).then((result) {
      setState(() {
        words = result;
      });
    });

    appBarButtons = [
      const ActionButton(
        icon: MySvgs.add2List,
        size: 32,
        semanticsLabel: "Add This Word To Lists",
      ),
      const ActionButton(
        icon: MySvgs.edit,
        size: 32,
        semanticsLabel: "Edit The Word Entry",
      ),
    ];

    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    textEditingController.dispose();
    textInputFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(title: "Kelime Öğrenme", secTitle: widget.listName, buttons: appBarButtons),
        body: Stack(
          alignment: Alignment.center,
          children: [
            NonScrollablePageLayout(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF007AFF).withOpacity(0.7),
                    width: 2,
                  ),
                ),
                child: PageView.custom(
                  onPageChanged: (value) {
                    textEditingController.value = TextEditingValue(text: (value + 1).toString());
                    if (value + 1 == words.length && appBarButtons.length == 2) {
                      setState(() {
                        appBarButtons = [
                          ...appBarButtons,
                          const ActionButton(
                            icon: MySvgs.refresh,
                            size: 32,
                            semanticsLabel: "Refresh The List",
                          )
                        ];
                      });
                    }
                  },
                  controller: pageController,
                  scrollDirection: Axis.horizontal,
                  childrenDelegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final Word currentWord = words[index];
                      return KeepAlivePage(currentWord: currentWord, handleSetState: handleSetState);
                    },
                    childCount: words.length,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                height: 32,
                color: Colors.white,
                alignment: Alignment.topCenter,
                child: IntrinsicWidth(
                  child: TextField(
                    showCursor: true,
                    focusNode: textInputFocus,
                    style: counterTextStyle,
                    autocorrect: false,
                    keyboardType: TextInputType.number,
                    controller: textEditingController,
                    onEditingComplete: animateToPageHandler,
                    onTapOutside: (event) {
                      if (textInputFocus.hasFocus) {
                        animateToPageHandler();
                      }
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      suffixText: " / ${min(listLength, words.length)}",
                      suffixStyle: counterTextStyle,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KeepAlivePage extends StatefulWidget {
  const KeepAlivePage({
    super.key,
    required this.currentWord,
    required this.handleSetState,
  });

  final Word currentWord;
  final void Function(void Function()) handleSetState;

  @override
  KeepAlivePageState createState() => KeepAlivePageState();
}

class KeepAlivePageState extends State<KeepAlivePage> with AutomaticKeepAliveClientMixin<KeepAlivePage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Column(
                children: [
                  const Flexible(
                    child: FractionallySizedBox(
                      heightFactor: 0.4,
                    ),
                  ),
                  Text(
                    widget.currentWord.word,
                    style: const TextStyle(
                      fontSize: 28,
                      height: 36 / 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (widget.currentWord.description != null) const SizedBox(height: 8),
                  if (widget.currentWord.description != null)
                    Text(
                      widget.currentWord.description!,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 20 / 16,
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(0, 0, 0, 0.6),
                      ),
                    ),
                  const SizedBox(height: 64),
                  Text(
                    widget.currentWord.meaning.replaceAll(RegExp(r"(\|)"), ", "),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      height: 28 / 20,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(0, 0, 0, 0.8),
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
            word: widget.currentWord,
            eachIconSize: 36,
            iconStrokeColor: Colors.black,
            handleSetState: widget.handleSetState,
          ),
        ),
      ],
    );
  }
}
