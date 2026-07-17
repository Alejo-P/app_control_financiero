import 'package:control_financiero/features/shared/widgets/icon_container.dart';
import 'package:flutter/material.dart';

class CategoryCardDetail extends StatelessWidget {
  final String name;
  final String description;
  final int movementsCount;
  final IconData icon;
  final Color color;
  final bool isDefault;
  final VoidCallback? onTap;

  const CategoryCardDetail({
    super.key,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.isDefault,
    required this.movementsCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            Row(
              children: [
                IconContainer(icon: icon, color: color, size: 26),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        description.isEmpty ? '(Sin descripción)' : description,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (isDefault) 
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Tooltip(
                      message: 'Categoría predeterminada',
                      child: Icon(
                        Icons.lock,
                        size: 18,
                        color: colorScheme.primary.withOpacity(0.6),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
