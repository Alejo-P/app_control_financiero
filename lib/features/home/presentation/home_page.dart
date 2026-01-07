import 'package:control_financiero/features/home/widgets/detail_card.dart';
import 'package:control_financiero/features/home/widgets/icon_button_custom.dart';
import 'package:control_financiero/features/home/widgets/total_balance_summary_card.dart';
import 'package:control_financiero/features/shared/widgets/summary_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:control_financiero/app/app_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        // permite desplazamiento si el contenido es mayor que el espacio.
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 210, // ajusta a gusto
                    child: SummaryCard(
                      title: 'Balance Total',
                      icon: Icons.account_balance_wallet,
                      backgroundColor: Colors.purple,
                      content: TotalBalanceSummaryCard(
                        total: 150,
                        variationPercent: 5.0,
                      )
                    )
                  ),
                  SizedBox(height: 8),
                  GridView(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 3 / 2,
                    ),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      DetailCard(
                        title: 'Ingresos',
                        ammount: '2,500.00',
                        icon: Icons.arrow_downward,
                        iconColor: Colors.green,
                      ),
                      DetailCard(
                        title: 'Gastos',
                        ammount: '1,200.00',
                        icon: Icons.arrow_upward,
                        iconColor: Colors.red,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Registrar un nuevo movimiento',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButtonCustom(
                                  onPressed: () {
                                    print('Registrar ingreso');
                                  },
                                  icon: Icons.add_circle,
                                  color: Colors.green,
                                  label: 'Ingreso'
                                ),
                                IconButtonCustom(
                                  onPressed: () {
                                    print('Registrar gasto');
                                  },
                                  icon:  Icons.remove_circle,
                                  color: Colors.red,
                                  label: 'Gasto'
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
