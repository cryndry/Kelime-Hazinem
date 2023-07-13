import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/text_input.dart';
import 'package:kelime_hazinem/components/word_card.dart';
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
  List<Word> words = [];
  Timer? searchTimer;

  @override
  void didUpdateWidget(covariant AllWordsPageLayout oldWidget) {
    if (oldWidget.words.isEmpty && widget.words.isNotEmpty) {
      setState(() {
        words = widget.words;
      });
    }

    super.didUpdateWidget(oldWidget);
  }

  void onChangeSearchText(String searchText) {
    String searchText = textInputController.text;
    if (searchText.isEmpty) {
      words = widget.words;
    } else {
      if (searchTimer != null) {
        searchTimer!.cancel();
        searchTimer = null;
      }
      searchTimer = Timer(
        const Duration(milliseconds: 500),
        () {
          setState(() {
            words = widget.words.where((element) => element.wordSearch.contains(searchText)).toList();
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
              padding: const EdgeInsets.only(top: 16, left: 20, right: 20),
              sliver: SliverToBoxAdapter(
                child: MyTextInput(
                  label: "Kelime Arama",
                  hintText: "",
                  formatArabic: true,
                  keyboardAction: TextInputAction.done,
                  textInputController: textInputController,
                  onChange: onChangeSearchText,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList.separated(
                itemBuilder: (context, index) => WordCard(word: words[index]),
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
