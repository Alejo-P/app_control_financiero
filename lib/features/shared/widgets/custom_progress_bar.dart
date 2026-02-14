import 'package:flutter/material.dart';

class CustomProgressBar extends StatelessWidget {
  final double currentValue;
  final Color color;
  final Color? backgroundColor;
  final double minHeight;

  const CustomProgressBar({
    super.key,
    required this.currentValue,
    required this.color,
    this.backgroundColor,
    this.minHeight = 8,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Colors.grey.shade300;
    final value = currentValue.clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return LinearProgressIndicator(
          value: animatedValue,
          backgroundColor: bgColor,
          minHeight: minHeight,
          borderRadius: BorderRadius.circular(3),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        );
      },
    );
  }
}
