import 'package:control_financiero/core/utils/color_utils.dart';
import 'package:flutter/material.dart';

class CategoryButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryButton({
    super.key,
    required this.icon,
    required this.title,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final [r, g, b] = getRGBFromColor(colorScheme.primary);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: isSelected ? Color.fromRGBO(r, g, b, 0.1) : Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(
            color: isSelected ? colorScheme.primary : Colors.grey[400]!,
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(
                child: Icon(
                  icon,
                  size: 40,
                  color: isSelected ? colorScheme.primary : Colors.grey[600],
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected
                          ? colorScheme.primary
                          : Colors.grey[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
