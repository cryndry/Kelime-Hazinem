import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/buttons/icon.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';

class FAB extends StatelessWidget {
  const FAB({super.key, required this.icon, required this.onTap, this.semanticsLabel});

  final String icon;
  final String? semanticsLabel;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: MyColors.darkGreen,
        boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)],
      ),
      child: ActionButton(
        icon: icon,
        size: 32,
        fillColor: Colors.transparent,
        strokeColor: Colors.white,
        onTap: onTap,
        semanticsLabel: semanticsLabel,
      ),
    );
  }
}
