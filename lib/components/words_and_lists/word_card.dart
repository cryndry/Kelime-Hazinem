import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kelime_hazinem/components/layouts/all_words_page_layout.dart';
import 'package:kelime_hazinem/components/others/circular_progress_with_duration.dart';
import 'package:kelime_hazinem/components/sheets_and_dialogs/add_word_to_lists.dart';
import 'package:kelime_hazinem/components/buttons/icon.dart';
import 'package:kelime_hazinem/utils/analytics.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';
import 'package:kelime_hazinem/utils/providers.dart';
import 'package:kelime_hazinem/utils/word_db_model.dart';
import 'package:kelime_hazinem/components/words_and_lists/word_action_button_row.dart';

class WordCard extends ConsumerStatefulWidget {
  const WordCard({
    super.key,
    required this.word,
    this.wordRemove,
    this.wordChange,
  });

  final Word word;
  final void Function() Function(int)? wordRemove;
  final void Function() Function()? wordChange;

  @override
  WordCardState createState() => WordCardState();
}

class WordCardState extends ConsumerState<WordCard> {
  final TextStyle wordTextStyle = MyTextStyles.font_20_24_600.apply(color: Colors.white);
  final TextStyle infoTextStyle = MyTextStyles.font_14_16_500.apply(color: Colors.white60);
  final TextStyle meaningTextStyle = MyTextStyles.font_16_20_500.apply(color: Colors.white.withOpacity(0.9));

  void handleSetState(Function() callback) {
    setState(() {
      callback();
    });
  }

  void deleteWord(BuildContext context) async {
    final scaffoldContext = Scaffold.of(context).context;
    final allWordsPageLayoutState = context.findAncestorStateOfType<AllWordsPageLayoutState>();

    final slidableController = Slidable.of(context)!;
    await slidableController.dismiss(ResizeRequest(MyDurations.millisecond300, () {}));

    void Function()? reverseRemoveCallback;
    if (widget.wordRemove != null) {
      reverseRemoveCallback = widget.wordRemove!(widget.word.id);
    } else if (widget.wordChange != null) {
      reverseRemoveCallback = widget.wordChange!();
    }

    Timer? timer;
    final duration = MyDurations.millisecond1000 * 5;

    ScaffoldMessenger.of(scaffoldContext).clearSnackBars();
    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
      SnackBar(
        padding: const EdgeInsets.all(8),
        backgroundColor: MyColors.darkBlue,
        duration: duration,
        onVisible: () {
          if (timer != null) {
            timer?.cancel();
            timer = null;
          }
          timer = Timer(duration, () {
            SqlDatabase.deleteWord(widget.word.id);
            Analytics.logWordAction(word: widget.word.word, action: "word_deleted");
            final bool? allWordsPageLayoutHasNoWord = allWordsPageLayoutState?.words.isEmpty;
            if (allWordsPageLayoutHasNoWord ?? false) {
              Navigator.of(scaffoldContext).popUntil(ModalRoute.withName("MainScreen"));
            }
          });
        },
        content: Row(
          children: [
            TextButton.icon(
              label: Text("Geri Al", style: MyTextStyles.font_14_16_500.apply(color: Colors.white)),
              style: const ButtonStyle(overlayColor: MaterialStatePropertyAll(Colors.white24)),
              icon: CircularProgressIndicatorWithDuration(
                size: 30,
                strokeWidth: 3,
                color: Colors.white,
                duration: duration,
                shouldShowRemainingDuration: true,
                remainingDurationColor: Colors.white,
              ),
              onPressed: () {
                timer?.cancel();
                timer = null;
                reverseRemoveCallback?.call();
                ScaffoldMessenger.of(scaffoldContext).clearSnackBars();
              },
            ),
            const SizedBox(width: 4),
            const Text(
              "Kelime kalıcı olarak silinecek.",
              style: MyTextStyles.font_16_20_400,
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedWords = ref.watch(selectedWordsProvider);

    return LayoutBuilder(builder: (context, constraints) {
      return DecoratedBox(
        position:
            selectedWords.contains(widget.word.id) ? DecorationPosition.foreground : DecorationPosition.background,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: MyColors.darkGreen, width: 3),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Slidable(
            key: widget.key,
            startActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 48 / constraints.maxWidth,
              dismissible: Builder(builder: (context) {
                return DismissiblePane(
                  dismissThreshold: 0.5,
                  onDismissed: () {
                    deleteWord(context);
                  },
                );
              }),
              children: [
                Flexible(
                  child: Builder(builder: (context) {
                    return GestureDetector(
                      onTap: () {
                        deleteWord(context);
                      },
                      child: Container(
                        width: 48,
                        color: MyColors.red,
                        alignment: Alignment.center,
                        child: const ActionButton(
                          icon: MySvgs.delete,
                          size: 32,
                          semanticsLabel: "Sil",
                        ),
                      ),
                    );
                  }),
                )
              ],
            ),
            endActionPane: ActionPane(
              openThreshold: 0.0001,
              closeThreshold: 0.0001,
              motion: const DrawerMotion(),
              extentRatio: 160 / constraints.maxWidth,
              children: [
                Flexible(
                  child: Builder(builder: (context) {
                    return GestureDetector(
                      onTap: () async {
                        final result = await Navigator.of(context).pushNamed(
                          "WordEdit",
                          arguments: {"word": widget.word},
                        );

                        if (result != null && (result as Map)["deleted"]) {
                          if (widget.wordRemove != null) {
                            widget.wordRemove!(widget.word.id);
                          } else if (widget.wordChange != null) {
                            widget.wordChange!();
                          }
                        } else {
                          final slidableController = Slidable.of(context)!;
                          setState(() {});
                          slidableController.close();
                        }
                      },
                      child: Container(
                        width: 80,
                        color: MyColors.darkGreen,
                        alignment: Alignment.center,
                        child: const ActionButton(
                          icon: MySvgs.edit,
                          size: 32,
                          semanticsLabel: "Düzenle",
                        ),
                      ),
                    );
                  }),
                ),
                Flexible(
                  child: Builder(builder: (boxContext) {
                    return GestureDetector(
                      onTap: () {
                        addWordToLists(context: context, wordId: widget.word.id).then((value) {
                          final slidableController = Slidable.of(boxContext)!;
                          slidableController.close();
                        });
                      },
                      child: Container(
                        width: 80,
                        color: MyColors.darkBlue,
                        alignment: Alignment.center,
                        child: const ActionButton(
                          icon: MySvgs.add2List,
                          size: 32,
                          semanticsLabel: "Listelere Ekle",
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
            child: Builder(builder: (context) {
              return GestureDetector(
                onLongPress: () {
                  activateWordSelectionMode(ref);
                  updateSelectedWords(ref, widget.word.id);
                },
                onTap: () async {
                  bool isWordSelectionModeActive = getIsWordSelectionModeActive(ref);
                  if (isWordSelectionModeActive) {
                    updateSelectedWords(ref, widget.word.id);
                    return;
                  }

                  final slidableController = Slidable.of(context)!;
                  if (slidableController.ratio != 0) {
                    slidableController.close();
                    return;
                  }

                  final result = await Navigator.of(context).pushNamed(
                    "WordShow",
                    arguments: {"word": widget.word},
                  );
                  if (result != null && (result as Map)["deleted"] && widget.wordRemove != null) {
                    widget.wordRemove!(widget.word.id);
                  } else {
                    setState(() {});
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  color: MyColors.lightBlue,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(widget.word.word, style: wordTextStyle),
                            if (widget.word.description.isNotEmpty) const SizedBox(height: 2),
                            if (widget.word.description.isNotEmpty) Text(widget.word.description, style: infoTextStyle),
                            const SizedBox(height: 8),
                            Text(widget.word.meaning, style: meaningTextStyle),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      WordActionButtonRow(
                        word: widget.word,
                        eachIconSize: 32,
                        iconStrokeColor: Colors.white,
                        handleSetState: handleSetState,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      );
    });
  }
}
