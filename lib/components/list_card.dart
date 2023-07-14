import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/bottom_sheet.dart';
import 'package:kelime_hazinem/components/fill_colored_button.dart';
import 'package:kelime_hazinem/components/icon.dart';
import 'package:kelime_hazinem/components/route_animator.dart';
import 'package:kelime_hazinem/components/stroke_colored_button.dart';
import 'package:kelime_hazinem/screens/word_screen/all_words_of_list.dart';
import 'package:kelime_hazinem/screens/word_screen/word_guess.dart';
import 'package:kelime_hazinem/screens/word_screen/word_learn.dart';
import 'package:kelime_hazinem/utils/colors_text_styles_patterns.dart';
import 'package:kelime_hazinem/utils/database.dart';

class ListCard extends StatelessWidget {
  const ListCard({
    super.key,
    this.icon,
    required this.title,
    this.dbTitle,
    this.color = MyColors.lightBlue,
  });

  final String title;
  final String? dbTitle;
  final ActionButton? icon;
  final Color color;
  final beginOffsetForRotatingPage = const Offset(0, 1);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        bool doesHaveWord = (dbTitle == null)
            ? await SqlDatabase.checkIfListHaveWords(title)
            : await SqlDatabase.checkIfIconicListHaveWords(dbTitle!);
        if (doesHaveWord) {
          popBottomSheet(
            context: context,
            title: title,
            info: "Seçtiğiniz listenin ilgili menüsüne alttan ulaşabilirsiniz.",
            bottomWidgets: (setSheetState) => <Widget>[
              FillColoredButton(
                title: "Kelime Öğrenme",
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    routeAnimator(
                      beginOffset: beginOffsetForRotatingPage,
                      page: WordLearn(
                        listName: title,
                        dbTitle: dbTitle ?? title,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              FillColoredButton(title: "Kelime Testi", onPressed: () {}),
              const SizedBox(height: 12),
              FillColoredButton(
                title: "Kelimeyi Bul",
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    routeAnimator(
                      beginOffset: beginOffsetForRotatingPage,
                      page: WordGuess(
                        listName: title,
                        dbTitle: dbTitle ?? title,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              StrokeColoredButton(
                title: "Tüm Kelimeler",
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    routeAnimator(
                      beginOffset: beginOffsetForRotatingPage,
                      page: AllWordsOfList(
                        listName: title,
                        dbTitle: dbTitle ?? title,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              duration: Duration(milliseconds: 1200),
              content: Text("Listede hiç kelime yok!"),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(blurRadius: 4, color: color.withOpacity(0.25))],
        ),
        constraints: BoxConstraints(maxWidth: (MediaQuery.of(context).size.width < 350) ? 80 : 90),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: (icon == null)
                        ? Text(
                            title.substring(0, 1).toUpperCase(),
                            style: MyTextStyles.font_16_20_500.merge(
                              const TextStyle(color: Colors.white),
                            ),
                          )
                        : icon,
                  )
                ],
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(minHeight: 32, maxHeight: 48),
                child: Text(
                  title,
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
      ),
    );
  }
}
