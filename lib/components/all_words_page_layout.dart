import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/text_input.dart';
import 'package:kelime_hazinem/components/word_card.dart';
import 'package:kelime_hazinem/screens/settings.dart';
import 'package:kelime_hazinem/utils/word_db_model.dart';

class AllWordsPageLayout extends StatefulWidget {
  const AllWordsPageLayout({super.key, required this.words, this.FABs});

  final List<Word> words;
  final List<Widget>? FABs;

  @override
  State<AllWordsPageLayout> createState() => AllWordsPageLayoutState();
}

class AllWordsPageLayoutState extends State<AllWordsPageLayout> {
  final TextEditingController textInputController = TextEditingController();
  final FocusNode textInputFocusNode = FocusNode();
  List<Word> words = [];
  Timer? searchTimer;
  String searchMode = "Kelimede";

  @override
  void didUpdateWidget(covariant AllWordsPageLayout oldWidget) {
    if (oldWidget.words.isEmpty && widget.words.isNotEmpty) {
      setState(() {
        words = widget.words;
      });
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    textInputController.addListener(() {
      onChangeSearchText(textInputController.text);
    });

    super.initState();
  }

  @override
  void dispose() {
    textInputController.dispose();
    textInputFocusNode.dispose();
    
    super.dispose();
  }

  void onChangeSearchText(String searchText) {
    String searchText = textInputController.text;
    if (searchText.isEmpty) {
      setState(() {
        words = widget.words;
      });
    } else {
      if (searchTimer != null) {
        searchTimer!.cancel();
        searchTimer = null;
      }
      searchTimer = Timer(
        const Duration(milliseconds: 500),
        () {
          setState(() {
            List<Word> searchedWords;
            if (searchMode == "Kelimede") {
              searchedWords = widget.words.where((element) => element.wordSearch.contains(searchText)).toList();
              searchedWords
                  .sort((a, b) => a.wordSearch.indexOf(searchText).compareTo(b.wordSearch.indexOf(searchText)));
            } else {
              final searchedWordsWithMeaning = <Word>[];
              final searchTextNotExact = searchText.trim();
              final searchTextExact = "$searchTextNotExact,";

              final queryExact = widget.words.where((element) => element.meaning.contains(searchTextExact)).toList();
              queryExact.sort((a, b) => a.meaning.indexOf(searchTextExact).compareTo(b.meaning.indexOf(searchTextExact)));
              searchedWordsWithMeaning.addAll(queryExact);

              final queryNotExact = widget.words.where((element) => element.meaning.contains(searchTextNotExact)).toList();
              queryNotExact.sort((a, b) => a.meaning.indexOf(searchTextNotExact).compareTo(b.meaning.indexOf(searchTextNotExact)));
              for (Word word in queryNotExact) {
                if (!queryExact.contains(word)) {
                  searchedWordsWithMeaning.add(word);
                }
              }

              searchedWords = searchedWordsWithMeaning;
            }
            words = searchedWords;
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SelectableSetting<String>(
                      values: const {
                        "Kelimede": "Kelimede",
                        "Anlamda": "Anlamda",
                      },
                      initialValue: "Kelimede",
                      onChange: (value) {
                        setState(() {
                          searchMode = value;
                          textInputController.clear();
                          textInputFocusNode.requestFocus();
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: MyTextInput(
                        label: "$searchMode Ara",
                        hintText: "",
                        formatArabic: searchMode == "Kelimede",
                        keyboardAction: TextInputAction.done,
                        textInputController: textInputController,
                        focusNode: textInputFocusNode,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList.separated(
                itemBuilder: (context, index) => WordCard(key: ValueKey(words[index].id), word: words[index]),
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemCount: words.length,
              ),
            )
          ],
        ),
        if (widget.FABs != null)
          Positioned(
            bottom: 48,
            right: 16,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                children: widget.FABs!,
              ),
            ),
          ),
      ],
    );
  }
}
