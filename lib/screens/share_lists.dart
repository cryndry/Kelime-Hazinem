import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/app_bar.dart';
import 'package:kelime_hazinem/components/icon.dart';
import 'package:kelime_hazinem/components/nonscrollable_page_layout.dart';
import 'package:kelime_hazinem/utils/colors_text_styles_patterns.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';

class ShareLists extends StatelessWidget {
  const ShareLists({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: const MyAppBar(title: "Listelerini Paylaş"),
        body: NonScrollablePageLayout(
          child: Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 32),
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                          margin: const EdgeInsets.only(top: 16),
                          decoration: const BoxDecoration(
                            color: MyColors.lightBlue,
                            borderRadius: BorderRadius.all(Radius.circular(40)),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text("Liste Yükle", style: MyTextStyles.font_24_32_500),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    "Diğer kullanıcılardan aldığın kodlarla yeni listeler oluşturabilirsin",
                                    textAlign: TextAlign.center,
                                    style: MyTextStyles.font_16_24_500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: 64,
                          height: 64,
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: MyColors.darkBlue,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          child: Transform.rotate(
                            angle: pi * 1.5,
                            child: const ActionButton(
                              icon: MySvgs.backArrow,
                              size: 48,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                          margin: const EdgeInsets.only(top: 16),
                          decoration: const BoxDecoration(
                            color: MyColors.green,
                            borderRadius: BorderRadius.all(Radius.circular(40)),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text("Listelerini Paylaş", style: MyTextStyles.font_24_32_500),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    "Kendi listelerini de arkadaşlarınla paylaşabilirsin",
                                    textAlign: TextAlign.center,
                                    style: MyTextStyles.font_16_24_500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: 64,
                          height: 64,
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: MyColors.darkGreen,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          child: Transform.rotate(
                            angle: pi * 0.5,
                            child: const ActionButton(
                              icon: MySvgs.backArrow,
                              size: 48,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
