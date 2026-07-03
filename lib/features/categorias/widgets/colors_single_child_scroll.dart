import 'package:control_financiero/core/utils/color_utils.dart';
import 'package:control_financiero/features/categorias/widgets/color_container.dart';
import 'package:control_financiero/features/shared/widgets/grid_container.dart';
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
    final theme = Theme.of(context);
    final colorsScheme = theme.colorScheme;

    return GridContainer(
      columns: 5,
      gap: 12,
      children: colors.map((color) {
        final isSelected = compareColors(color, tempColor);
        final borderColor = isSelected ? colorsScheme.primary : colorsScheme.surface;

        return ColorContainer(
          size: 60,
          color: color,
          borderColor: borderColor,
          borderWidth: isSelected ? 2 : 0,
          isSelected: isSelected,
          onTap: () {
            onTap(color);
          },
        );
      }).toList(),
    );
  }
}
