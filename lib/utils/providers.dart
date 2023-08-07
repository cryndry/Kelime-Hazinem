import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/word_db_model.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';

final isSelectionModeActiveProvider = StateProvider((ref) => false);
final selectedListsProvider = StateProvider((ref) => <String>[]);
final myListsProvider = StateProvider((ref) => <String>[]);
final activeTabIndexProvider = StateProvider((ref) => KeyValueDatabase.getFirstTabIndex());
final allWordsProvider = StateProvider((ref) => <Word>[]);
final allWordsOfListProvider = StateProvider((ref) => <Word>[]);
final observingStrategyProvider = Provider<InternetObservingStrategy>(
  (ref) => DefaultObServingStrategy(timeOut: const Duration(seconds: 5)),
);
final internetConnectivityProvider = Provider<InternetConnectivity>(
  (ref) => InternetConnectivity(internetObservingStrategy: ref.watch(observingStrategyProvider)),
);

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
