import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final bool selected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon = Icons.category,
    this.iconColor = Colors.black54,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final bgColor = selected ? colors.primary : colors.surface;

    final contentColor = selected ? colors.onPrimary : colors.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: contentColor, width: selected ? 0 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? contentColor : iconColor, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? contentColor : colors.onSurface,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
