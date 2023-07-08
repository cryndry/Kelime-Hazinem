import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/all_words_page_layout.dart';
import 'package:kelime_hazinem/components/app_bar.dart';
import 'package:kelime_hazinem/components/icon.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';
import 'package:kelime_hazinem/utils/word_db_model.dart';

class AllWordsOfList extends StatefulWidget {
  const AllWordsOfList({
    super.key,
    required this.listName,
    required this.dbTitle,
  });

  final String listName;
  final String dbTitle;

  @override
  State<AllWordsOfList> createState() => _AllWordsOfListState();
}

class _AllWordsOfListState extends State<AllWordsOfList> {
  List<Word> words = [];

  @override
  void initState() {
    SqlDatabase.getWordsQuery(
      listName: widget.dbTitle,
      isIconicList: widget.dbTitle != widget.listName,
      isInRandomOrder: false,
    ).then((value) {
      setState(() {
        words = value;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(
          title: "Tüm Kelimeler",
          secTitle: widget.listName,
          buttons: const [
            ActionButton(icon: MySvgs.search, size: 32),
          ],
        ),
        body: AllWordsPageLayout(words: words),
      ),
    );
  }
}
