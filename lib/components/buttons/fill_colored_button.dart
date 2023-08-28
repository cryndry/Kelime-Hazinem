import 'package:flutter/material.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';

class FillColoredButton extends StatelessWidget {
  FillColoredButton({super.key, this.title, required this.onPressed, this.icon});

  final String? title;
  final void Function() onPressed;
  final Widget? icon;

  final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: MaterialStateColor.resolveWith((states) => MyColors.darkBlue),
    foregroundColor: MaterialStateColor.resolveWith((states) => Colors.white),
    padding: const EdgeInsets.all(12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: elevatedButtonStyle,
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (title != null) Text(title!, style: MyTextStyles.font_16_24_500),
          if (title != null && icon != null) const SizedBox(width: 12),
          if (icon != null) icon!,
        ],
      ),
    );
  }
}
