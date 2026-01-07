import 'package:control_financiero/features/movimientos/widgets/transaction_card.dart';
import 'package:flutter/material.dart';

class BalanceSummaryCard extends StatelessWidget {
  final double ammountIncome;
  final double ammountExpense;

  const BalanceSummaryCard({
    super.key,
    required this.ammountIncome,
    required this.ammountExpense,
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