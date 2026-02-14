import 'package:control_financiero/features/shared/widgets/custom_progress_bar.dart';
import 'package:flutter/material.dart';

class TotalBudgetSummaryCard extends StatelessWidget {
  final double totalBudget;
  final double spentAmount;

  const TotalBudgetSummaryCard({
    super.key,
    required this.totalBudget,
    required this.spentAmount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final total = totalBudget;
    final spent = spentAmount;
    final available = total - spent;
    final percent = spent / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '\$${totalBudget.toStringAsFixed(2)}',
          style: textTheme.headlineMedium?.copyWith(
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
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              '${(percent * 100).toStringAsFixed(0)}%',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomProgressBar(
                currentValue: percent,
                color: Colors.white,
                backgroundColor: Colors.white24,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Disponible', style: TextStyle(color: Colors.white70)),
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
