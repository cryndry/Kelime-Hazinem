import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelime_hazinem/components/sheets_and_dialogs/bottom_sheet.dart';
import 'package:kelime_hazinem/components/sheets_and_dialogs/dialog.dart';
import 'package:kelime_hazinem/components/buttons/fab.dart';
import 'package:kelime_hazinem/components/buttons/fill_colored_button.dart';
import 'package:kelime_hazinem/components/words_and_lists/list_card.dart';
import 'package:kelime_hazinem/components/layouts/list_card_grid.dart';
import 'package:kelime_hazinem/components/layouts/page_layout.dart';
import 'package:kelime_hazinem/components/others/text_input.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';
import 'package:kelime_hazinem/utils/navigation_observer.dart';
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
  String? errorMessage;
  final bool isUsedInListSharePage = MyNavigatorObserver.stack.first == "ShareMyLists";

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (isUsedInListSharePage) {
        activateListSelectionMode(ref);
      }
    });

    ref.listenManual(myListsProvider, (previous, next) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (next.isEmpty && isUsedInListSharePage) {
          deactivateListSelectionMode(ref);
          Navigator.of(context).pop();
        }
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    listAddingTextInputController.dispose();

    super.dispose();
  }

  Future<bool> createList(String listName) async {
    if (listName.trim().length < 2) {
      setState(() {
        errorMessage = "Liste adı en az iki karakterden oluşmalıdır.";
      });
      return false;
    }

    await Future.delayed(MyDurations.millisecond1000);

    final doesListExist = await SqlDatabase.checkIfListExists(listName);
    if (doesListExist) {
      setState(() {
        errorMessage = "Bu isimde bir liste zaten var.";
      });
      return false;
    }

    setState(() {
      errorMessage = null;
    });

    await SqlDatabase.createList(listName);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final lists = ref.watch(myListsProvider);
    final isListSelectionModeActive = ref.watch(isListSelectionModeActiveProvider);

    return PageLayout(
      FABs: (isListSelectionModeActive || isUsedInListSharePage)
          ? null
          : [
              FAB(
                icon: MySvgs.cloud,
                semanticsLabel: "Liste Paylaş",
                onTap: () {
                  Navigator.of(context).pushNamed("ShareLists");
                },
              ),
              const SizedBox(height: 12),
              FAB(
                icon: MySvgs.plus,
                semanticsLabel: "Yeni Liste Oluştur",
                onTap: () async {
                  final newListName = await popBottomSheet<String>(
                    context: context,
                    title: "Yeni Listeni Oluştur",
                    routeName: "CreateListBottomSheet",
                    mayKeyboardAppear: true,
                    onSheetDismissed: () {
                      setState(() {
                        errorMessage = null;
                        listAddingTextInputController.clear();
                      });
                    },
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
                              errormessage: errorMessage,
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
                                  );
                                }
                                return FillColoredButton(
                                  title: "Oluştur",
                                  onPressed: () {
                                    final String listName = listAddingTextInputController.text;
                                    setState(() {
                                      setSheetState(() {
                                        errorMessage = null;
                                      });
                                      creatingList = createList(listName);
                                      setSheetState(() {});
                                    });

                                    creatingList!.then((value) {
                                      setSheetState(() {});
                                      if (!value) return value;

                                      ref.read(myListsProvider.notifier).update((state) => [...state, listName]);
                                      Navigator.of(context).pop(listName);
                                      return value;
                                    });
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );

                  if (newListName == null) return;
                  final willAddWords = await popDialog<bool>(
                    context: context,
                    routeName: "AddWordsToNewListRequestDialog",
                    builder: (setDialogState) {
                      return [
                        const Text(
                          "İsterseniz yeni listenize tüm kelimeler arasından seçim yaparak yeni kelimeler ekleyebilirsiniz.",
                          style: MyTextStyles.font_16_24_500,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              child: const Text("Geri Dön"),
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                            ),
                            const SizedBox(width: 12),
                            TextButton(
                              child: const Text("Onayla"),
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                            ),
                          ],
                        ),
                      ];
                    },
                  );

                  if (willAddWords != true) return;
                  ref.read(isWordSelectionModeActiveProvider.notifier).update((state) => true);
                  ref.read(newCreatedListNameProvider.notifier).update((state) => newListName);
                  await Navigator.of(context).pushNamed("AddWordsToNewList");
                  ref.read(newCreatedListNameProvider.notifier).update((state) => "");
                },
              ),
            ],
      children: lists.isNotEmpty
          ? [
              ListCardGrid(
                children: lists.map<ListCard>((e) => ListCard(title: e)).toList(),
              ),
            ]
          : [
              Image.asset(
                "assets/sad_folder.png",
                filterQuality: FilterQuality.high,
                colorBlendMode: BlendMode.dstOver,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              const SizedBox(height: 24),
              const Text(
                "Hiç listen yok. Sağ alttan hemen yeni bir tane oluşturabilirsin.",
                style: MyTextStyles.font_20_24_500,
                textAlign: TextAlign.center,
              ),
            ],
    );
  }
}
