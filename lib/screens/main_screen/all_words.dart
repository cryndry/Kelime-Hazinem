import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/fab.dart';
import 'package:kelime_hazinem/components/all_words_page_layout.dart';
import 'package:kelime_hazinem/components/route_animator.dart';
import 'package:kelime_hazinem/screens/word_screen/word_add.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';
import 'package:kelime_hazinem/utils/word_db_model.dart';

class AllWords extends StatefulWidget {
  const AllWords({super.key});

  @override
  State<AllWords> createState() => _AllWordsState();
}

class _AllWordsState extends State<AllWords> {
  List<Word> words = [];

  @override
  void initState() {
    SqlDatabase.getAllWords().then((result) {
      setState(() {
        words = result;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AllWordsPageLayout(
      words: words,
      FABs: [
        FAB(
          icon: MySvgs.plus,
          semanticsLabel: "Yeni Kelime Ekle",
          onTap: () {
            Navigator.of(context).push(routeAnimator(page: const WordAdd()));
          },
        ),
      ],
    );
  }
}
