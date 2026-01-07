import 'package:flutter/material.dart';

class TotalBalanceSummaryCard extends StatelessWidget {
  final double total;
  final double variationPercent;

  const TotalBalanceSummaryCard({
    super.key,
    required this.total,
    required this.variationPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '\$${total.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 32,
                color: Colors.white,
              ),
        ),
        SizedBox(height: 4),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: variationPercent >= 0 ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    variationPercent >= 0 ? Icons.trending_up : Icons.trending_down,
                    color: variationPercent >= 0 ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${variationPercent >= 0 ? '+' : ''}${variationPercent.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: variationPercent >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 4),
            Text(
              'desde el mes pasado',
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ],
    );
  }
}