import 'package:control_financiero/features/shared/widgets/icon_container.dart';
import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final double spent;
  final double total;
  final Color color;

  const CategoryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.spent,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = spent / total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  IconContainer(
                    icon: icon,
                    color: color,
                    size: 26,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            title,
                            style:
                                const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16
                                )
                        ),
                        Text(
                          'Restante: \$${(total - spent).toStringAsFixed(2)}',
                          style:
                              const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '\$${spent.toStringAsFixed(2)}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'de \$${total.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.grey.shade300,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
                valueColor:
                    AlwaysStoppedAnimation<Color>(color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
