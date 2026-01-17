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

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            IconContainer(
              icon: icon,
              color: iconColor,
              size: 26,
            ),
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
                    category,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  type == 'Ingreso'
                      ? '+\$${spent.toStringAsFixed(2)}'
                      : '-\$${spent.toStringAsFixed(2)}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: type == 'Ingreso' ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  time.format(context),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
