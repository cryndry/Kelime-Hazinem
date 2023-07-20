import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelime_hazinem/components/bottom_sheet.dart';
import 'package:kelime_hazinem/components/fab.dart';
import 'package:kelime_hazinem/components/fill_colored_button.dart';
import 'package:kelime_hazinem/components/list_card.dart';
import 'package:kelime_hazinem/components/list_card_grid.dart';
import 'package:kelime_hazinem/components/page_layout.dart';
import 'package:kelime_hazinem/components/text_input.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';
import 'package:kelime_hazinem/utils/providers.dart';

class MyLists extends ConsumerStatefulWidget {
  const MyLists({super.key});

  @override
  ConsumerState<MyLists> createState() => MyListsState();
}

class MyListsState extends ConsumerState<MyLists> {
  final _formKey = GlobalKey<FormState>();
  final listAddingTextInputController = TextEditingController();
  Future<bool>? creatingList;

  @override
  void initState() {
    SqlDatabase.getLists().then((result) {
      result.remove("Temel Seviye");
      result.remove("Orta Seviye");
      result.remove("İleri Seviye");

      ref.read(myListsProvider.notifier).update((state) => result);
    });

    super.initState();
  }

  @override
  void dispose() {
    listAddingTextInputController.dispose();

    super.dispose();
  }

  String? inputValidator(String? value) {
    if (value == null || (value.trim().length < 2)) {
      return 'Liste adı en az iki karakterden oluşmalıdır.';
    }
    return null;
  }

  Future<bool> createList(String listName) async {
    final validationResult = _formKey.currentState!.validate();
    if (!validationResult) return false;

    await Future.delayed(
      const Duration(seconds: 1),
      () async => await SqlDatabase.createList(listName),
    );

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final lists = ref.watch(myListsProvider);
    final isSelectionModeActive = ref.watch(isSelectionModeActiveProvider);

    return PageLayout(
      FABs: isSelectionModeActive
          ? null
          : [
              FAB(
                  icon: MySvgs.cloud,
                  onTap: () {
                    Navigator.of(context).pushNamed("ShareLists");
                  }),
              const SizedBox(height: 12),
              FAB(
                  icon: MySvgs.plus,
                  onTap: () async {
                    await popBottomSheet(
                      context: context,
                      title: "Yeni Listeni Oluştur",
                      routeName: "CreateListBottomSheet",
                      mayKeyboardAppear: true,
                      bottomWidgets: (setSheetState) => [
                        Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              MyTextInput(
                                label: "Liste",
                                hintText: "Yeni Listem",
                                autoFocus: true,
                                keyboardAction: TextInputAction.done,
                                validator: inputValidator,
                                loseFocusOnTapOutside: false,
                                textInputController: listAddingTextInputController,
                              ),
                              const SizedBox(height: 16),
                              FutureBuilder(
                                future: creatingList,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting ||
                                      snapshot.connectionState == ConnectionState.active) {
                                    return FillColoredButton(
                                      title: "Oluşturuluyor",
                                      icon: const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 3,
                                          semanticsLabel: "Oluşturuluyor...",
                                        ),
                                      ),
                                      onPressed: () {},
                                    );
                                  }
                                  return FillColoredButton(
                                      title: "Oluştur",
                                      onPressed: () {
                                        setSheetState(() {
                                          final String listName = listAddingTextInputController.text;
                                          creatingList = createList(listName).then((value) {
                                            if (!value) return value;

                                            ref.read(myListsProvider.notifier).update((state) => [...state, listName]);
                                            Navigator.of(context).pop();
                                            return value;
                                          });
                                        });
                                      });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                    listAddingTextInputController.clear();
                  }),
            ],
      children: [
        ListCardGrid(
          children: lists.map<ListCard>((e) => ListCard(title: e)).toList(),
        ),
      ],
    );
  }
}
