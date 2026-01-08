import 'package:flutter/material.dart';

class TransactionDetailCard extends StatelessWidget {
  final String title;
  final String category;
  final String type;
  final double spent;
  final IconData icon;
  final Color iconColor;
  final TimeOfDay time;

  const TransactionDetailCard({
    super.key,
    required this.title,
    required this.category,
    required this.type,
    required this.spent,
    required this.icon,
    required this.iconColor,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    // Convert Color components (0..1) to 0..255 ints to avoid deprecated accessors
    final int r = ((iconColor.r * 255.0).round().clamp(0, 255)).toInt();
    final int g = ((iconColor.g * 255.0).round().clamp(0, 255)).toInt();
    final int b = ((iconColor.b * 255.0).round().clamp(0, 255)).toInt();

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color.fromRGBO(r, g, b, 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor),
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
              Text(category, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        Column(
          children: [
            Text(
              '\$${spent.toStringAsFixed(2)}',
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
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}
