import 'package:control_financiero/core/constants/categoria_constants.dart';
import 'package:control_financiero/features/shared/widgets/grid_container.dart';
import 'package:control_financiero/features/shared/widgets/icon_container.dart';
import 'package:flutter/material.dart';

class IconsSingleChildScroll extends StatelessWidget {
  final IconData tempIcon;
  final Color tempColor;
  final ValueChanged<IconData> onTap;

  const IconsSingleChildScroll({
    super.key,
    required this.tempIcon,
    required this.tempColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridContainer(
      columns: 5,
      gap: 12,
      children: categoryIcons.map((icon) {
        final isSelected = icon == tempIcon;

        return IconContainer(
          icon: icon,
          color: isSelected ? tempColor : Colors.grey[700]!,
          borderColor: isSelected ? tempColor : Colors.transparent,
          borderWidth: isSelected ? 2 : 0,
          size: 32,
          onTap: () {
            onTap(icon);
          },
        );
      }).toList(),
    );
  }
}
