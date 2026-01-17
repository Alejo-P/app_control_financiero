import 'package:control_financiero/core/utils/color_utils.dart';
import 'package:flutter/material.dart';

class IconContainer extends StatelessWidget {
  final Color color;
  final IconData icon;
  final Color borderColor;
  final double size;
  final double borderWidth;
  final VoidCallback? onTap;

  const IconContainer({
    super.key,
    required this.icon,
    this.color = Colors.blue,
    this.size = 48,
    this.borderColor = Colors.transparent,
    this.borderWidth = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = size * 1.15;
    final [r, g, b] = getRGBFromColor(color);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(size * 0.25),
        decoration: BoxDecoration(
          color: Color.fromRGBO(r, g, b, 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: Icon(icon, size: iconSize, color: color),
      ),
    );
  }
}
