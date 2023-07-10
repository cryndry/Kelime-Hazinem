import 'package:flutter/material.dart';
import 'package:kelime_hazinem/utils/colors_text_styles_patterns.dart';

class StrokeColoredButton extends StatelessWidget {
  StrokeColoredButton({super.key, required this.title, required this.onPressed});

  final String title;
  final void Function() onPressed;

  final ButtonStyle outlinedButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: MaterialStateColor.resolveWith((states) => MyColors.darkBlue),
    backgroundColor: MaterialStateColor.resolveWith((states) => Colors.white),
    side: const BorderSide(color: MyColors.darkBlue, width: 1.5),
    padding: const EdgeInsets.all(12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: outlinedButtonStyle,
      onPressed: onPressed,
      child: Text(title, style: MyTextStyles.font_16_24_500),
    );
  }
}
