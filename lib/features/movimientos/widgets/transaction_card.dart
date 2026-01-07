import 'package:flutter/material.dart';

class TransactionCard extends StatelessWidget {
  final double amount;
  final String name;
  final IconData icon;

  const TransactionCard({
    super.key,
    required this.amount,
    required this.name,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70),
            SizedBox(width: 4),
            Text(
              name,
              style: TextStyle(color: Colors.white70)
            ),
          ],
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
