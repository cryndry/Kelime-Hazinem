import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ActionButton extends StatefulWidget {
  const ActionButton({
    super.key,
    required this.path,
    required this.size,
    this.fillColor = Colors.transparent,
    this.strokeColor = Colors.white,
    this.semanticsLabel,
    this.onTap,
  });

  final String path;
  final double size;
  final Color fillColor;
  final Color strokeColor;
  final String? semanticsLabel;
  final void Function()? onTap;

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SvgPicture.asset(widget.path,
          width: widget.size,
          height: widget.size,
          theme: SvgTheme(currentColor: widget.fillColor), // fill color
          colorFilter: ColorFilter.mode(
              widget.strokeColor, BlendMode.dstIn), // stroke color
          semanticsLabel: widget.semanticsLabel),
    );
  }
}
