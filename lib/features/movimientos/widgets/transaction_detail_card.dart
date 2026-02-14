import 'package:control_financiero/features/shared/widgets/icon_container.dart';
import 'package:flutter/material.dart';

class TransactionDetailCard extends StatelessWidget {
  final String title;
  final String category;
  final String type;
  final double spent;
  final IconData icon;
  final Color iconColor;
  final TimeOfDay time;
  final VoidCallback? onTap;

  const TransactionDetailCard({
    super.key,
    required this.title,
    required this.category,
    required this.type,
    required this.spent,
    required this.icon,
    required this.iconColor,
    required this.time,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconContainer(icon: icon, color: iconColor, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.labelMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary
                    ),
                  ),
                  Text(category, style: textTheme.labelSmall!.copyWith(
                    color: colorScheme.onSurface
                  )),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  type == 'Ingreso'
                      ? '+\$${spent.toStringAsFixed(2)}'
                      : '-\$${spent.toStringAsFixed(2)}',
                  textAlign: TextAlign.right,
                  style: textTheme.labelMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: type == 'Ingreso' ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  time.format(context),
                  textAlign: TextAlign.right,
                  style: textTheme.labelSmall!.copyWith(
                    color: colorScheme.onSurface
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
