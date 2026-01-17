import 'package:control_financiero/core/utils/color_utils.dart';
import 'package:flutter/material.dart';

class TabChip extends StatelessWidget {
  final bool isSelected;
  final Color tempColor;
  final String label;
  final VoidCallback onTap;

  const TabChip({
    super.key,
    required this.isSelected,
    required this.tempColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Colors.black;
    final [r, g, b] = getRGBFromColor(color);

    return Card(
      elevation: 0,
      color: (isSelected ? color : Color.fromRGBO(r, g, b, 0.1)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
