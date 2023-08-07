import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/app_bar.dart';
import 'package:kelime_hazinem/components/fill_colored_button.dart';
import 'package:kelime_hazinem/components/icon.dart';
import 'package:kelime_hazinem/components/page_layout.dart';
import 'package:kelime_hazinem/components/text_input.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';

class WordAdd extends StatefulWidget {
  const WordAdd({super.key});

  @override
  State<WordAdd> createState() => WordAddState();
}

class WordAddState extends State<WordAdd> {
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
    if (!validationResult) return false;

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
    final wordId = await SqlDatabase.createWord(wordData);
    if (wordId != 0) {
      return {...wordData, "id": wordId};
    }
    return false;
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
    } else {
      saveButtonOnTap();
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
