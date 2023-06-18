import 'package:flutter/material.dart';

class StrokeColoredButton extends StatelessWidget {
  StrokeColoredButton({super.key, required this.title, required this.onPressed});

  final String title;
  final void Function() onPressed;

  final ButtonStyle outlinedButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: MaterialStateColor.resolveWith((states) => const Color(0xFF007AFF)),
    backgroundColor: MaterialStateColor.resolveWith((states) => Colors.white),
    side: const BorderSide(color: Color(0xFF007AFF), width: 1.5),
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
    return OutlinedButton(
      style: outlinedButtonStyle,
      onPressed: onPressed,
      child: Text(title, style: buttonTextStyle),
    );
  }
}
