import 'package:flutter/material.dart';

abstract final class MyColors {
  static const darkBlue = Color(0xFF007AFF);
  static const lightBlue = Color(0xFF4BA1FF);
  static const aqua = Color(0xFFADE8F4);
  static const green = Color(0xFF70E000);
  static const darkGreen = Color(0xFF008000);
  static const red = Color(0xFFB3261E);
  static const amber = Color(0xFFFFD000);
}

abstract final class MyTextStyles {
  static const font_28_36_600 = TextStyle(
    fontSize: 28,
    height: 36 / 28,
    fontWeight: FontWeight.w600,
  );
  static const font_24_32_500 = TextStyle(
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w500,
  );
  static const font_20_24_600 = TextStyle(
    fontSize: 20,
    height: 24 / 20,
    fontWeight: FontWeight.w600,
  );
  static const font_20_24_500 = TextStyle(
    fontSize: 20,
    height: 24 / 20,
    fontWeight: FontWeight.w500,
  );
  static const font_18_20_500 = TextStyle(
    fontSize: 18,
    height: 20 / 18,
    fontWeight: FontWeight.w500,
  );
  static const font_16_24_500 = TextStyle(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w500,
  );
  static const font_16_20_500 = TextStyle(
    fontSize: 16,
    height: 20 / 16,
    fontWeight: FontWeight.w500,
  );
  static const font_16_20_400 = TextStyle(
    fontSize: 16,
    height: 20 / 16,
    fontWeight: FontWeight.w400,
  );
  static const font_14_16_500 = TextStyle(
    fontSize: 14,
    height: 16 / 14,
    fontWeight: FontWeight.w500,
  );
  static const font_14_16_400 = TextStyle(
    fontSize: 14,
    height: 16 / 14,
    fontWeight: FontWeight.w400,
  );
}

abstract final class MyRegExpPatterns {
  static RegExp allArabic = RegExp(r"([\u0621-\u063A\u0641-\u0652\u0660-\u06690-9\p{P}\p{S}\s])", unicode: true);
  static RegExp allArabicWithoutHaraka =
      RegExp(r'([\u0621-\u063A\u0641-\u064A\u0660-\u06690-9\p{P}\p{S}\s])', unicode: true);

  static String getWithoutHaraka(String word) {
    return allArabicWithoutHaraka.allMatches(word).map((e) => e[0]).toList().join("");
  }
}
