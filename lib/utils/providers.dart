import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelime_hazinem/components/secondary_app_bar.dart';
import 'package:kelime_hazinem/utils/database.dart';

final isSelectionModeActiveProvider = StateProvider((ref) => false);
final secondaryAppBarProvider = StateProvider<Widget?>((ref) => null);
final selectedListsProvider = StateProvider((ref) => <String>[]);
final myListsProvider = StateProvider((ref) => <String>[]);
final activeTabIndexProvider = StateProvider((ref) => KeyValueDatabase.getFirstTabIndex());

void activateSelectionMode(WidgetRef ref) {
  ref.read(isSelectionModeActiveProvider.notifier).update((state) => true);
  ref.read(secondaryAppBarProvider.notifier).update((state) => const SecondaryAppBar());
}

void deactivateSelectionMode(WidgetRef ref) {
  ref.read(isSelectionModeActiveProvider.notifier).update((state) => false);
  ref.read(secondaryAppBarProvider.notifier).update((state) => null);
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
