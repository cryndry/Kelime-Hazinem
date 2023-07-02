import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/bottom_sheet.dart';
import 'package:kelime_hazinem/components/dialog.dart';
import 'package:kelime_hazinem/components/fill_colored_button.dart';
import 'package:kelime_hazinem/components/icon.dart';
import 'package:kelime_hazinem/components/stroke_colored_button.dart';
import 'package:kelime_hazinem/screens/word_screen/word_learn.dart';
import 'package:kelime_hazinem/utils/database.dart';

class ListCard extends StatefulWidget {
  ListCard({
    super.key,
    this.icon,
    required this.title,
    this.color = const Color(0xFF4BA1FF),
  });

  final String title;
  final ActionButton? icon;
  final Color color;

  late final String dbTitle = (() {
    final defaults = {
      "Öğrenecek\u200blerim": "willLearn",
      "Favorilerim".split('').join('\ufeff'): "favorite",
      "Öğrendik\u200blerim": "learned",
      "Hazinem": "memorized",
      "Temel Seviye": "basic",
      "Orta Seviye": "intermediate",
      "İleri Seviye": "advanced",
    };

    return defaults[title] ?? title.toLowerCase().replaceAll(" ", "_");
  })();

  final ButtonStyle outlinedButtonStyle = ButtonStyle(
      foregroundColor: MaterialStateColor.resolveWith((states) => const Color(0xFF007AFF)),
      backgroundColor: MaterialStateColor.resolveWith((states) => Colors.white),
      surfaceTintColor: MaterialStateColor.resolveWith((states) => const Color(0xFF007AFF)));

  @override
  State<ListCard> createState() => _ListCardState();
}

class _ListCardState extends State<ListCard> {
  bool doesHaveWord = false;

  @override
  void initState() {
    SqlDatabase.checkIfListHaveWords(widget.dbTitle).then((result) {
      doesHaveWord = result;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        popBottomSheet(
          context,
          widget.title,
          "Seçtiğiniz listenin ilgili menüsüne alttan ulaşabilirsiniz.",
          <Widget>[
            FillColoredButton(
                title: "Kelime Öğrenme",
                onPressed: () {
                  if (doesHaveWord) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => WordLearn(
                          listName: widget.title,
                          dbTitle: widget.dbTitle,
                        ),
                      ),
                    );
                  } else {
                    popDialog(
                      context: context,
                      fadeDurationInMiliSecs: 1200,
                      children: [
                        const Text(
                          "Listede hiç kelime yok.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            height: 20 / 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: FittedBox(
                            child: StrokeColoredButton(
                              title: "Tamam",
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                }),
            const SizedBox(height: 12),
            FillColoredButton(title: "Kelime Testi", onPressed: () {}),
            const SizedBox(height: 12),
            FillColoredButton(title: "Kelimeyi Bul", onPressed: () {}),
            const SizedBox(height: 12),
            StrokeColoredButton(title: "Tüm Kelimeler", onPressed: () {}),
          ],
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(blurRadius: 4, color: widget.color.withOpacity(0.25))],
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
                      color: widget.color,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: (widget.icon == null)
                        ? Text(
                            widget.title.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              height: 20 / 16,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : widget.icon,
                  )
                ],
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(minHeight: 32, maxHeight: 48),
                child: Text(
                  widget.title,
                  maxLines: 3,
                  softWrap: true,
                  style: const TextStyle(
                    letterSpacing: -0.5,
                    fontSize: 14,
                    height: 16 / 14,
                    fontWeight: FontWeight.w500,
                  ),
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
