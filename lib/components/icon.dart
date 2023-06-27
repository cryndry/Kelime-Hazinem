import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';

class ActionButton extends StatefulWidget {
  const ActionButton({
    super.key,
    required this.icon,
    required this.size,
    this.fillColor = Colors.transparent,
    this.strokeColor = Colors.white,
    this.semanticsLabel,
    this.onTap,
  });

  final String icon;
  final double size;
  final Color fillColor;
  final Color strokeColor;
  final String? semanticsLabel;
  final void Function()? onTap;

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  late String svg = MySvgs.strokeChange(widget.icon, widget.strokeColor);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SvgPicture.string(
        svg,
        width: widget.size,
        height: widget.size,
        theme: SvgTheme(currentColor: widget.fillColor), // fill color
        semanticsLabel: widget.semanticsLabel,
      ),
    );
  }
}
