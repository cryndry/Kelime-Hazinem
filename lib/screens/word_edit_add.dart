import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/app_bar.dart';
import 'package:kelime_hazinem/components/bottom_sheet.dart';
import 'package:kelime_hazinem/components/dialog.dart';
import 'package:kelime_hazinem/components/fill_colored_button.dart';
import 'package:kelime_hazinem/components/icon.dart';
import 'package:kelime_hazinem/components/page_layout.dart';
import 'package:kelime_hazinem/components/stroke_colored_button.dart';
import 'package:kelime_hazinem/components/text_input.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/deep_map_copy.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';
import 'package:kelime_hazinem/utils/word_db_model.dart';

class WordEditAdd extends StatefulWidget {
  const WordEditAdd({super.key, this.word});

  final Word? word;

  @override
  State<WordEditAdd> createState() => WordEditAddState();
}

class WordEditAddState extends State<WordEditAdd> {
  final _formKey = GlobalKey<FormState>();
  Future<bool>? saveHandling;
  Future<void>? deleteHandling;
  var lists = <String, dynamic>{};
  var listsBottomSheet = <String, dynamic>{};
  final listsInitialValue = <String, dynamic>{};

  String plural = "";
  String infinitive = "";
  late String word = widget.word?.word ?? "";
  late String meaning = widget.word?.meaning.replaceAll("|", ", ") ?? "";

  late TextEditingController wordInputController = TextEditingController(text: word);
  late TextEditingController pluralInputController = TextEditingController(text: plural);
  late TextEditingController infinitiveInputController = TextEditingController(text: infinitive);
  late TextEditingController meaningInputController = TextEditingController(text: meaning);

  String? wordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kelime alanı boş bırakılamaz.';
    }
    return null;
  }

  String? pluralInfinitiveValidator(String? value) {
    if (pluralInputController.text.isNotEmpty && infinitiveInputController.text.isNotEmpty) {
      return 'Aynı anda hem çoğul hem mastar bilgisi girilemez.';
    }
    return null;
  }

  String? meaningValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Anlam alanı boş bırakılamaz';
    }
    return null;
  }

  @override
  void initState() {
    if (widget.word != null) {
      final description = widget.word!.description;
      if (description.contains("M.")) {
        infinitive = description.substring(3);
        plural = "";
      } else if (description.contains("Ç.")) {
        plural = description.substring(3);
        infinitive = "";
      }
    }

    SqlDatabase.getListsOfWord(widget.word!.id).then((value) {
      setState(() {
        lists.addAll(deepMapCopy(value));
        listsBottomSheet.addAll(deepMapCopy(value));
        listsInitialValue.addAll(deepMapCopy(value));
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    wordInputController.dispose();
    pluralInputController.dispose();
    infinitiveInputController.dispose();
    meaningInputController.dispose();

    super.dispose();
  }

  Future<bool> saveHandler() async {
    await Future.delayed(const Duration(seconds: 1));
    bool validationResult = _formKey.currentState!.validate();
    if (!validationResult) return false;

    if (widget.word != null) {
      widget.word!.word = wordInputController.text;
      widget.word!.meaning = meaningInputController.text;

      String pluralNew = pluralInputController.text;
      String infinitiveNew = infinitiveInputController.text;
      if (pluralNew.isNotEmpty) {
        widget.word!.description = "Ç. $pluralNew";
        widget.word!.descriptionSearch =
            pluralNew.replaceAll(RegExp(r"(^[\u0621-\u063A\u0641-\u064A0-9٠-٩\p{P}\p{S}\s])", unicode: true), "");
      } else if (infinitiveNew.isNotEmpty) {
        widget.word!.description = "M. $infinitiveNew";
        widget.word!.descriptionSearch =
            infinitiveNew.replaceAll(RegExp(r"(^[\u0621-\u063A\u0641-\u064A0-9٠-٩\p{P}\p{S}\s])", unicode: true), "");
      } else {
        widget.word!.description = "";
        widget.word!.descriptionSearch = "";
      }

      await SqlDatabase.updateWord(widget.word!.id, {
        "word": widget.word!.word,
        "word_search": widget.word!.wordSearch,
        "meaning": widget.word!.meaning,
        "description": widget.word!.description,
        "description_search": widget.word!.descriptionSearch
      });
      return true;
    } else {
      return true;
      // TODO Ekle menüsünde yeni kelime oluşturulacak.
    }
  }

  Future<void> deleteHandler() async {
    bool? isDeleted = await popDialog<bool>(
      context: context,
      children: [
        const Text(
          "Kelime Silinecek",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            height: 24 / 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Kelime tüm listelerden kalıcı olarak silinecek. Bu işlem geri alınamaz.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 16 / 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: StrokeColoredButton(
                title: "Vazgeç",
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ),
            const SizedBox(width: 16),
            FillColoredButton(
              title: "Onayla",
              onPressed: () async {
                final bool deleted = await SqlDatabase.deleteWord(widget.word!.id);
                Navigator.of(context).pop(deleted);
              },
            ),
          ],
        )
      ],
    );
    if (isDeleted != null && isDeleted) {
      await Future.delayed(const Duration(seconds: 1));
      Navigator.of(context).pop({"deleted": isDeleted});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(
          title: widget.word == null ? "Kelime Ekle" : "Düzenle",
          buttons: [
            ActionButton(
              icon: MySvgs.undo,
              size: 32,
              semanticsLabel: "Değişiklikleri Geri Al",
              onTap: () {
                setState(() {
                  wordInputController.text = word;
                  pluralInputController.text = plural;
                  infinitiveInputController.text = infinitive;
                  meaningInputController.text = meaning;
                  // TODO initial values of selected lists also will be recorded
                });
              },
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: PageLayout(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MyTextInput(
                      label: "Kelime",
                      hintText: word,
                      textInputController: wordInputController,
                      validator: wordValidator,
                      formatArabic: true,
                    ),
                    const SizedBox(height: 16),
                    MyTextInput(
                      label: "Çoğul",
                      hintText: plural,
                      textInputController: pluralInputController,
                      validator: pluralInfinitiveValidator,
                      formatArabic: true,
                    ),
                    const SizedBox(height: 16),
                    MyTextInput(
                      label: "Mastar",
                      hintText: infinitive,
                      textInputController: infinitiveInputController,
                      validator: pluralInfinitiveValidator,
                      formatArabic: true,
                    ),
                    const SizedBox(height: 16),
                    MyTextInput(
                      label: "Anlam",
                      hintText: meaning,
                      textInputController: meaningInputController,
                      validator: meaningValidator,
                      keyboardAction: TextInputAction.done,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  FutureBuilder(
                    future: deleteHandling,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          snapshot.connectionState == ConnectionState.active) {
                        return FillColoredButton(
                          icon: const SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                              semanticsLabel: "Siliniyor...",
                            ),
                          ),
                          onPressed: () {},
                        );
                      }
                      return FillColoredButton(
                        icon: const ActionButton(
                          icon: MySvgs.delete,
                          size: 32,
                        ),
                        onPressed: () {
                          setState(() {
                            deleteHandling = deleteHandler();
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FutureBuilder(
                      future: saveHandling,
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
                          icon: const ActionButton(
                            icon: MySvgs.save,
                            size: 32,
                          ),
                          onPressed: () {
                            setState(() {
                              saveHandling = saveHandler();
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FractionallySizedBox(
                widthFactor: 1,
                child: StrokeColoredButton(
                  title: "Listelere Ekle",
                  onPressed: () {
                    popBottomSheet<Map<String, dynamic>>(
                      context: context,
                      title: "Listelere Ekle",
                      info: "Liste değişiklikleri kaydettikten sonra geri alınamaz.",
                      bottomWidgets: (setSheetState) {
                        return [
                          ConstrainedBox(
                            constraints:
                                BoxConstraints.loose(Size.fromHeight(MediaQuery.of(context).size.height * 0.5)),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: listsBottomSheet.length,
                              itemBuilder: (context, index) {
                                final MapEntry listEntry = listsBottomSheet.entries.elementAt(index);
                                return CheckboxListTile(
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                  contentPadding: EdgeInsets.zero,
                                  value: listEntry.value["is_word_in_list"],
                                  controlAffinity: ListTileControlAffinity.leading,
                                  onChanged: (value) {
                                    setSheetState(() {
                                      listsBottomSheet[listEntry.key]["is_word_in_list"] = value;
                                    });
                                  },
                                  title: Text(
                                    listEntry.key,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      height: 20 / 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 32),
                          FillColoredButton(
                            title: "Kaydet",
                            onPressed: () async {
                              if (widget.word != null) {
                                // 2. düzenlemede listeler değişmiyor.
                                await SqlDatabase.changeListsOfWord(widget.word!.id, lists, listsBottomSheet);
                                lists = deepMapCopy(listsBottomSheet);
                                Navigator.of(context).pop();
                              } else {
                                // TODO save lists for now creating word
                              }
                            },
                          ),
                        ];
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
