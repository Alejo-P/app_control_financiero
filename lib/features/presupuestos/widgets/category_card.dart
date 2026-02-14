import 'package:control_financiero/core/utils/color_utils.dart';
import 'package:control_financiero/features/shared/widgets/custom_progress_bar.dart';
import 'package:control_financiero/features/shared/widgets/icon_container.dart';
import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final double spent;
  final double total;
  final double percentage;
  final Color color;

  const CategoryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.spent,
    required this.total,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final percentageText = '${(percentage * 100).toStringAsFixed(0)}%';
    final remaining = total - spent;
    final isOverBudget = spent > total;
    final displayColor = isOverBudget ? Colors.red : colorScheme.onSurface;
    final borderColor = isOverBudget ? Colors.red : Colors.grey.shade600;
    final remainingText = isOverBudget
        ? 'Sobrepasado: \$${(spent - total).toStringAsFixed(2)}'
        : 'Restante: \$${remaining.toStringAsFixed(2)}';
    final [rBorder, gBorder, bBorder] = getRGBFromColor(borderColor);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Color.fromRGBO(rBorder, gBorder, bBorder, 0.5),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
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
                          title,
                          style: textTheme.labelMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        Text(
                          remainingText,
                          style: textTheme.labelSmall!.copyWith(
                            color: displayColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${spent.toStringAsFixed(2)}',
                        textAlign: TextAlign.right,
                        style: textTheme.labelMedium!.copyWith(
                          color: displayColor,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'de \$${total.toStringAsFixed(2)}',
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 14,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CustomProgressBar(
                        currentValue: percentage,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(percentageText, style: textTheme.labelSmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
