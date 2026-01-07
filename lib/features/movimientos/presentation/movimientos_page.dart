import 'package:control_financiero/features/movimientos/widgets/balance_summary_card.dart';
import 'package:control_financiero/features/shared/widgets/summary_card.dart';
import 'package:flutter/material.dart';

class MovimientosPage extends StatelessWidget {
  const MovimientosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Expanded(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                height: 210,
                child: SummaryCard(
                  title: 'Balance Mensual',
                  icon: Icons.account_balance,
                  backgroundColor: Colors.blue,
                  content: BalanceSummaryCard(
                    ammountIncome: 1200,
                    ammountExpense: 900,
                  )
                )
              ),
              SizedBox(height: 8),
              // Aquí puedes agregar más widgets relacionados con los movimientos
            ],
          )
        ),
      ),
    );
  }
}
