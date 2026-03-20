import 'package:flutter/material.dart';

class AmmountDetailCard extends StatelessWidget {
  final double amount;
  final String name;
  final IconData icon;
  final Color iconColor;

  const AmmountDetailCard({
    super.key,
    required this.amount,
    required this.name,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: EdgeInsets.all(0),
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                SizedBox(width: 4),
                Text(
                  name,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: textTheme.bodyLarge?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
