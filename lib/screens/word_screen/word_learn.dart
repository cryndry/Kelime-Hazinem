import 'dart:math' show Random, min;
import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/app_bar.dart';
import 'package:kelime_hazinem/components/icon.dart';
import 'package:kelime_hazinem/components/keep_alive_widget.dart';
import 'package:kelime_hazinem/components/nonscrollable_page_layout.dart';
import 'package:kelime_hazinem/components/word_action_button_row.dart';
import 'package:kelime_hazinem/screens/word_edit_add.dart';
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
  final int listLength = KeyValueDatabase.getWordLearnListLength();
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
  bool isListRefreshed = false;

  late final List<ActionButton> constAppBarButtons = [
    const ActionButton(
      icon: MySvgs.add2List,
      size: 32,
      semanticsLabel: "Add This Word To Lists",
    ),
    ActionButton(
      icon: MySvgs.edit,
      size: 32,
      semanticsLabel: "Edit The Word Entry",
      onTap: () async {
        final int wordIndex = pageController.page!.toInt();
        final result = await Navigator.of(context).push<Map<String, dynamic>>(PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => WordEditAdd(word: words[wordIndex]),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            Animatable<Offset> tween = Tween(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.ease));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ));
        setState(() {
          if (result != null && result["deleted"]) {
            words.removeAt(wordIndex);
            if (wordIndex == words.length) {
              textEditingController.text = wordIndex.toString();
            }
          }
        });
      },
    ),
  ];

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
    SqlDatabase.getWordsQuery(
      limit: listLength,
      listName: widget.dbTitle,
      isIconicList: widget.dbTitle != widget.listName,
      isInRandomOrder: true,
    ).then((result) {
      setState(() {
        words = result;
      });
    });

    appBarButtons = [...constAppBarButtons];

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
                          ...constAppBarButtons,
                          ActionButton(
                            icon: MySvgs.refresh,
                            size: 32,
                            semanticsLabel: "Refresh The List",
                            onTap: () async {
                              final List<int> willRepeatIndexes = [];
                              while (willRepeatIndexes.length < (min(5, words.length))) {
                                final int index = Random().nextInt(words.length);
                                if (!willRepeatIndexes.contains(index)) {
                                  willRepeatIndexes.add(index);
                                }
                              }

                              final List<Word> willRepeatWords = willRepeatIndexes.map((i) => words[i]).toList();
                              final List<int> willRepeatIds = willRepeatWords.map((word) => word.id).toList();
                              final newWords = await SqlDatabase.getWordsQuery(
                                listName: widget.dbTitle,
                                isIconicList: widget.dbTitle != widget.listName,
                                limit: listLength - willRepeatIds.length,
                                exceptionIds: willRepeatIds,
                                isInRandomOrder: true,
                              );

                              setState(() {
                                words = (willRepeatWords + newWords)..shuffle();
                                appBarButtons = [...constAppBarButtons];
                                pageController.jumpToPage(0);
                                isListRefreshed = true;
                              });
                            },
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
                      final wordPage = WordLearnPage(
                        currentWord: currentWord,
                        handleSetState: handleSetState,
                      );

                      if (isListRefreshed) {
                        // disposes all the states from pages
                        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                          setState(() {
                            isListRefreshed = false;
                          });
                        });
                      }
                      return isListRefreshed
                          ? wordPage
                          : KeepAliveWidget(
                              child: wordPage,
                            );
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
                      suffixText: " / ${words.length}",
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

class WordLearnPage extends StatefulWidget {
  const WordLearnPage({
    super.key,
    required this.currentWord,
    required this.handleSetState,
  });

  final Word currentWord;
  final void Function(void Function()) handleSetState;

  @override
  WordLearnPageState createState() => WordLearnPageState();
}

class WordLearnPageState extends State<WordLearnPage> {
  final bool isAnimatable = KeyValueDatabase.getIsAnimatable();
  bool isMeaningVisible = false;
  double wordFlipTurn = 0;

  @override
  void didUpdateWidget(covariant WordLearnPage oldWidget) {
    // if (oldWidget.currentWord.id != widget.currentWord.id) {
    if (oldWidget.currentWord.hashCode != widget.currentWord.hashCode) {
      setState(() {
        isMeaningVisible = false;
        wordFlipTurn = 0;
      });
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final wordWidget = Text(
      widget.currentWord.word,
      style: const TextStyle(
        fontSize: 28,
        height: 36 / 28,
        fontWeight: FontWeight.w600,
      ),
    );

    final infoWidget = Visibility(
      visible: isMeaningVisible,
      child: Column(
        children: [
          if (widget.currentWord.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                widget.currentWord.description,
                style: const TextStyle(
                  fontSize: 16,
                  height: 20 / 16,
                  fontWeight: FontWeight.w500,
                  color: Color.fromRGBO(0, 0, 0, 0.6),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 64),
            child: Text(
              widget.currentWord.meaning.replaceAll(RegExp(r"(\|)"), ", "),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                height: 28 / 20,
                fontWeight: FontWeight.w500,
                color: Color.fromRGBO(0, 0, 0, 0.8),
              ),
            ),
          ),
        ],
      ),
    );

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isMeaningVisible = true;
              wordFlipTurn = 1;
            });
          },
          child: AbsorbPointer(
            child: Row(
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
                      isAnimatable
                          ? AnimatedRotation(
                              turns: wordFlipTurn,
                              duration: const Duration(milliseconds: 400),
                              child: wordWidget,
                            )
                          : wordWidget,
                      isAnimatable
                          ? AnimatedSize(
                              duration: const Duration(milliseconds: 400),
                              child: infoWidget,
                            )
                          : infoWidget,
                    ],
                  ),
                ),
              ],
            ),
          ),
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
