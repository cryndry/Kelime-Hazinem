import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/word_db_model.dart';

final isSelectionModeActiveProvider = StateProvider((ref) => false);
final selectedListsProvider = StateProvider((ref) => <String>[]);
final myListsProvider = StateProvider((ref) => <String>[]);
final activeTabIndexProvider = StateProvider((ref) => KeyValueDatabase.getFirstTabIndex());
final allWordsProvider = StateProvider((ref) => <Word>[]);
final allWordsOfListProvider = StateProvider((ref) => <Word>[]);

void activateSelectionMode(WidgetRef ref) {
  ref.read(isSelectionModeActiveProvider.notifier).update((state) => true);
}

void deactivateSelectionMode(WidgetRef ref) {
  ref.read(isSelectionModeActiveProvider.notifier).update((state) => false);
  ref.read(selectedListsProvider.notifier).update((state) => []);
}

bool getIsSelectionModeActive(WidgetRef ref) {
  return ref.read(isSelectionModeActiveProvider);
}

bool updateSelectedLists(WidgetRef ref, String listName) {
  final selectedLists = ref.read(selectedListsProvider.notifier).update((state) {
    final newState = [...state];
    if (newState.contains(listName)) {
      newState.remove(listName);
    } else {
      newState.add(listName);
    }
    return newState;
  });

  bool isInListAfterUpdate = selectedLists.contains(listName);
  return isInListAfterUpdate;
}
