import 'package:flutter/material.dart';

class TotalBudgetSummaryCard extends StatelessWidget {
  final double totalBudget;
  final double spentAmount;

  const TotalBudgetSummaryCard({
    super.key,
    required this.totalBudget,
    required this.spentAmount
  });

  @override
  Widget build(BuildContext context) {
    final total = totalBudget;
    final spent = spentAmount;
    final available = total - spent;
    final percent = spent / total;
    // use percent to set the progress indicator's value programmatically
    final progressValue = percent.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '\$${totalBudget.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 32,
                color: Colors.white,
              ),
        ),
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Gastado: \$${spent.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.white70)
            ),
            Text(
              '${(percent * 100).toStringAsFixed(0)}%',
              style: TextStyle(color: Colors.white70)
            ),
          ],
        ),
        SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progressValue,
            minHeight: 8,
            backgroundColor: Colors.white24,
            valueColor:
                AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Disponible',
                style: TextStyle(color: Colors.white70)),
            Text(
              '\$${available.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}