import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/word_db_model.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';

final isListSelectionModeActiveProvider = StateProvider((ref) => false);
final isWordSelectionModeActiveProvider = StateProvider((ref) => false);
final selectedListsProvider = StateProvider((ref) => <String>[]);
final selectedWordsProvider = StateProvider((ref) => <int>[]);
final myListsProvider = StateProvider((ref) => <String>[]);
final newCreatedListNameProvider = StateProvider((ref) => "");
final activeTabIndexProvider = StateProvider((ref) => KeyValueDatabase.getFirstTabIndex());
final allWordsProvider = StateProvider((ref) => <Word>[]);
final allWordsOfListProvider = StateProvider((ref) => <Word>[]);
final observingStrategyProvider = Provider<InternetObservingStrategy>(
  (ref) => DefaultObServingStrategy(timeOut: const Duration(seconds: 5)),
);
final internetConnectivityProvider = Provider<InternetConnectivity>(
  (ref) => InternetConnectivity(internetObservingStrategy: ref.watch(observingStrategyProvider)),
);

void activateListSelectionMode(WidgetRef ref) {
  ref.read(isListSelectionModeActiveProvider.notifier).update((state) => true);
  ref.read(selectedListsProvider.notifier).update((state) => []);
}

void deactivateListSelectionMode(WidgetRef ref) {
  ref.read(isListSelectionModeActiveProvider.notifier).update((state) => false);
  ref.read(selectedListsProvider.notifier).update((state) => []);
}

void activateWordSelectionMode(WidgetRef ref) {
  ref.read(isWordSelectionModeActiveProvider.notifier).update((state) => true);
  ref.read(selectedWordsProvider.notifier).update((state) => []);
}

void deactivateWordSelectionMode(WidgetRef ref) {
  ref.read(isWordSelectionModeActiveProvider.notifier).update((state) => false);
  ref.read(selectedWordsProvider.notifier).update((state) => []);
}

bool getIsListSelectionModeActive(WidgetRef ref) {
  return ref.read(isListSelectionModeActiveProvider);
}

bool getIsWordSelectionModeActive(WidgetRef ref) {
  return ref.read(isWordSelectionModeActiveProvider);
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

bool updateSelectedWords(WidgetRef ref, int wordId) {
  final selectedWords = ref.read(selectedWordsProvider.notifier).update((state) {
    final newState = [...state];
    if (newState.contains(wordId)) {
      newState.remove(wordId);
    } else {
      newState.add(wordId);
    }
    return newState;
  });

  bool isSelectedNow = selectedWords.contains(wordId);
  return isSelectedNow;
}
