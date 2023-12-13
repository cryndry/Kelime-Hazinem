import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelime_hazinem/components/layouts/all_words_page_layout.dart';
import 'package:kelime_hazinem/components/app_bars/app_bar.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/providers.dart';

class AllWordsOfList extends ConsumerStatefulWidget {
  const AllWordsOfList({
    super.key,
    required this.listName,
    required this.dbTitle,
  });

  final String listName;
  final String dbTitle;

  @override
  AllWordsOfListState createState() => AllWordsOfListState();
}

class AllWordsOfListState extends ConsumerState<AllWordsOfList> {
  @override
  void initState() {
    SqlDatabase.getWordsQuery(
      listName: widget.dbTitle,
      isIconicList: widget.dbTitle != widget.listName,
      isInRandomOrder: false,
      toStudy: false,
    ).then((result) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        ref.read(allWordsOfListProvider.notifier).update((state) => result);
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final words = ref.watch(allWordsOfListProvider);

    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(
          title: "Tüm Kelimeler",
          secTitle: widget.listName,
        ),
        body: AllWordsPageLayout(
          words: words,
          type: "AllWordsOfList",
        ),
      ),
    );
  }
}
