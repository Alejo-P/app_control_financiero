import 'package:control_financiero/core/utils/color_utils.dart';
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
    final colors = theme.colorScheme;
    
    final percentageText = '${(percentage * 100).toStringAsFixed(0)}%';
    final remaining = total - spent;
    final isOverBudget = spent > total;
    final displayColor = isOverBudget ? Colors.red : colors.onSurface;
    final remainingText = isOverBudget
        ? 'Sobrepasado: \$${(spent - total).toStringAsFixed(2)}'
        : 'Restante: \$${remaining.toStringAsFixed(2)}';
    final [r, g, b] = getRGBFromColor(displayColor);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Color.fromRGBO(r, g, b, 0.5),
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
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          remainingText,
                          style: TextStyle(color: displayColor, fontSize: 13),
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: displayColor,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'de \$${total.toStringAsFixed(2)}',
                        style: TextStyle(color: colors.onSurface),
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
                      child: LinearProgressIndicator(
                        value: percentage.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey.shade300,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(3),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      percentageText,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
