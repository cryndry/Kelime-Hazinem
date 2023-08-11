import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelime_hazinem/components/bottom_sheet.dart';
import 'package:kelime_hazinem/components/dialog.dart';
import 'package:kelime_hazinem/components/fill_colored_button.dart';
import 'package:kelime_hazinem/components/icon.dart';
import 'package:kelime_hazinem/components/text_input.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';
import 'package:kelime_hazinem/utils/navigation_observer.dart';
import 'package:kelime_hazinem/utils/providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ListSelectionAppBar extends ConsumerStatefulWidget {
  const ListSelectionAppBar({super.key});

  @override
  ListSelectionAppBarState createState() => ListSelectionAppBarState();
}

class ListSelectionAppBarState extends ConsumerState {
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

    await Future.delayed(MyDurations.millisecond500);

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

  void deactivateShareMode() {
    final isUsedInListSharePage = MyNavigatorObserver.stack.first == "ShareMyLists";
    if (isUsedInListSharePage) Navigator.of(context).pop();
    deactivateListSelectionMode(ref);
  }

  @override
  Widget build(BuildContext context) {
    final activeTabIndex = ref.watch(activeTabIndexProvider);
    final selectedLists = ref.watch(selectedListsProvider);
    final isUsedInListSharePage = MyNavigatorObserver.stack.first == "ShareMyLists";

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!(activeTabIndex == 1 || isUsedInListSharePage)) {
        deactivateListSelectionMode(ref);
      }
    });

    return WillPopScope(
      onWillPop: () async {
        if (getIsListSelectionModeActive(ref)) {
          deactivateListSelectionMode(ref);
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
            '${selectedLists.length.toString()} Liste Seçildi',
            style: MyTextStyles.font_24_32_500.apply(color: Colors.white),
          ),
          const Spacer(),
          if (selectedLists.isNotEmpty && !isUsedInListSharePage)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionButton(
                icon: MySvgs.delete,
                size: 32,
                semanticsLabel: "${selectedLists.length == 1 ? "Listeyi" : "Listeleri"} Sil",
                onTap: () {
                  ref.read(myListsProvider.notifier).update((state) {
                    final newState = [...state];

                    for (String listName in selectedLists) {
                      SqlDatabase.deleteList(listName);
                      newState.remove(listName);
                    }

                    return newState;
                  });

                  deactivateListSelectionMode(ref);
                },
              ),
            ),
          if (selectedLists.length == 1 && !isUsedInListSharePage)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionButton(
                icon: MySvgs.edit,
                size: 32,
                semanticsLabel: "Listeyi Yeniden Adlandır",
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
                                        deactivateListSelectionMode(ref);
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
              semanticsLabel: "${selectedLists.length == 1 ? "Listeyi" : "Listeleri"} Paylaş",
              onTap: () {
                popDialog(
                    context: context,
                    routeName: "ShareListsDialog",
                    onDialogDissmissed: deactivateShareMode,
                    builder: (setDialogState) {
                      Widget progressWidget(double progress) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Yükleniyor", style: MyTextStyles.font_16_20_500),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(value: progress, minHeight: 8, color: MyColors.darkBlue),
                          ],
                        );
                      }

                      Stream<Widget> uploadingStream() async* {
                        yield const Text("Liste verisi alınıyor...", style: MyTextStyles.font_16_20_500);
                        final cacheDbFile = await SqlDatabase.shareLists(selectedLists);
                        await Future.delayed(MyDurations.millisecond300);

                        yield const Text("Yükleme başlatılıyor", style: MyTextStyles.font_16_20_500);
                        final sharedFileId = await FirebaseDatabase.addSharedFileData({
                          "creation_time": Timestamp.now(),
                        });
                        await Future.delayed(MyDurations.millisecond300);

                        final uploadTask = FirebaseDatabase.uploadFile(cacheDbFile, sharedFileId);
                        final uploadStream = uploadTask.snapshotEvents;

                        double progress = 0;
                        yield progressWidget(progress);

                        await for (TaskSnapshot taskSnapshot in uploadStream) {
                          if (taskSnapshot.state == TaskState.running) {
                            progress = taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
                            yield progressWidget(progress);
                          } else if (taskSnapshot.state == TaskState.success) {
                            yield progressWidget(progress);
                            await Future.delayed(MyDurations.millisecond500);
                            Future<void>? clipboardActionFuture;

                            yield Column(
                              children: [
                                const Text(
                                  "Seçtiğiniz listeleri aşağıdaki kod ile paylaşabilirsiniz",
                                  style: MyTextStyles.font_16_20_500,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                StatefulBuilder(builder: (context, setCopyButtonState) {
                                  return GestureDetector(
                                    onTap: () {
                                      if (clipboardActionFuture != null) return;
                                      setCopyButtonState(() {
                                        clipboardActionFuture = Clipboard.setData(ClipboardData(text: sharedFileId));
                                      });
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.black12,
                                      ),
                                      child: FutureBuilder(
                                        future: clipboardActionFuture,
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.done) {
                                            return const Text("Kopyalandı!", style: MyTextStyles.font_16_24_500);
                                          }
                                          return Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(sharedFileId, style: MyTextStyles.font_16_24_500),
                                              const SizedBox(width: 16),
                                              const Icon(Icons.copy, size: 24),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            );
                          }
                        }
                      }

                      return [
                        StreamBuilder(
                          stream: uploadingStream(),
                          builder: (context, snapshot) {
                            if (snapshot.data != null) {
                              final dialogWidget = Container(
                                alignment: Alignment.center,
                                constraints: const BoxConstraints(minHeight: 48),
                                child: snapshot.data!,
                              );

                              final isAnimatable = KeyValueDatabase.getIsAnimatable();
                              return isAnimatable
                                  ? AnimatedSize(
                                      duration: MyDurations.millisecond300,
                                      child: dialogWidget,
                                    )
                                  : dialogWidget;
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ];
                    });
              },
            ),
        ],
      ),
    );
  }
}
