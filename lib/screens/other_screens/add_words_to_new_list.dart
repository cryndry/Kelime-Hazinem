import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/app_bars/app_bar.dart';
import 'package:kelime_hazinem/screens/main_screen/all_words.dart';

class AddWordsToNewList extends StatelessWidget {
  const AddWordsToNewList({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(
        appBar: MyAppBar(title: "Tüm Kelimeler"),
        body: AllWords(hideFAB: true),
      ),
    );
  }
}
