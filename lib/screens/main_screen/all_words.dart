import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelime_hazinem/components/buttons/fab.dart';
import 'package:kelime_hazinem/components/layouts/all_words_page_layout.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';
import 'package:kelime_hazinem/utils/providers.dart';
import 'package:kelime_hazinem/utils/set_state_on_pop_next.dart';
import 'package:kelime_hazinem/utils/word_db_model.dart';

class AllWords extends ConsumerStatefulWidget {
  const AllWords({super.key});

  @override
  AllWordsState createState() => AllWordsState();
}

class AllWordsState extends ConsumerStateWithRefreshOnPopNext<AllWords> {
  List<Word> words = [];

  @override
  void initState() {
    if (words.isEmpty) {
      SqlDatabase.getAllWords().then((result) {
        ref.read(allWordsProvider.notifier).update((state) => result);
      });
    }

    ref.listenManual(allWordsProvider, (previous, next) {
      setState(() {
        words = next;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isWordSelectionModeActive = ref.watch(isWordSelectionModeActiveProvider);

    return AllWordsPageLayout(
      words: words,
      type: "AllWords",
      FABs: isWordSelectionModeActive
          ? null
          : [
              FAB(
                icon: MySvgs.plus,
                semanticsLabel: "Yeni Kelime Ekle",
                onTap: () async {
                  final result = await Navigator.of(context).pushNamed("WordAdd");
                  if (result is Map<String, dynamic>) {
                    ref.read(allWordsProvider.notifier).update((state) => [...state, Word.fromJson(result)]);
                  }
                },
              ),
            ],
    );
  }
}
