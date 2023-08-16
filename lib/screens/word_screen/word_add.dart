import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelime_hazinem/components/app_bars/app_bar.dart';
import 'package:kelime_hazinem/components/sheets_and_dialogs/dialog.dart';
import 'package:kelime_hazinem/components/buttons/fill_colored_button.dart';
import 'package:kelime_hazinem/components/buttons/icon.dart';
import 'package:kelime_hazinem/components/layouts/page_layout.dart';
import 'package:kelime_hazinem/components/others/text_input.dart';
import 'package:kelime_hazinem/utils/analytics.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';
import 'package:kelime_hazinem/utils/providers.dart';

class WordAdd extends ConsumerStatefulWidget {
  const WordAdd({super.key});

  @override
  WordAddState createState() => WordAddState();
}

class WordAddState extends ConsumerState<WordAdd> {
  final _formKey = GlobalKey<FormState>();
  Future? saveHandling;

  String word = "";
  String meaning = "";
  String plural = "";
  String infinitive = "";

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
  void dispose() {
    wordInputController.dispose();
    pluralInputController.dispose();
    infinitiveInputController.dispose();
    meaningInputController.dispose();

    super.dispose();
  }

  Future saveHandler() async {
    await Future.delayed(MyDurations.millisecond500);
    bool validationResult = _formKey.currentState!.validate();
    if (!validationResult) return "TextError";

    String description;
    String descriptionSearch;
    String wordSearch;

    word = wordInputController.text;
    wordSearch = MyRegExpPatterns.getWithoutHaraka(word);
    meaning = meaningInputController.text;

    String pluralNew = pluralInputController.text;
    String infinitiveNew = infinitiveInputController.text;
    if (pluralNew.isNotEmpty) {
      description = "Ç. $pluralNew";
      descriptionSearch = MyRegExpPatterns.getWithoutHaraka(pluralNew);
    } else if (infinitiveNew.isNotEmpty) {
      description = "M. $infinitiveNew";
      descriptionSearch = MyRegExpPatterns.getWithoutHaraka(infinitiveNew);
    } else {
      description = "";
      descriptionSearch = "";
    }

    final wordData = {
      "word": word,
      "word_search": wordSearch,
      "meaning": meaning,
      "description": description,
      "description_search": descriptionSearch,
    };

    String? decision = "Save";
    final existingWordData = await SqlDatabase.getWordData(word);
    if (existingWordData != null) {
      decision = await popDialog<String>(
        context: context,
        builder: (setDialogState) {
          return [
            const Text(
              "Bu kelime için bir kayıt zaten mevcut. Dilerseniz o kaydı düzenleyebilirsiniz.",
              style: MyTextStyles.font_16_24_500,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                TextButton(
                  child: const Text(
                    "Yeni Kopyayı Kaydet",
                    style: MyTextStyles.font_16_24_500,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop("Save");
                  },
                ),
                TextButton(
                  child: const Text(
                    "Mevcut Kaydı Düzenle",
                    style: MyTextStyles.font_16_24_500,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop("EditExistingOne");
                  },
                ),
              ],
            )
          ];
        },
      );
    }
    if (decision == "EditExistingOne") {
      final existingWord = ref.read(allWordsProvider).where((word) => word.id == existingWordData!["id"]).first;
      await Navigator.of(context).pushReplacementNamed("WordEdit", arguments: {"word": existingWord});
      return;
    } else if (decision == "Save") {
      final wordId = await SqlDatabase.createWord(wordData);
      if (wordId != 0) {
        Analytics.logWordAction(word: wordData["word"]!, action: "word_created");
        return {...wordData, "id": wordId};
      }
      return "DbError";
    }
  }

  void saveButtonOnTap() async {
    setState(() {
      saveHandling = saveHandler();
    });
    final saveResult = await saveHandling;
    if (saveResult is Map) {
      Future.delayed(
        MyDurations.millisecond500,
        () {
          Navigator.of(context).pop(saveResult);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(
          title: "Kelime Ekle",
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
                  Expanded(
                    child: FutureBuilder(
                      future: saveHandling,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting ||
                            snapshot.connectionState == ConnectionState.active) {
                          return FillColoredButton(
                            title: "Kaydediliyor",
                            icon: const Padding(
                              padding: EdgeInsets.all(4),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                  semanticsLabel: "Kaydediliyor...",
                                ),
                              ),
                            ),
                            onPressed: () {},
                          );
                        }
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.data is Map) {
                            return FillColoredButton(
                              title: "Kaydedildi",
                              onPressed: () {},
                            );
                          } else if (snapshot.data == "DbError") {
                            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                              popDialog(
                                context: context,
                                duration: MyDurations.millisecond1000,
                                builder: (setDialogState) {
                                  return const [
                                    Text(
                                      "Bir hata oluştu. Lütfen tekrar deneyin.",
                                      style: MyTextStyles.font_16_24_500,
                                      textAlign: TextAlign.center,
                                    ),
                                  ];
                                },
                              );
                            });
                          }
                        }

                        return FillColoredButton(
                          title: "Kaydet",
                          icon: const ActionButton(
                            icon: MySvgs.save,
                            size: 32,
                          ),
                          onPressed: saveButtonOnTap,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
