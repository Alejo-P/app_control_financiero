import 'package:control_financiero/core/constants/categoria_constants.dart';
import 'package:control_financiero/features/categorias/widgets/color_container.dart';
import 'package:control_financiero/features/categorias/widgets/grid_container.dart';
import 'package:flutter/material.dart';

class ColorsSingleChildScroll extends StatelessWidget {
  final Color tempColor;
  final ValueChanged<Color> onTap;

  const ColorsSingleChildScroll({
    super.key,
    required this.tempColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GridContainer(
        columns: 5,
        gap: 12,
        children: categoryColors.map((color) {
          final isSelected = color == tempColor;

          return ColorContainer(
            size: 60,
            color: color,
            borderColor: isSelected ? Colors.black : Colors.transparent,
            borderWidth: isSelected ? 2 : 0,
            isSelected: isSelected,
            onTap: () {
              onTap(color);
            },
          );
        }).toList(),
      ),
    );
  }
}
