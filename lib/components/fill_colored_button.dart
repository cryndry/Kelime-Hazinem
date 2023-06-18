import 'package:flutter/material.dart';

class FillColoredButton extends StatelessWidget {
  FillColoredButton({super.key, required this.title, required this.onPressed});

  final String title;
  final void Function() onPressed;

  final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: MaterialStateColor.resolveWith((states) => const Color(0xFF007AFF)),
    foregroundColor: MaterialStateColor.resolveWith((states) => Colors.white),
    padding: const EdgeInsets.all(12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  final TextStyle buttonTextStyle = const TextStyle(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w500,
  );

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: elevatedButtonStyle,
      onPressed: onPressed,
      child: Text(title, style: buttonTextStyle),
    );
  }
}
