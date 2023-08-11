import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';
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
  ActionButtonState createState() => ActionButtonState();
}

class ActionButtonState extends State<ActionButton> {
  late String svg = MySvgs.strokeChange(widget.icon, widget.strokeColor);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      textAlign: TextAlign.center,
      message: widget.semanticsLabel ?? "",
      showDuration: MyDurations.millisecond1000,
      triggerMode: TooltipTriggerMode.longPress,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: GestureDetector(
        onTap: widget.onTap,
        child: SvgPicture.string(
          svg,
          width: widget.size,
          height: widget.size,
          theme: SvgTheme(currentColor: widget.fillColor), // fill color
          semanticsLabel: widget.semanticsLabel,
        ),
      ),
    );
  }
}
