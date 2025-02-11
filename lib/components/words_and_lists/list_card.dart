import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelime_hazinem/components/sheets_and_dialogs/bottom_sheet.dart';
import 'package:kelime_hazinem/components/buttons/fill_colored_button.dart';
import 'package:kelime_hazinem/components/buttons/icon.dart';
import 'package:kelime_hazinem/components/sheets_and_dialogs/snack_bar.dart';
import 'package:kelime_hazinem/components/buttons/stroke_colored_button.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:kelime_hazinem/utils/providers.dart';

class ListCard extends ConsumerStatefulWidget {
  const ListCard({
    super.key,
    this.icon,
    required this.title,
    this.dbTitle,
    this.color = MyColors.lightBlue,
    this.isDefaultList = false,
  });

  final String title;
  final String? dbTitle;
  final ActionButton? icon;
  final Color color;
  final bool isDefaultList;

  @override
  ListCardState createState() => ListCardState();
}

class ListCardState extends ConsumerState<ListCard> {
  final beginOffsetForRotatingPage = const Offset(0, 1);
  final overlayPortalController = OverlayPortalController();

  void showOverlayPortal() {
    overlayPortalController.hide();
    overlayPortalController.show();
    Future.delayed(MyDurations.millisecond1000, () {
      overlayPortalController.hide();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isListSelected = ref.watch(selectedListsProvider).contains(widget.title);

    return GestureDetector(
      onLongPress: () {
        if (widget.isDefaultList) return;

        activateListSelectionMode(ref);
        updateSelectedLists(ref, widget.title);
      },
      onTap: () async {
        bool isSelectionModeActive = !widget.isDefaultList && getIsListSelectionModeActive(ref);
        if (isSelectionModeActive) {
          updateSelectedLists(ref, widget.title);
          return;
        }

        final [doesHaveWord, isStudiable] = (widget.dbTitle == null)
            ? await SqlDatabase.checkIfListHaveWords(listName: widget.title, studiable: true)
            : [await SqlDatabase.checkIfIconicListHaveWords(listName: widget.dbTitle!), true];
        if (doesHaveWord) {
          popBottomSheet(
            context: context,
            title: widget.title,
            info: "Seçtiğiniz listenin ilgili menüsüne alttan ulaşabilirsiniz.",
            routeName: "ListActionsBottomSheet",
            bottomWidgets: (setSheetState) => [
              OverlayPortal(
                controller: overlayPortalController,
                overlayChildBuilder: (context) => Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    color: const Color(0xFF323232),
                    child: Row(
                      children: [
                        Text(
                          "Listedeki tüm kelimeleri öğrenmişsin!",
                          style: MyTextStyles.font_16_20_400.apply(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              FillColoredButton(
                title: "Kelime Öğrenme",
                onPressed: () {
                  if (isStudiable) {
                    Navigator.of(context).pushReplacementNamed("WordLearn", arguments: {
                      "listName": widget.title,
                      "dbTitle": widget.dbTitle ?? widget.title,
                      "beginOffset": beginOffsetForRotatingPage,
                    });
                  } else {
                    showOverlayPortal();
                  }
                },
              ),
              const SizedBox(height: 12),
              FillColoredButton(
                title: "Kelime Testi",
                onPressed: () {
                  if (isStudiable) {
                    Navigator.of(context).pushReplacementNamed("WordTest", arguments: {
                      "listName": widget.title,
                      "dbTitle": widget.dbTitle ?? widget.title,
                      "beginOffset": beginOffsetForRotatingPage,
                    });
                  } else {
                    showOverlayPortal();
                  }
                },
              ),
              const SizedBox(height: 12),
              FillColoredButton(
                title: "Kelimeyi Bul",
                onPressed: () {
                  if (isStudiable) {
                    Navigator.of(context).pushReplacementNamed("WordGuess", arguments: {
                      "listName": widget.title,
                      "dbTitle": widget.dbTitle ?? widget.title,
                      "beginOffset": beginOffsetForRotatingPage,
                    });
                  } else {
                    showOverlayPortal();
                  }
                },
              ),
              const SizedBox(height: 12),
              StrokeColoredButton(
                title: "Tüm Kelimeler",
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed("AllWordsOfList", arguments: {
                    "listName": widget.title,
                    "dbTitle": widget.dbTitle ?? widget.title,
                    "beginOffset": beginOffsetForRotatingPage,
                  });
                },
              ),
            ],
          );
        } else {
          showSnackBar(
            context: context,
            message: "Listede hiç kelime yok!",
          );
        }
      },
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8),
        constraints: BoxConstraints(maxWidth: (MediaQuery.of(context).size.width < 360) ? 80 : 100),
        decoration: BoxDecoration(
          border: isListSelected
              ? Border.all(
                  width: 2,
                  color: MyColors.darkBlue,
                  strokeAlign: BorderSide.strokeAlignOutside,
                )
              : null,
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(blurRadius: 4, color: widget.color.withOpacity(0.25))],
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: (widget.icon == null)
                      ? Text(
                          widget.title.substring(0, 1).toUpperCase(),
                          style: MyTextStyles.font_16_20_500.merge(
                            const TextStyle(color: Colors.white),
                          ),
                        )
                      : widget.icon,
                )
              ],
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 32, maxHeight: 48),
              child: Text(
                widget.title,
                maxLines: 3,
                softWrap: true,
                style: MyTextStyles.font_14_16_500.merge(const TextStyle(
                  letterSpacing: -0.5,
                )),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
