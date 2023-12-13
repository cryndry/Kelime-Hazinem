import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelime_hazinem/components/app_bars/app_bar.dart';
import 'package:kelime_hazinem/components/sheets_and_dialogs/add_word_to_lists.dart';
import 'package:kelime_hazinem/components/sheets_and_dialogs/add_words_to_lists.dart';
import 'package:kelime_hazinem/components/buttons/icon.dart';
import 'package:kelime_hazinem/components/sheets_and_dialogs/undo_snack_bar.dart';
import 'package:kelime_hazinem/main.dart';
import 'package:kelime_hazinem/utils/analytics.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';
import 'package:kelime_hazinem/utils/navigation_observer.dart';
import 'package:kelime_hazinem/utils/providers.dart';
import 'package:kelime_hazinem/utils/word_db_model.dart';

class WordSelectionAppBar extends ConsumerStatefulWidget {
  const WordSelectionAppBar({super.key});

  @override
  WordSelectionAppBarState createState() => WordSelectionAppBarState();
}

class WordSelectionAppBarState extends ConsumerState<WordSelectionAppBar> {
  void deleteWords(List<int> selectedWordIds) {
    final isUsedInAllWordsOfListPage = MyNavigatorObserver.stack.first == "AllWordsOfList";

    List<Word> Function(List<Word>) stateUpdater(
      Map<int, Word> willRemoveIndexes,
      List<MapEntry<int, Word>> willRemoveIndexesSorted,
    ) {
      return (state) {
        final newState = [...state];

        for (int index = 0; index < newState.length; index++) {
          final Word word = newState[index];
          if (selectedWordIds.contains(word.id)) {
            willRemoveIndexes[index] = word;
          }

          if (selectedWordIds.length == willRemoveIndexes.length) break;
        }

        willRemoveIndexesSorted.addAll(
          willRemoveIndexes.entries.toList()
            ..sort(
              (entry1, entry2) => entry2.key.compareTo(entry1.key),
            ),
        );

        for (MapEntry<int, Word> entry in willRemoveIndexesSorted) {
          newState.removeAt(entry.key);
        }

        return newState;
      };
    }

    final willRemoveIndexesAllWords = <int, Word>{};
    List<MapEntry<int, Word>> willRemoveIndexesSortedAllWords = [];
    ref.read(allWordsProvider.notifier).update(stateUpdater(
          willRemoveIndexesAllWords,
          willRemoveIndexesSortedAllWords,
        ));

    final willRemoveIndexesAllWordsOfList = <int, Word>{};
    List<MapEntry<int, Word>> willRemoveIndexesSortedAllWordsOfList = [];
    List<Word> remainedWordsInAllWordsOfListPage = [];
    if (isUsedInAllWordsOfListPage) {
      remainedWordsInAllWordsOfListPage = ref.read(allWordsOfListProvider.notifier).update(stateUpdater(
            willRemoveIndexesAllWordsOfList,
            willRemoveIndexesSortedAllWordsOfList,
          ));
    }

    deactivateWordSelectionMode(ref);
    // appBarRef is used, because ref of WordSelectionAppBarState is not accessible after above line executed.
    // because ref is actually context of Consumer(Stateful)Widget
    final appBarRef = context.findAncestorStateOfType<MyAppBarState>()!.ref;

    showUndoSnackBar(
      message: "${selectedWordIds.length == 1 ? "Kelime" : "Kelimeler"} kalıcı olarak silinecek.",
      duration: MyDurations.millisecond1000 * 5,
      undoCallback: () {
        appBarRef.read(allWordsProvider.notifier).update((state) {
          final newState = [...state];

          for (MapEntry<int, Word> entry in willRemoveIndexesSortedAllWords.reversed) {
            newState.insert(entry.key, entry.value);
          }

          return newState;
        });

        if (isUsedInAllWordsOfListPage) {
          appBarRef.read(allWordsOfListProvider.notifier).update((state) {
            final newState = [...state];

            for (MapEntry<int, Word> entry in willRemoveIndexesSortedAllWordsOfList.reversed) {
              newState.insert(entry.key, entry.value);
            }

            return newState;
          });
        }
      },
      noUndoCallback: () {
        for (MapEntry<int, Word> entry in willRemoveIndexesSortedAllWords) {
          final Word word = entry.value;
          SqlDatabase.deleteWord(word.id);
          Analytics.logWordAction(word: word.word, action: "word_deleted");
        }

        final isAllWordsOfListEmpty = remainedWordsInAllWordsOfListPage.isEmpty;
        if (MyNavigatorObserver.stack.first == "AllWordsOfList" && isAllWordsOfListEmpty) {
          Navigator.of(KelimeHazinem.navigatorKey.currentContext!).popUntil(ModalRoute.withName("MainScreen"));
        }
      },
    );
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

    return PopScope(
      canPop: isUsedInListCreateMode,
      onPopInvoked: (didPop) {
        deactivateWordSelectionMode(ref);
      },
      child: Row(
        children: [
          ActionButton(
            icon: MySvgs.clearText,
            size: 40,
            semanticsLabel: "Seçimleri İptal Et",
            onTap: () {
              if (isUsedInListCreateMode) {
                Navigator.of(context).pop();
              }
              deactivateWordSelectionMode(ref);
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 240),
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    '${selectedWords.length.toString()} Kelime Seçildi',
                    style: MyTextStyles.font_24_32_500.apply(color: Colors.white),
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (selectedWords.isNotEmpty && !isUsedInListCreateMode)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionButton(
                icon: MySvgs.delete,
                size: 32,
                semanticsLabel: "${selectedWords.length == 1 ? "Kelimeyi" : "Kelimeleri"} Sil",
                onTap: () {
                  deleteWords([...selectedWords]);
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

                Navigator.of(context).pop();
                deactivateWordSelectionMode(ref);
              },
            ),
        ],
      ),
    );
  }
}
