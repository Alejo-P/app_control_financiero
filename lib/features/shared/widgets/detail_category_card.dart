import 'package:control_financiero/core/utils/color_utils.dart';
import 'package:flutter/material.dart';

class DetailCategoryCard extends StatelessWidget {
  final String categoryName;
  final IconData categoryIcon;
  final Color iconColor;
  final String currentValue;
  final bool showArrow;

  const DetailCategoryCard({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
    required this.iconColor,
    this.currentValue = "Seleccionar",
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
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
          child: Text(
          categoryName,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        
        const SizedBox(width: 4),
        //Valor actual
        IntrinsicWidth(
          child: Container(
            alignment: Alignment.centerRight,
            child: Text(
              currentValue,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
        ),

        if (showArrow) 
        ...[
          const SizedBox(width: 3),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey[400],
          ),
        ],
      ],
    );
  }
}
