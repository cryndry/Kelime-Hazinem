import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kelime_hazinem/components/add_word_to_lists.dart';
import 'package:kelime_hazinem/components/icon.dart';
import 'package:kelime_hazinem/utils/colors_text_styles_patterns.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';
import 'package:kelime_hazinem/utils/word_db_model.dart';
import 'package:kelime_hazinem/components/word_action_button_row.dart';

class WordCard extends StatefulWidget {
  const WordCard({
    super.key,
    required this.word,
    this.wordRemove,
    this.wordChange,
  });

  final Word word;
  final void Function(int)? wordRemove;
  final void Function()? wordChange;

  @override
  State<WordCard> createState() => WordCardState();
}

class WordCardState extends State<WordCard> {
  final TextStyle wordTextStyle = MyTextStyles.font_20_24_600.apply(color: Colors.white);
  final TextStyle infoTextStyle = MyTextStyles.font_14_16_500.apply(color: Colors.white60);
  final TextStyle meaningTextStyle = MyTextStyles.font_16_20_500.apply(color: Colors.white.withOpacity(0.9));

  int intBoolInvert(int value) => (value == 1) ? 0 : 1;
  bool intAsBool(int value) => (value == 1);

  void handleSetState(Function() callback) {
    setState(() {
      callback();
    });
  }

  void deleteWord(BuildContext context) async {
    final slidableController = Slidable.of(context)!;
    await slidableController.dismiss(ResizeRequest(const Duration(milliseconds: 300), () {}));

    SqlDatabase.deleteWord(widget.word.id);
    if (widget.wordRemove != null) {
      widget.wordRemove!(widget.word.id);
    } else if (widget.wordChange != null) {
      widget.wordChange!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return ClipRRect(
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
                      child: const ActionButton(icon: MySvgs.delete, size: 32),
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
                      child: const ActionButton(icon: MySvgs.edit, size: 32),
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
                      child: const ActionButton(icon: MySvgs.add2List, size: 32),
                    ),
                  );
                }),
              ),
            ],
          ),
          child: Builder(builder: (context) {
            return GestureDetector(
              onTap: () async {
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
      );
    });
  }
}
