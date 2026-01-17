import 'package:flutter/material.dart';

class ColorContainer extends StatelessWidget {
  final Color color;
  final double size;
  final double borderWidth;
  final Color borderColor;
  final bool isSelected;
  final VoidCallback? onTap;

  const ColorContainer({
    super.key,
    required this.color,
    this.size = 32,
    this.borderWidth = 0,
    this.borderColor = Colors.transparent,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: borderWidth),
            ),
          ),

          AnimatedScale(
            scale: isSelected ? 1 : 0,
            duration: const Duration(milliseconds: 150),
            child: Icon(Icons.check, color: Colors.white, size: size / 2),
          )
        ],
      ),
    );
  }
}
