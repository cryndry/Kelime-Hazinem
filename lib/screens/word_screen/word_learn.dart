import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/app_bar.dart';
import 'package:kelime_hazinem/components/nonscrollable_page_layout.dart';
import 'package:kelime_hazinem/components/word_action_button_row.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/word_db_model.dart';

class WordLearn extends StatefulWidget {
  const WordLearn({super.key, required this.listName});

  final String listName;

  @override
  State<WordLearn> createState() => _WordLearnState();
}

class _WordLearnState extends State<WordLearn> {
  int currentPage = 0;
  final int listLength = SharedPreferencesDatabase.db.getInt("wordLearnListLength")!;
  final PageController pageController = PageController();
  final TextEditingController textEditingController = TextEditingController(text: "1");
  final counterTextStyle = const TextStyle(
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w500,
  );

  List<Word> words = [];

  int intBoolInvert(int value) => (value == 1) ? 0 : 1;
  bool intAsBool(int value) => (value == 1);

  void handleSetState(Function() callback) {
    setState(() {
      callback();
    });
  }

  @override
  void initState() {
    SqlDatabase.getWordsQuery(listLength, "willLearn").then((result) {
      setState(() {
        words = result;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(title: "Kelime Öğrenme", secTitle: widget.listName),
        body: Stack(
          alignment: Alignment.center,
          children: [
            NonScrollablePageLayout(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color.fromRGBO(0, 122, 255, 0.7),
                    width: 2,
                  ),
                ),
                child: PageView.custom(
                  controller: pageController,
                  scrollDirection: Axis.horizontal,
                  childrenDelegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final Word currentWord = words[index];
                      return Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                currentWord.word,
                                style: const TextStyle(
                                  fontSize: 28,
                                  height: 36 / 28,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (currentWord.description != null) const SizedBox(height: 8),
                              if (currentWord.description != null)
                                Text(
                                  currentWord.description!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 20 / 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromRGBO(0, 0, 0, 0.6),
                                  ),
                                ),
                              const SizedBox(height: 64),
                              Text(
                                currentWord.meaning.replaceAll(RegExp(r"(\|)"), ", "),
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
                    style: counterTextStyle,
                    autocorrect: false,
                    keyboardType: TextInputType.number,
                    controller: textEditingController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      suffixText: " / $listLength",
                      suffixStyle: counterTextStyle,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
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
