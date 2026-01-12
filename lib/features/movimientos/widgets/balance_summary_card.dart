import 'package:control_financiero/features/movimientos/widgets/transaction_card.dart';
import 'package:flutter/material.dart';

class BalanceSummaryCard extends StatelessWidget {
  final double ammountIncome;
  final double ammountExpense;
  final double variationPercent;

  const BalanceSummaryCard({
    super.key,
    required this.ammountIncome,
    required this.ammountExpense,
    required this.variationPercent,
  });

  @override
  Widget build(BuildContext context) {
    final ammountBalance = ammountIncome - ammountExpense;
    final balanceColor = ammountBalance >= 0 ? Colors.green[100] : Colors.red[100];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '\$${ammountBalance.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 32,
            color: balanceColor,
          ),
        ),
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
            SizedBox(width: 6),
            Text(
              'en ahorros desde el mes pasado',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TransactionCard(
              amount: ammountIncome,
              name: 'Ingresos',
              icon: Icons.arrow_upward
            ),
            
            TransactionCard(
              amount: ammountExpense,
              name: 'Gastos',
              icon: Icons.arrow_downward
            ),
          ],
        ),
      ],
    );
  }
}