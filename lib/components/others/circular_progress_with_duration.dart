import 'dart:math';
import 'package:flutter/material.dart';

class CircularProgressIndicatorWithDuration extends StatefulWidget {
  const CircularProgressIndicatorWithDuration({
    super.key,
    required this.color,
    required this.duration,
    required this.strokeWidth,
    required this.size,
    this.shouldShowRemainingDuration = false,
    this.remainingDurationColor,
  });

  final Color color;
  final Duration duration;
  final double strokeWidth;
  final double size;
  final bool shouldShowRemainingDuration;
  final Color? remainingDurationColor;

  @override
  CircularProgressIndicatorWithDurationState createState() => CircularProgressIndicatorWithDurationState();
}

class CircularProgressIndicatorWithDurationState extends State<CircularProgressIndicatorWithDuration>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward();

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textSize = ((widget.size - widget.strokeWidth) / sqrt(2)).floorToDouble();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) => Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: CircularProgressIndicator(
              color: widget.color,
              strokeWidth: widget.strokeWidth,
              value: _animationController.value,
            ),
          ),
          if (widget.shouldShowRemainingDuration)
            Container(
              constraints: BoxConstraints(
                maxWidth: textSize,
                maxHeight: min(textSize, 24),
              ),
              width: textSize,
              height: textSize,
              child: FittedBox(
                fit: BoxFit.fitHeight,
                child: Text(
                  ((1 - _animationController.value) * widget.duration.inSeconds).round().toInt().toString(),
                  style: TextStyle(height: 1, color: widget.remainingDurationColor),
                  maxLines: 1,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
