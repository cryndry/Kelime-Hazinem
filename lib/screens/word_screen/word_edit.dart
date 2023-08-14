import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelime_hazinem/components/sheets_and_dialogs/add_word_to_lists.dart';
import 'package:kelime_hazinem/components/app_bars/app_bar.dart';
import 'package:kelime_hazinem/components/sheets_and_dialogs/dialog.dart';
import 'package:kelime_hazinem/components/buttons/fill_colored_button.dart';
import 'package:kelime_hazinem/components/buttons/icon.dart';
import 'package:kelime_hazinem/components/layouts/page_layout.dart';
import 'package:kelime_hazinem/components/buttons/stroke_colored_button.dart';
import 'package:kelime_hazinem/components/others/text_input.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';
import 'package:kelime_hazinem/utils/providers.dart';
import 'package:kelime_hazinem/utils/word_db_model.dart';

class WordEdit extends ConsumerStatefulWidget {
  const WordEdit({super.key, required this.word});

  final Word word;

  @override
  WordEditState createState() => WordEditState();
}

class WordEditState extends ConsumerState<WordEdit> {
  final _formKey = GlobalKey<FormState>();
  Future? saveHandling;
  Future<void>? deleteHandling;

  String plural = "";
  String infinitive = "";
  late String word = widget.word.word;
  late String meaning = widget.word.meaning;

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
    final description = widget.word.description;
    if (description.contains("M.")) {
      infinitive = description.substring(3);
      plural = "";
    } else if (description.contains("Ç.")) {
      plural = description.substring(3);
      infinitive = "";
    }

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

  Future saveHandler() async {
    await Future.delayed(MyDurations.millisecond500);
    bool validationResult = _formKey.currentState!.validate();
    if (!validationResult) return "TextError";

    widget.word.word = wordInputController.text;
    widget.word.meaning = meaningInputController.text;

    String pluralNew = pluralInputController.text;
    String infinitiveNew = infinitiveInputController.text;
    if (pluralNew.isNotEmpty) {
      widget.word.description = "Ç. $pluralNew";
      widget.word.descriptionSearch = MyRegExpPatterns.getWithoutHaraka(pluralNew);
    } else if (infinitiveNew.isNotEmpty) {
      widget.word.description = "M. $infinitiveNew";
      widget.word.descriptionSearch = MyRegExpPatterns.getWithoutHaraka(infinitiveNew);
    } else {
      widget.word.description = "";
      widget.word.descriptionSearch = "";
    }

    final isSuccessful = await SqlDatabase.updateWord(widget.word.id, {
      "word": widget.word.word,
      "word_search": widget.word.wordSearch,
      "meaning": widget.word.meaning,
      "description": widget.word.description,
      "description_search": widget.word.descriptionSearch
    });
    return isSuccessful;
  }

  Future<void> deleteHandler() async {
    bool? isDeleted = await popDialog<bool>(
      context: context,
      routeName: "DeleteWordDialog",
      builder: (setDialogState) => [
        const Text(
          "Kelime Silinecek",
          textAlign: TextAlign.center,
          style: MyTextStyles.font_20_24_600,
        ),
        const SizedBox(height: 12),
        const Text(
          "Kelime tüm listelerden kalıcı olarak silinecek. Bu işlem geri alınamaz.",
          textAlign: TextAlign.center,
          style: MyTextStyles.font_14_16_400,
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
                final bool deleted = await SqlDatabase.deleteWord(widget.word.id);
                Navigator.of(context).pop(deleted);
              },
            ),
          ],
        )
      ],
    );
    if (isDeleted != null && isDeleted) {
      ref.read(allWordsProvider.notifier).update((state) {
        int index = state.indexWhere((word) => word.id == widget.word.id);
        if (index == -1) return state;
        return [...state]..removeAt(index);
      });
      ref.read(allWordsOfListProvider.notifier).update((state) {
        int index = state.indexWhere((word) => word.id == widget.word.id);
        if (index == -1) return state;
        return [...state]..removeAt(index);
      });

      await Future.delayed(MyDurations.millisecond500);
      Navigator.of(context).pop({"deleted": isDeleted});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(
          title: "Düzenle",
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
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: MyTextInput(
                        label: "Kelime",
                        hintText: word,
                        textInputController: wordInputController,
                        validator: wordValidator,
                        formatArabic: true,
                      ),
                    ),
                    if (plural.isNotEmpty || (plural.isEmpty && infinitive.isEmpty))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: MyTextInput(
                          label: "Çoğul",
                          hintText: plural,
                          textInputController: pluralInputController,
                          validator: pluralInfinitiveValidator,
                          formatArabic: true,
                        ),
                      ),
                    if (infinitive.isNotEmpty || (plural.isEmpty && infinitive.isEmpty))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: MyTextInput(
                          label: "Mastar",
                          hintText: infinitive,
                          textInputController: infinitiveInputController,
                          validator: pluralInfinitiveValidator,
                          formatArabic: true,
                        ),
                      ),
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
                          icon: const Padding(
                            padding: EdgeInsets.all(4),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                                semanticsLabel: "Siliniyor...",
                              ),
                            ),
                          ),
                          onPressed: () {},
                        );
                      }
                      return FillColoredButton(
                        icon: const ActionButton(
                          icon: MySvgs.delete,
                          size: 32,
                          semanticsLabel: "Sil",
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
                          if (snapshot.data is bool) {
                            if (snapshot.data) {
                              Timer(MyDurations.millisecond1000, () {
                                setState(() {
                                  saveHandling = null;
                                });
                              });
                              return FillColoredButton(
                                title: "Kaydedildi",
                                icon: const ActionButton(
                                  icon: MySvgs.save,
                                  size: 32,
                                ),
                                onPressed: () {},
                              );
                            }
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
                    addWordToLists(context: context, wordId: widget.word.id);
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
