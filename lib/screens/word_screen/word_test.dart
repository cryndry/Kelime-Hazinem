import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/app_bar.dart';
import 'package:kelime_hazinem/components/bottom_sheet.dart';
import 'package:kelime_hazinem/components/fill_colored_button.dart';
import 'package:kelime_hazinem/components/icon.dart';
import 'package:kelime_hazinem/components/keep_alive_widget.dart';
import 'package:kelime_hazinem/components/nonscrollable_page_layout.dart';
import 'package:kelime_hazinem/components/stroke_colored_button.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';
import 'package:kelime_hazinem/utils/word_db_model.dart';

class WordTest extends StatefulWidget {
  const WordTest({super.key, required this.listName, required this.dbTitle});

  final String listName;
  final String dbTitle;

  @override
  State<WordTest> createState() => WordTestState();
}

class WordTestState extends State<WordTest> {
  final bool isAnimatable = KeyValueDatabase.getIsAnimatable();
  final int listLength = KeyValueDatabase.getOtherModsListLength();
  final PageController pageController = PageController();
  final TextEditingController textEditingController = TextEditingController(text: "1");
  final FocusNode textInputFocus = FocusNode();

  List<Word> words = [];
  List<String> meanings = [];
  final List<Widget> appBarButtons = [];
  bool isListRefreshed = false;
  Future<void>? handleMistakenAnswersFuture;

  int correctCount = 0;
  int wrongCount = 0;
  int emptyCount = 0;
  final List<int> mistakenIndexes = [];

  final correctTextStyle = MyTextStyles.font_20_24_500.apply(color: MyColors.green);
  final wrongTextStyle = MyTextStyles.font_20_24_500.apply(color: MyColors.red);
  final emptyTextStyle = MyTextStyles.font_20_24_500.apply(color: Colors.black.withOpacity(0.6));

  void animateToPageHandler() {
    textInputFocus.unfocus();

    int currentValue = int.parse(textEditingController.text);
    if (currentValue > 0 && currentValue <= words.length) {
      if (isAnimatable) {
        pageController.animateToPage(
          currentValue - 1,
          duration: MyDurations.millisecond500,
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
        MyDurations.millisecond500,
        () {
          final bool isAnimatable = KeyValueDatabase.getIsAnimatable();
          pageController.nextPage(
            duration: isAnimatable ? MyDurations.millisecond300 : MyDurations.millisecond1,
            curve: Curves.ease,
          );
        },
      );
    }
  }

  void refreshList() async {
    final List<Word> willRepeatWords = [];
    final bool isCurrentListIconic = widget.dbTitle != widget.listName;

    int loopCounter = 0;
    while (loopCounter < 10) {
      final int index = Random().nextInt(words.length);
      final Word word = words[index];
      if (willRepeatWords.contains(word)) {
        loopCounter++;
        continue;
      }

      bool isWordStillInList;
      if (isCurrentListIconic) {
        switch (widget.dbTitle) {
          case "willLearn":
            isWordStillInList = word.willLearn == 1;
            break;
          case "favorite":
            isWordStillInList = word.favorite == 1;
            break;
          case "learned":
            isWordStillInList = word.learned == 1;
            break;
          case "memorized":
            isWordStillInList = word.memorized == 1;
            break;
          default:
            isWordStillInList = true;
            break;
        }
      } else {
        final wordListData = await SqlDatabase.getListsOfWord(word.id);
        isWordStillInList = wordListData[widget.listName]!["is_word_in_list"] as bool;
      }

      if (isWordStillInList) {
        willRepeatWords.add(word);
      }

      if (willRepeatWords.length == 5) break;
      loopCounter++;
    }

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
      meanings = words.map((e) => e.meaning).toList();
      correctCount = 0;
      wrongCount = 0;
      emptyCount = words.length;
      mistakenIndexes.clear();
      handleMistakenAnswersFuture = null;
      if (appBarButtons.isNotEmpty) appBarButtons.removeLast();
      pageController.jumpToPage(0);
      isListRefreshed = true;
    });
  }

  void handleAnswer(bool result) {
    final int currentPage = pageController.page!.toInt();
    final bool isMarkedAsMistaken = mistakenIndexes.contains(currentPage);
    if (!isMarkedAsMistaken) {
      setState(() {
        if (result) {
          correctCount += 1;
          emptyCount -= 1;
        } else {
          mistakenIndexes.add(currentPage);
          wrongCount += 1;
          emptyCount -= 1;
        }
      });
    }

    if (emptyCount == 0) {
      endingHandler();
    }
  }

  Future<void> handleMistakenAnswers() async {
    await Future.delayed(MyDurations.millisecond1000);
    for (int index in mistakenIndexes) {
      words[index].willLearnToggle(setValue: 1);
    }
    return;
  }

  void endingHandler() {
    popBottomSheet(
      context: context,
      title: "Seti Tamamladınız!",
      widgetBetweenTitleAndInfo: (wrongCount > 0)
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "D: $correctCount",
                      textAlign: TextAlign.center,
                      style: correctTextStyle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Y: $wrongCount",
                      textAlign: TextAlign.center,
                      style: wrongTextStyle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "B: $emptyCount",
                      textAlign: TextAlign.center,
                      style: emptyTextStyle,
                    ),
                  ),
                ],
              ),
            )
          : null,
      info: (wrongCount > 0) ? "Yanlış yaptığınız kelimeleri Öğreneceklerim listesine ekleyebilirsiniz." : "",
      routeName: "TestCompletedBottomSheet",
      bottomWidgets: (setSheetState) => [
        FillColoredButton(
          title: "Yeni Sete Başla",
          onPressed: () {
            Navigator.of(context).pop();
            refreshList();
          },
        ),
        const SizedBox(height: 12),
        if (wrongCount > 0)
          FutureBuilder(
            future: handleMistakenAnswersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.connectionState == ConnectionState.active) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FillColoredButton(
                    title: "Kaydediliyor",
                    icon: const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                        semanticsLabel: "Kaydediliyor...",
                      ),
                    ),
                    onPressed: () {},
                  ),
                );
              } else if (snapshot.connectionState == ConnectionState.done) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FillColoredButton(
                  title: "Yanlışlarımı Kaydet",
                  onPressed: () {
                    setSheetState(() {
                      setState(() {
                        handleMistakenAnswersFuture = handleMistakenAnswers();
                      });
                    });
                  },
                ),
              );
            },
          ),
        StrokeColoredButton(
          title: "Anasayfaya Dön",
          onPressed: () {
            Navigator.of(context).popUntil(ModalRoute.withName("MainScreen"));
          },
        ),
      ],
    );
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
        meanings = result.map((word) => word.meaning).toList();
        emptyCount = result.length;
      });
    });

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
        appBar: MyAppBar(title: "Kelime Testi", secTitle: widget.listName, buttons: appBarButtons),
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
                child: Column(
                  children: [
                    Flexible(
                      child: PageView.custom(
                        onPageChanged: (value) {
                          textEditingController.value = TextEditingValue(text: (value + 1).toString());
                          if (appBarButtons.isEmpty && value + 1 == words.length) {
                            setState(() {
                              appBarButtons.add(
                                ActionButton(
                                  icon: MySvgs.save,
                                  size: 32,
                                  onTap: endingHandler,
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
                            final wordPage = WordTestPage(
                              currentWord: currentWord,
                              meanings: meanings,
                              getToNextPage: getToNextPage,
                              handleAnswer: handleAnswer,
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
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "D: $correctCount",
                              textAlign: TextAlign.center,
                              style: correctTextStyle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Y: $wrongCount",
                              textAlign: TextAlign.center,
                              style: wrongTextStyle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "B: $emptyCount",
                              textAlign: TextAlign.center,
                              style: emptyTextStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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

class WordTestPage extends StatefulWidget {
  const WordTestPage({
    super.key,
    required this.currentWord,
    required this.meanings,
    required this.getToNextPage,
    required this.handleAnswer,
  });

  final Word currentWord;
  final List<String> meanings;
  final void Function() getToNextPage;
  final void Function(bool) handleAnswer;

  @override
  State<WordTestPage> createState() => WordTestPageState();
}

class WordTestPageState extends State<WordTestPage> {
  final List<String> options = [];
  List<Widget> optionWidgets = [];
  bool isAnsweredCorrectly = false;

  Future<void> createOptions() async {
    options.add(widget.currentWord.meaning);

    final otherOptions = widget.meanings
      ..sublist(0)
      ..remove(widget.currentWord.meaning)
      ..shuffle();

    for (int i = 0; i < otherOptions.length; i++) {
      options.add(otherOptions[i]);
      if (options.length == 4) break;
    }

    while (options.length < 4) {
      final randomWord = await SqlDatabase.getRandomWord();
      final randomMeaning = randomWord.meaning;
      if (!options.contains(randomMeaning)) {
        options.add(randomMeaning);
      }
    }

    options.shuffle();

    optionWidgets = [
      for (String option in options)
        Builder(builder: (context) {
          OptionStatus status = OptionStatus.normal;
          return StatefulBuilder(
            builder: (context, setWidgetState) {
              return GestureDetector(
                onTap: () {
                  if (isAnsweredCorrectly) return;

                  final newStatus = optionTapHandler(option);
                  setWidgetState(() {
                    status = newStatus;
                    widget.handleAnswer(newStatus == OptionStatus.correct);
                    if (newStatus == OptionStatus.wrong) {
                      Timer(MyDurations.millisecond500, () {
                        setWidgetState(() {
                          status = OptionStatus.normal;
                        });
                      });
                    } else {
                      setState(() {
                        isAnsweredCorrectly = true;
                      });
                      widget.getToNextPage();
                    }
                  });
                },
                child: WordTestOption(option: option, status: status),
              );
            },
          );
        }),
    ];

    if (mounted) {
      setState(() {});
    }
  }

  OptionStatus optionTapHandler(String option) {
    if (option == widget.currentWord.meaning) {
      return OptionStatus.correct;
    }
    return OptionStatus.wrong;
  }

  @override
  void initState() {
    createOptions();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          margin: const EdgeInsets.all(8),
          constraints: const BoxConstraints(maxWidth: 240),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(12)),
            boxShadow: [BoxShadow(blurRadius: 4, color: MyColors.darkBlue)],
          ),
          child: Text(
            widget.currentWord.word,
            textAlign: TextAlign.center,
            style: MyTextStyles.font_28_36_600,
          ),
        ),
        Flexible(
          child: CustomScrollView(
            shrinkWrap: true,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(8),
                sliver: SliverList.separated(
                  itemCount: optionWidgets.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => optionWidgets[index],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum OptionStatus {
  normal,
  correct,
  wrong,
}

class WordTestOption extends StatefulWidget {
  const WordTestOption({
    super.key,
    required this.option,
    required this.status,
  });

  final String option;
  final OptionStatus status;

  @override
  State<WordTestOption> createState() => WordTestOptionState();
}

class WordTestOptionState extends State<WordTestOption> {
  late OptionStatus status = widget.status;

  final shadowColors = const {
    OptionStatus.normal: Colors.black26,
    OptionStatus.correct: MyColors.green,
    OptionStatus.wrong: MyColors.red,
  };

  final textColors = const {
    OptionStatus.normal: Colors.black,
    OptionStatus.correct: MyColors.green,
    OptionStatus.wrong: MyColors.red,
  };

  @override
  void didUpdateWidget(covariant WordTestOption oldWidget) {
    setState(() {
      status = widget.status;
    });

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(blurRadius: 2, color: shadowColors[status]!)],
      ),
      child: Text(
        widget.option,
        style: MyTextStyles.font_16_24_500.apply(color: textColors[status]),
      ),
    );
  }
}
