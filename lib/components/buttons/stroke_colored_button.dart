import 'package:flutter/material.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';

class StrokeColoredButton extends StatelessWidget {
  StrokeColoredButton({super.key, required this.title, this.onPressed});

  final String title;
  final void Function()? onPressed;

  final ButtonStyle outlinedButtonStyle = OutlinedButton.styleFrom(
    backgroundColor: MaterialStateColor.resolveWith((states) => Colors.white),
    foregroundColor: MaterialStateColor.resolveWith((states) => MyColors.darkBlue),
    disabledBackgroundColor: MaterialStateColor.resolveWith((states) => Colors.white),
    disabledForegroundColor: MaterialStateColor.resolveWith((states) => MyColors.darkBlue),
    side: const BorderSide(color: MyColors.darkBlue, width: 1.5),
    padding: const EdgeInsets.all(12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        style: outlinedButtonStyle,
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: MyTextStyles.font_16_24_500),
          ],
        ));
  }
}
