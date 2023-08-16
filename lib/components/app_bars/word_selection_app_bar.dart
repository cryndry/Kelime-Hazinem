import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelime_hazinem/components/sheets_and_dialogs/add_word_to_lists.dart';
import 'package:kelime_hazinem/components/sheets_and_dialogs/add_words_to_lists.dart';
import 'package:kelime_hazinem/components/buttons/icon.dart';
import 'package:kelime_hazinem/utils/analytics.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';
import 'package:kelime_hazinem/utils/navigation_observer.dart';
import 'package:kelime_hazinem/utils/providers.dart';

class WordSelectionAppBar extends ConsumerStatefulWidget {
  const WordSelectionAppBar({super.key});

  @override
  WordSelectionAppBarState createState() => WordSelectionAppBarState();
}

class WordSelectionAppBarState extends ConsumerState<WordSelectionAppBar> {
  void deactivateShareMode() {
    final isUsedInListCreateMode = MyNavigatorObserver.stack.first == "AddWordsToNewList";
    if (isUsedInListCreateMode) Navigator.of(context).pop();
    deactivateWordSelectionMode(ref);
  }

  @override
  Widget build(BuildContext context) {
    final selectedWords = ref.watch(selectedWordsProvider);
    final activeTabIndex = ref.watch(activeTabIndexProvider);
    final isUsedInListCreateMode = MyNavigatorObserver.stack.first == "AddWordsToNewList";
    final isUsedInAllWordsOfListPage = MyNavigatorObserver.stack.first == "AllWordsOfList";

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!(activeTabIndex == 2 || isUsedInListCreateMode || isUsedInAllWordsOfListPage)) {
        deactivateWordSelectionMode(ref);
      }
    });

    return WillPopScope(
      onWillPop: () async {
        if (getIsWordSelectionModeActive(ref)) {
          deactivateWordSelectionMode(ref);
          return false;
        }
        return true;
      },
      child: Row(
        children: [
          ActionButton(
            icon: MySvgs.clearText,
            size: 40,
            semanticsLabel: "Seçimleri İptal Et",
            onTap: deactivateShareMode,
          ),
          const SizedBox(width: 12),
          Text(
            '${selectedWords.length.toString()} Kelime Seçildi',
            style: MyTextStyles.font_24_32_500.apply(color: Colors.white),
          ),
          const Spacer(),
          if (selectedWords.isNotEmpty && !isUsedInListCreateMode)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionButton(
                icon: MySvgs.delete,
                size: 32,
                semanticsLabel: "${selectedWords.length == 1 ? "Kelimeyi" : "Kelimeleri"} Sil",
                onTap: () {
                  ref.read(allWordsProvider.notifier).update((state) {
                    final newState = [...state];
                    newState.removeWhere((word) {
                      final bool result = selectedWords.contains(word.id);
                      if (result) {
                        SqlDatabase.deleteWord(word.id);
                        Analytics.logWordAction(word: word.word, action: "word_deleted");
                      }
                      return result;
                    });

                    return newState;
                  });

                  ref.read(allWordsOfListProvider.notifier).update((state) {
                    if (state.isEmpty) return state;

                    final newState = [...state];
                    newState.removeWhere((word) => selectedWords.contains(word.id));

                    return newState;
                  });

                  deactivateWordSelectionMode(ref);
                },
              ),
            ),
          if (selectedWords.isNotEmpty && !isUsedInListCreateMode)
            ActionButton(
              icon: MySvgs.add2List,
              size: 32,
              semanticsLabel: "Seçili Kelimeleri Listelere Ekle",
              onTap: () async {
                if (selectedWords.length == 1) {
                  await addWordToLists(context: context, wordId: selectedWords.first);
                } else {
                  await addWordsToLists(context: context, wordIds: selectedWords);
                }
                deactivateWordSelectionMode(ref);
              },
            ),
          if (selectedWords.isNotEmpty && isUsedInListCreateMode)
            ActionButton(
              icon: MySvgs.save,
              size: 32,
              semanticsLabel: "Seçili Kelimeleri Yeni Listeye Ekle",
              onTap: () async {
                final newCreatedListName = ref.read(newCreatedListNameProvider);
                for (int wordId in selectedWords) {
                  // not working right
                  final listsData = await SqlDatabase.getListsOfWord(wordId);
                  listsData[newCreatedListName]!["is_word_in_list"] = true;
                  await SqlDatabase.changeListsOfWord(wordId, listsData);
                }

                deactivateWordSelectionMode(ref);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }
}
