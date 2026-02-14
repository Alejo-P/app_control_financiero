import 'package:control_financiero/core/utils/color_utils.dart';
import 'package:flutter/material.dart';

class DetailCategoryCard extends StatelessWidget {
  final String categoryName;
  final IconData categoryIcon;
  final Color iconColor;
  final String? currentValue;
  final Widget? trailing;
  final bool showArrow;

  const DetailCategoryCard({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
    required this.iconColor,
    this.currentValue = "Seleccionar",
    this.trailing,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final [r, g, b] = getRGBFromColor(iconColor);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //Categoria
        Container(
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color.fromRGBO(r, g, b, 0.15),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Icon(categoryIcon, size: 22, color: iconColor),
        ),

        const SizedBox(width: 3),
        //Nombre categoria
        Expanded(
          flex: 2,
          child: Text(
            categoryName,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 6),

        //Valor actual
        if (currentValue != null && trailing == null)
          Expanded(
            flex: 3,
            child: Tooltip(
              message: currentValue!,
              child: Text(
                currentValue!,
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelMedium,
              ),
            ),
          ),

        if (trailing != null) ...[const SizedBox(width: 8), trailing!],

        if (showArrow && trailing == null)
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
      ],
    );
  }
}
