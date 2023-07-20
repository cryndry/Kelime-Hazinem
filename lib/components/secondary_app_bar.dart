import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelime_hazinem/components/bottom_sheet.dart';
import 'package:kelime_hazinem/components/fill_colored_button.dart';
import 'package:kelime_hazinem/components/icon.dart';
import 'package:kelime_hazinem/components/text_input.dart';
import 'package:kelime_hazinem/utils/colors_text_styles_patterns.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';
import 'package:kelime_hazinem/utils/providers.dart';

class SecondaryAppBar extends ConsumerStatefulWidget {
  const SecondaryAppBar({super.key});

  @override
  SecondaryAppBarState createState() => SecondaryAppBarState();
}

class SecondaryAppBarState extends ConsumerState {
  final _formKey = GlobalKey<FormState>();
  final listRenameTextInputController = TextEditingController();
  Future<bool>? renamingList;
  String? errorMessage;

  @override
  void dispose() {
    listRenameTextInputController.dispose();

    super.dispose();
  }

  Future<bool> renameList(String listName, String newName) async {
    if (newName.trim().length < 2) {
      setState(() {
        errorMessage = "Liste adı en az iki karakterden oluşmalıdır.";
      });
      return false;
    }

    await Future.delayed(const Duration(seconds: 1));

    final doesListExist = await SqlDatabase.checkIfListExists(newName);
    if (doesListExist) {
      setState(() {
        errorMessage = "Bu isimde bir liste zaten var.";
      });
      return false;
    }

    setState(() {
      errorMessage = null;
    });

    await SqlDatabase.renameList(listName, newName);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final selectedLists = ref.watch(selectedListsProvider);

    return WillPopScope(
      onWillPop: () async {
        if (getIsSelectionModeActive(ref)) {
          deactivateSelectionMode(ref);
          return false;
        }
        return true;
      },
      child: Container(
        constraints: const BoxConstraints.tightFor(height: 64),
        color: MyColors.darkBlue,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            ActionButton(
              icon: MySvgs.clearText,
              size: 40,
              onTap: () {
                deactivateSelectionMode(ref);
              },
            ),
            const SizedBox(width: 12),
            Text(
              '${selectedLists.length.toString()} Liste Seçildi',
              style: MyTextStyles.font_24_32_500.apply(color: Colors.white),
            ),
            const Spacer(),
            if (selectedLists.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionButton(
                  icon: MySvgs.delete,
                  size: 32,
                  onTap: () {
                    ref.read(myListsProvider.notifier).update((state) {
                      final newState = [...state];

                      for (String listName in selectedLists) {
                        SqlDatabase.deleteList(listName);
                        newState.remove(listName);
                      }

                      return newState;
                    });

                    deactivateSelectionMode(ref);
                  },
                ),
              ),
            if (selectedLists.length == 1)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionButton(
                  icon: MySvgs.edit,
                  size: 32,
                  onTap: () async {
                    String listName = selectedLists.first;
                    listRenameTextInputController.text = listName;

                    await popBottomSheet(
                      context: context,
                      title: "Listeni Yeniden Adlandır",
                      routeName: "RenameListBottomSheet",
                      mayKeyboardAppear: true,
                      onSheetDismissed: () {
                        setState(() {
                          errorMessage = null;
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
                                hintText: listName,
                                autoFocus: true,
                                keyboardAction: TextInputAction.done,
                                errormessage: errorMessage,
                                loseFocusOnTapOutside: false,
                                textInputController: listRenameTextInputController,
                              ),
                              const SizedBox(height: 16),
                              FutureBuilder(
                                future: renamingList,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting ||
                                      snapshot.connectionState == ConnectionState.active) {
                                    return FillColoredButton(
                                      title: "Kaydediliyor",
                                      icon: const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 3,
                                          semanticsLabel: "Kaydediliyor...",
                                        ),
                                      ),
                                      onPressed: () {},
                                    );
                                  }
                                  return FillColoredButton(
                                      title: "Kaydet",
                                      onPressed: () {
                                        final String newName = listRenameTextInputController.text;
                                        setState(() {
                                          setSheetState(() {
                                            errorMessage = null;
                                          });
                                          renamingList = renameList(listName, newName);
                                          setSheetState(() {});
                                        });

                                        renamingList!.then((value) {
                                          setSheetState(() {});
                                          if (!value) return value;

                                          ref.read(myListsProvider.notifier).update((state) {
                                            final newState = [...state];
                                            final listIndex = newState.indexOf(listName);
                                            newState[listIndex] = newName;
                                            return newState;
                                          });

                                          listName = newName;
                                          deactivateSelectionMode(ref);
                                          Navigator.of(context).pop();
                                          return value;
                                        });
                                      });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );

                    listRenameTextInputController.text = listName;
                  },
                ),
              ),
            if (selectedLists.isNotEmpty)
              ActionButton(
                icon: MySvgs.share,
                size: 32,
                onTap: () {},
              ),
          ],
        ),
      ),
    );
  }
}
