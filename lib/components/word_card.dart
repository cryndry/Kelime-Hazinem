import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/color_animated_icon.dart';
import 'package:kelime_hazinem/components/icon.dart';

class WordCard extends StatefulWidget {
  const WordCard({super.key, required this.isRandomWordCard});
  final bool isRandomWordCard;

  final TextStyle wordTextStyle = const TextStyle(
    fontSize: 20,
    height: 24 / 20,
    fontWeight: FontWeight.w600,
    color: Color.fromRGBO(255, 255, 255, 1),
  );

  final TextStyle infoTextStyle = const TextStyle(
    fontSize: 14,
    height: 16 / 14,
    fontWeight: FontWeight.w500,
    color: Color.fromRGBO(255, 255, 255, 0.6),
  );

  final TextStyle meaningTextStyle = const TextStyle(
    fontSize: 16,
    height: 20 / 16,
    fontWeight: FontWeight.w500,
    color: Color.fromRGBO(255, 255, 255, 0.9),
  );

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  bool willLearn = true;
  bool favorite = false;
  bool learned = false;
  bool memorized = false;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(12),
        color: const Color.fromARGB(255, 75, 161, 255),
        child: Stack(
          children: [
            if (widget.isRandomWordCard)
              const Positioned(
                top: 4,
                right: 4,
                width: 32,
                height: 32,
                child: ActionButton(
                  path: "assets/Refresh.svg",
                  size: 32,
                  semanticsLabel: "Kelimeyi Yenile",
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Kelime", style: widget.wordTextStyle),
                        const SizedBox(height: 2),
                        Text("Çoğul", style: widget.infoTextStyle),
                        const SizedBox(height: 8),
                        Text("Anlam", style: widget.meaningTextStyle),
                      ]),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AnimatedActionButton(
                        duration: 300,
                        size: 32,
                        path: "assets/Will Learn.svg",
                        isActive: willLearn,
                        activeFillColor: const Color(0xFFB3261E),
                        strokeColor: const Color(0xFFFFFFFF),
                        semanticsLabel: "Öğreneceklerime Ekle",
                        onTap: () {
                          setState(() {
                            willLearn = !willLearn;
                            if (willLearn) {
                              learned = false;
                              memorized = false;
                            }
                          });
                        },
                      ),
                      AnimatedActionButton(
                        duration: 300,
                        size: 32,
                        path: "assets/Favorites.svg",
                        isActive: favorite,
                        activeFillColor: const Color(0xFFFFD000),
                        strokeColor: const Color(0xFFFFFFFF),
                        semanticsLabel: "Favorilerime Ekle",
                        onTap: () {
                          setState(() {
                            favorite = !favorite;
                          });
                        },
                      ),
                      AnimatedActionButton(
                        duration: 300,
                        size: 32,
                        path: "assets/Learned.svg",
                        isActive: learned,
                        activeFillColor: const Color(0xFF70E000),
                        strokeColor: const Color(0xFFFFFFFF),
                        semanticsLabel: "Öğrendiklerime Ekle",
                        onTap: () {
                          setState(() {
                            learned = !learned;
                            if (learned) {
                              willLearn = false;
                              memorized = false;
                            }
                          });
                        },
                      ),
                      AnimatedActionButton(
                        duration: 300,
                        size: 32,
                        path: "assets/Memorized.svg",
                        isActive: memorized,
                        activeFillColor: const Color(0xFF008000),
                        strokeColor: const Color(0xFFFFFFFF),
                        semanticsLabel: "Hazineme Ekle",
                        onTap: () {
                          setState(() {
                            memorized = !memorized;
                            if (memorized) {
                              willLearn = false;
                              learned = false;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
