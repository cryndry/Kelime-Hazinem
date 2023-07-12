import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/app_bar.dart';
import 'package:kelime_hazinem/components/icon.dart';
import 'package:kelime_hazinem/components/keep_alive_widget.dart';
import 'package:kelime_hazinem/components/nonscrollable_page_layout.dart';
import 'package:kelime_hazinem/utils/colors_text_styles_patterns.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';
import 'package:kelime_hazinem/utils/word_db_model.dart';

class WordGuess extends StatefulWidget {
  const WordGuess({super.key, required this.listName, required this.dbTitle});

  final String listName;
  final String dbTitle;

  @override
  State<WordGuess> createState() => WordGuessState();
}

class WordGuessState extends State<WordGuess> {
  final key = GlobalKey<WordGuessPageState>();
  
  final bool isAnimatable = KeyValueDatabase.getIsAnimatable();
  final int listLength = KeyValueDatabase.getOtherModsListLength();
  final PageController pageController = PageController();
  final TextEditingController textEditingController = TextEditingController(text: "1");
  final FocusNode textInputFocus = FocusNode();

  List<Word> words = [];
  List<Widget> appBarButtons = [];
  bool isListRefreshed = false;

  void animateToPageHandler() {
    textInputFocus.unfocus();

    int currentValue = int.parse(textEditingController.text);
    if (currentValue > 0 && currentValue <= words.length) {
      if (isAnimatable) {
        pageController.animateToPage(
          currentValue - 1,
          duration: const Duration(milliseconds: 500),
          curve: Curves.bounceOut,
        );
      } else {
        pageController.jumpToPage(currentValue - 1);
      }
    } else {
      textEditingController.text = (pageController.page! + 1).toInt().toString();
    }
  }

  void getToNextPage() {
    if (pageController.page != (words.length - 1)) {
      Future.delayed(
        const Duration(milliseconds: 500),
        () {
          final bool isAnimatable = KeyValueDatabase.getIsAnimatable();
          pageController.nextPage(
            duration: isAnimatable ? const Duration(milliseconds: 300) : const Duration(milliseconds: 1),
            curve: Curves.ease,
          );
        },
      );
    }
  }

  void refreshList() async {
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
      appBarButtons.removeLast();
      pageController.jumpToPage(0);
      isListRefreshed = true;
    });
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

    ActionButton tipButton = ActionButton(
      icon: MySvgs.tip,
      size: 32,
      onTap: () {},
    );

    appBarButtons = [
      (isAnimatable)
          ? AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: Visibility(
                visible: true,
                child: tipButton,
              ))
          : tipButton,
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
        appBar: MyAppBar(title: "Kelimeyi Bul", secTitle: widget.listName, buttons: appBarButtons),
        body: Stack(
          alignment: Alignment.center,
          children: [
            NonScrollablePageLayout(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: MyColors.darkBlue.withOpacity(0.7),
                    width: 2,
                  ),
                ),
                child: PageView.custom(
                  onPageChanged: (value) {
                    textEditingController.value = TextEditingValue(text: (value + 1).toString());
                    if (value + 1 == words.length && appBarButtons.length == 1) {
                      setState(() {
                        appBarButtons.add(
                          ActionButton(
                            icon: MySvgs.refresh,
                            size: 32,
                            onTap: refreshList,
                          ),
                        );
                      });
                    }
                  },
                  controller: pageController,
                  scrollDirection: Axis.horizontal,
                  childrenDelegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final Word currentWord = words[index];
                      final wordPage = WordGuessPage(
                        currentWord: currentWord,
                        getToNextPage: getToNextPage,
                        isAnimatable: isAnimatable,
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
                    style: MyTextStyles.font_24_32_500,
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
                      suffixStyle: MyTextStyles.font_24_32_500,
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

class WordGuessPage extends StatefulWidget {
  const WordGuessPage({
    super.key,
    required this.currentWord,
    required this.getToNextPage,
    required this.isAnimatable,
  });

  final Word currentWord;
  final void Function() getToNextPage;
  final bool isAnimatable;

  @override
  WordGuessPageState createState() => WordGuessPageState();
}

class WordGuessPageState extends State<WordGuessPage> {
  final allLetters = [
    'ء',
    'أ',
    'إ',
    'ؤ',
    'ئ',
    'ا',
    'ب',
    'ت',
    'ث',
    'ج',
    'ح',
    'خ',
    'د',
    'ذ',
    'ر',
    'ز',
    'س',
    'ش',
    'ص',
    'ض',
    'ط',
    'ظ',
    'ع',
    'غ',
    'ف',
    'ق',
    'ک',
    'ل',
    'م',
    'ن',
    'و',
    'ه',
    'ة',
    'ي',
    'ى'
  ];

  bool isCompleted = false;
  late bool isAnimatable = widget.isAnimatable;
  final Map<String, List<int>> letters = {};
  final List<String> options = [];
  final List<String> wordLetters = [];
  final List<int> revealedIndexes = [];
  List<Widget> optionWidgets = [];

  Map<String, List<int>> getLetterIndexes(List<String> word) {
    final letterMap = <String, List<int>>{};
    for (int i = 0; i < word.length; i++) {
      if (!letterMap.containsKey(word[i])) {
        letterMap[word[i]] = [i];
      } else {
        letterMap[word[i]]!.add(i);
      }
    }
    return letterMap;
  }

  List<String> createLetterOptions(List<String> word) {
    final options = word.toSet().toList();

    int counter = 0;
    while (counter < 5) {
      if (options.length < 15) {
        final randomLetter = allLetters[Random().nextInt(allLetters.length)];
        if (!options.contains(randomLetter)) {
          options.add(randomLetter);
          counter++;
        }
      } else {
        break;
      }
    }

    options.shuffle();
    return options;
  }

  LetterBoxStatus letterTapHandler(String letter) {
    if (isCompleted) return LetterBoxStatus.normal;

    if (letters.containsKey(letter) && letters[letter]!.isNotEmpty) {
      setState(() {
        int index = letters[letter]!.removeAt(0);
        revealedIndexes.add(index);
        if (revealedIndexes.length == wordLetters.length) {
          isCompleted = true;
          widget.getToNextPage();
        }
      });
      return LetterBoxStatus.correct;
    } else {
      return LetterBoxStatus.wrong;
    }
  }

  @override
  void initState() {
    wordLetters.addAll(MyRegExpPatterns.getWithoutHarakaButShaddah(widget.currentWord.word));
    letters.addAll(getLetterIndexes(wordLetters));
    options.addAll(createLetterOptions(wordLetters));

    optionWidgets = [
      for (String option in options)
        Builder(builder: (context) {
          LetterBoxStatus status = LetterBoxStatus.normal;
          return StatefulBuilder(
            builder: (context, setWidgetState) {
              return GestureDetector(
                onTap: () {
                  final newStatus = letterTapHandler(option);
                  setWidgetState(() {
                    status = newStatus;
                    Timer(const Duration(milliseconds: 600), () {
                      setWidgetState(() {
                        status = LetterBoxStatus.normal;
                      });
                    });
                  });
                },
                child: WordGuessLetterBox(
                  letter: option,
                  status: status,
                  isAnimatable: isAnimatable,
                ),
              );
            },
          );
        }),
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    textDirection: TextDirection.rtl,
                    children: [
                      for (int i = 0; i < wordLetters.length; i++)
                        WordGuessLetterBox(
                          letter: wordLetters[i],
                          visible: revealedIndexes.contains(i),
                          isAnimatable: isAnimatable,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(maxWidth: 240),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      boxShadow: [BoxShadow(blurRadius: 4, color: MyColors.darkBlue)],
                    ),
                    child: Text(
                      widget.currentWord.meaning,
                      textAlign: TextAlign.center,
                      style: MyTextStyles.font_16_20_400,
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: optionWidgets,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum LetterBoxStatus {
  normal,
  correct,
  wrong,
}

class WordGuessLetterBox extends StatefulWidget {
  const WordGuessLetterBox({
    super.key,
    required this.letter,
    required this.isAnimatable,
    this.visible = true,
    this.status = LetterBoxStatus.normal,
  });

  final String letter;
  final bool visible;
  final bool isAnimatable;
  final LetterBoxStatus status;

  @override
  State<WordGuessLetterBox> createState() => WordGuessLetterBoxState();
}

class WordGuessLetterBoxState extends State<WordGuessLetterBox> {
  late LetterBoxStatus status = widget.status;
  late bool isAnimatable = widget.isAnimatable;

  final shadowColors = const {
    LetterBoxStatus.normal: Colors.black26,
    LetterBoxStatus.correct: MyColors.green,
    LetterBoxStatus.wrong: MyColors.red,
  };

  final textColors = const {
    LetterBoxStatus.normal: Colors.black,
    LetterBoxStatus.correct: MyColors.green,
    LetterBoxStatus.wrong: MyColors.red,
  };

  @override
  void didUpdateWidget(covariant WordGuessLetterBox oldWidget) {
    setState(() {
      status = widget.status;
    });

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final Widget letterTextWidget = Visibility(
      visible: widget.visible,
      child: Text(
        widget.letter,
        style: MyTextStyles.font_24_32_500.merge(TextStyle(color: textColors[status])),
      ),
    );

    return Container(
      alignment: Alignment.center,
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(blurRadius: 2, color: shadowColors[status]!)],
      ),
      child: isAnimatable
          ? AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn,
              child: letterTextWidget,
            )
          : letterTextWidget,
    );
  }
}
