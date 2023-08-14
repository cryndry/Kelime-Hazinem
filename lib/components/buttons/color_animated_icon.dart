import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/buttons/icon.dart';

class AnimatedActionButton extends StatefulWidget {
  const AnimatedActionButton({
    super.key,
    required this.isActive,
    required this.duration,
    required this.activeFillColor,
    this.inactiveFillColor = Colors.transparent,
    required this.icon,
    required this.size,
    this.strokeColor = Colors.white,
    this.semanticsLabel,
    this.onTap,
  });

  final bool isActive;
  final int duration;
  final Color activeFillColor;
  final Color inactiveFillColor;
  final String icon;
  final double size;
  final Color strokeColor;
  final String? semanticsLabel;
  final void Function()? onTap;

  @override
  AnimatedActionButtonState createState() => AnimatedActionButtonState();
}

class AnimatedActionButtonState extends State<AnimatedActionButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _colorTween;

  late Color firstBeginColor;
  late Color firstEndColor;

  @override
  void initState() {
    firstBeginColor = widget.isActive ? widget.activeFillColor : widget.inactiveFillColor;
    firstEndColor = widget.isActive ? widget.inactiveFillColor : widget.activeFillColor;

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.duration),
    );
    _colorTween = ColorTween(
      begin: firstBeginColor,
      end: firstEndColor,
    ).animate(_animationController);

    super.initState();
  }

  @override
  void didUpdateWidget(covariant AnimatedActionButton oldWidget) {
    if (oldWidget.isActive != widget.isActive) {
      if (firstBeginColor.hashCode == widget.activeFillColor.hashCode) {
        if (widget.isActive) {
          _animationController.reverse();
        } else {
          _animationController.forward();
        }
      } else {
        if (widget.isActive) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorTween,
      builder: (context, child) => ActionButton(
        icon: widget.icon,
        strokeColor: widget.strokeColor,
        size: widget.size,
        fillColor: _colorTween.value,
        semanticsLabel: widget.semanticsLabel,
        onTap: widget.onTap!,
      ),
    );
  }
}
