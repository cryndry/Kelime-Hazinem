import 'dart:math' show Random;
import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/sheets_and_dialogs/add_word_to_lists.dart';
import 'package:kelime_hazinem/components/app_bars/app_bar.dart';
import 'package:kelime_hazinem/components/buttons/icon.dart';
import 'package:kelime_hazinem/components/others/keep_alive_widget.dart';
import 'package:kelime_hazinem/components/layouts/nonscrollable_page_layout.dart';
import 'package:kelime_hazinem/components/sheets_and_dialogs/share_word.dart';
import 'package:kelime_hazinem/components/words_and_lists/word_action_button_row.dart';
import 'package:kelime_hazinem/utils/admob.dart';
import 'package:kelime_hazinem/utils/analytics.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';
import 'package:kelime_hazinem/utils/word_db_model.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';

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

  List<Word> words = [];
  List<ActionButton> appBarButtons = [];
  bool isListRefreshed = false;

  late final List<ActionButton> constAppBarButtons = [
    ActionButton(
      icon: MySvgs.add2List,
      size: 32,
      semanticsLabel: "Listelere Ekle",
      onTap: () {
        addWordToLists(context: context, wordId: words[pageController.page!.toInt()].id);
      },
    ),
    ActionButton(
      icon: MySvgs.edit,
      size: 32,
      semanticsLabel: "Düzenle",
      onTap: () async {
        final int wordIndex = pageController.page!.toInt();
        final result = await Navigator.of(context).pushNamed(
          "WordEdit",
          arguments: {"word": words[wordIndex]},
        );
        setState(() {
          if (result != null && (result as Map)["deleted"]) {
            words.removeAt(wordIndex);
            if (words.isEmpty) Navigator.of(context).pop();
            if (wordIndex == words.length) {
              textEditingController.text = wordIndex.toString();
            }
          }
        });
      },
    ),
    ActionButton(
      icon: MySvgs.share,
      size: 32,
      semanticsLabel: "Kelimeyi Paylaş",
      onTap: () {
        shareWord(context: context, word: words[pageController.page!.toInt()]);
      },
    ),
  ];

  void handleSetState(Function() callback) {
    setState(() {
      callback();
    });
  }

  void animateToPageHandler() {
    textInputFocus.unfocus();

    int currentValue = int.parse(textEditingController.text);
    if (currentValue > 0 && currentValue <= words.length) {
      final bool isAnimatable = KeyValueDatabase.getIsAnimatable();

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

  void refreshList() async {
    Analytics.logLearnModeAction(mode: "word_learn", listName: widget.listName, action: "refresh_button_used");
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
      appBarButtons = [...constAppBarButtons];
      pageController.jumpToPage(0);
      isListRefreshed = true;
    });
  }

  @override
  void initState() {
    AdMob.loadBannerAd().then((_) {
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
    });

    appBarButtons = [...constAppBarButtons];

    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    textEditingController.dispose();
    textInputFocus.dispose();
    AdMob.disposeBannerAd();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(title: "Kelime Öğrenme", secTitle: widget.listName, buttons: appBarButtons),
        body: Column(
          children: [
            Flexible(
              child: Stack(
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
                          if (value + 1 == words.length && appBarButtons.length == constAppBarButtons.length) {
                            setState(() {
                              appBarButtons = [
                                ...constAppBarButtons,
                                ActionButton(
                                  icon: MySvgs.refresh,
                                  size: 32,
                                  semanticsLabel: "Yeni Sete Başla",
                                  onTap: refreshList,
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
                      color: Theme.of(context).scaffoldBackgroundColor,
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
            InternetConnectivityBuilder(
              child: SizedBox(height: 50, child: AdMob.bannerAdWidget),
              connectivityBuilder: (context, hasInternetAccess, child) => (hasInternetAccess) ? child! : const SizedBox.shrink(),
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
      style: MyTextStyles.font_28_36_600,
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
                style: MyTextStyles.font_16_20_500.merge(TextStyle(
                  color: Colors.black.withOpacity(0.6),
                )),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 64),
            child: Text(
              widget.currentWord.meaning,
              textAlign: TextAlign.center,
              style: MyTextStyles.font_20_24_500.merge(TextStyle(
                color: Colors.black.withOpacity(0.8),
              )),
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
                              duration: MyDurations.millisecond400,
                              child: wordWidget,
                            )
                          : wordWidget,
                      isAnimatable
                          ? AnimatedSize(
                              duration: MyDurations.millisecond400,
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
