import 'package:flutter/material.dart';

class CircularProgressIndicatorWithDuration extends StatefulWidget {
  const CircularProgressIndicatorWithDuration({
    super.key,
    required this.color,
    required this.duration,
    required this.strokeWidth,
    this.size,
  });

  final Color color;
  final Duration duration;
  final double strokeWidth;
  final double? size;

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
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) => CircularProgressIndicator(
          color: widget.color,
          strokeWidth: widget.strokeWidth,
          value: _animationController.value,
        ),
      ),
    );
  }
}
