import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelime_hazinem/components/app_bars/app_bar.dart';
import 'package:kelime_hazinem/components/sheets_and_dialogs/bottom_sheet.dart';
import 'package:kelime_hazinem/components/buttons/fill_colored_button.dart';
import 'package:kelime_hazinem/components/buttons/icon.dart';
import 'package:kelime_hazinem/components/layouts/nonscrollable_page_layout.dart';
import 'package:kelime_hazinem/components/sheets_and_dialogs/snack_bar.dart';
import 'package:kelime_hazinem/components/others/text_input.dart';
import 'package:kelime_hazinem/utils/analytics.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';
import 'package:kelime_hazinem/utils/providers.dart';

class ShareLists extends ConsumerStatefulWidget {
  const ShareLists({super.key});

  @override
  ShareListsState createState() => ShareListsState();
}

class ShareListsState extends ConsumerState {
  final importListsTextInputController = TextEditingController();
  bool willCopyNewMeanings = false;
  bool willExtendExistingLists = false;
  Future<bool>? importingLists;
  String? errorMessage;

  Future<bool> checkIfCodeExists(String importCode) async {
    return await FirebaseDatabase.checkIfCodeExists(importCode);
  }

  Future<bool> importLists(String importCode) async {
    final doesCodeExist = await checkIfCodeExists(importCode);
    if (!doesCodeExist) {
      setState(() {
        errorMessage = "Hatalı giriş yaptınız ya da kodun karşılığı yok.";
      });
      return false;
    }

    await FirebaseDatabase.downloadFile(importCode);
    final importedLists = await SqlDatabase.importLists(willCopyNewMeanings, willExtendExistingLists);
    Analytics.logListShare(code: importCode, action: "list_share_import");
    ref.read(myListsProvider.notifier).update((state) => [...state, ...importedLists]);

    setState(() {
      errorMessage = null;
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final lists = ref.watch(myListsProvider);

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: const MyAppBar(title: "Listelerini Paylaş"),
        body: NonScrollablePageLayout(
          child: Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 32),
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final hasInternet = await ref.read(internetConnectivityProvider).hasInternetConnection;
                      if (!hasInternet) {
                        showSnackBar(
                          context: context,
                          message: "Listeleri içe aktarmak internet bağlantısı gerektirir.",
                        );
                        return;
                      }

                      popBottomSheet(
                        context: context,
                        title: "Yeni Listeler Ekle",
                        info: "Arkadaşlarından aldığın kodlarla yeni listeler oluşturabilirsin",
                        routeName: "ImportListsBottomSheet",
                        mayKeyboardAppear: true,
                        onSheetDismissed: () {
                          setState(() {
                            errorMessage = null;
                            importListsTextInputController.clear();
                          });
                        },
                        bottomWidgets: (setSheetState) => [
                          MyTextInput(
                            label: "Paylaşım Kodu",
                            hintText: "Kodunu Buraya Girebilirsin",
                            autoFocus: true,
                            keyboardAction: TextInputAction.done,
                            errormessage: errorMessage,
                            loseFocusOnTapOutside: false,
                            textInputController: importListsTextInputController,
                          ),
                          const SizedBox(height: 8),
                          Flexible(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  CheckboxListTile(
                                    dense: true,
                                    visualDensity: VisualDensity.compact,
                                    contentPadding: EdgeInsets.zero,
                                    value: willCopyNewMeanings,
                                    controlAffinity: ListTileControlAffinity.leading,
                                    onChanged: (value) {
                                      setSheetState(() {
                                        willCopyNewMeanings = value!;
                                      });
                                    },
                                    title: const Text(
                                      "Var olan kelimelerin anlam bilgilerini yenileriyle güncelle",
                                      style: MyTextStyles.font_16_20_500,
                                    ),
                                  ),
                                  CheckboxListTile(
                                    dense: true,
                                    visualDensity: VisualDensity.compact,
                                    contentPadding: EdgeInsets.zero,
                                    value: willExtendExistingLists,
                                    controlAffinity: ListTileControlAffinity.leading,
                                    onChanged: (value) {
                                      setSheetState(() {
                                        willExtendExistingLists = value!;
                                      });
                                    },
                                    title: const Text(
                                      "Liste isimleri çakışıyorsa listeleri birleştir",
                                      style: MyTextStyles.font_16_20_500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          FutureBuilder(
                            future: importingLists,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting ||
                                  snapshot.connectionState == ConnectionState.active) {
                                return FillColoredButton(
                                  title: "Yükleniyor",
                                  icon: const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                      semanticsLabel: "Yükleniyor...",
                                    ),
                                  ),
                                );
                              }
                              return FillColoredButton(
                                  title: "Listeleri Yükle",
                                  onPressed: () {
                                    final String importCode = importListsTextInputController.text;
                                    setState(() {
                                      setSheetState(() {
                                        errorMessage = null;
                                      });
                                      importingLists = importLists(importCode);
                                      setSheetState(() {});
                                    });

                                    importingLists!.then((value) {
                                      setSheetState(() {});
                                      if (!value) return value;

                                      Navigator.of(context).pop();
                                      return value;
                                    });
                                  });
                            },
                          ),
                        ],
                      );
                    },
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                          margin: const EdgeInsets.only(top: 16),
                          decoration: const BoxDecoration(
                            color: MyColors.lightBlue,
                            borderRadius: BorderRadius.all(Radius.circular(40)),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text("Liste Yükle", style: MyTextStyles.font_24_32_500),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    "Arkadaşlarından aldığın kodlarla yeni listeler oluşturabilirsin",
                                    textAlign: TextAlign.center,
                                    style: MyTextStyles.font_16_24_500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: 64,
                          height: 64,
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: MyColors.darkBlue,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          child: Transform.rotate(
                            angle: pi * 1.5,
                            child: const ActionButton(
                              icon: MySvgs.backArrow,
                              size: 48,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      if (lists.isEmpty) {
                        showSnackBar(
                          context: context,
                          message: "Hiç listen yok. Kelimelerini paylaşmak istiyorsan yeni bir liste oluşturabilirsin.",
                        );
                      } else {
                        final hasInternet = await ref.read(internetConnectivityProvider).hasInternetConnection;
                        if (!hasInternet) {
                          showSnackBar(
                            context: context,
                            message: "Liste paylaşımı internet bağlantısı gerektirir.",
                          );
                          return;
                        }

                        Navigator.of(context).pushNamed("MyLists");
                      }
                    },
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                          margin: const EdgeInsets.only(top: 16),
                          decoration: const BoxDecoration(
                            color: MyColors.green,
                            borderRadius: BorderRadius.all(Radius.circular(40)),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text("Listelerini Paylaş", style: MyTextStyles.font_24_32_500),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    "Kendi listelerini de arkadaşlarınla paylaşabilirsin",
                                    textAlign: TextAlign.center,
                                    style: MyTextStyles.font_16_24_500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: 64,
                          height: 64,
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: MyColors.darkGreen,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          child: Transform.rotate(
                            angle: pi * 0.5,
                            child: const ActionButton(
                              icon: MySvgs.backArrow,
                              size: 48,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
