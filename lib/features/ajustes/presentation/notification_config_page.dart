import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/features/ajustes/widgets/item_card.dart';
import 'package:control_financiero/features/ajustes/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationConfigPage extends StatefulWidget {
  const NotificationConfigPage({super.key});

  @override
  State<NotificationConfigPage> createState() => _NotificationConfigPageState();
}

class _NotificationConfigPageState extends State<NotificationConfigPage> {
  double _customThreshold = 0.5;
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final thresholds = appState.budgetThresholds;

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración de Notificaciones')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SectionTitle(
                    title: 'Movimientos',
                    icon: Icons.account_balance_wallet_outlined,
                  ),

                  ItemCard(
                    title: 'Creación de movimientos',
                    value: false,
                    onChanged: (value) {
                      // Aquí puedes manejar el cambio de estado
                    },
                  ),

                  ItemCard(
                    title: 'Edición de movimientos',
                    value: false,
                    onChanged: (value) {
                      // Aquí puedes manejar el cambio de estado
                    },
                  ),

                  ItemCard(
                    title: 'Eliminación de movimientos',
                    value: false,
                    onChanged: (value) {
                      // Aquí puedes manejar el cambio de estado
                    },
                  ),

                  SectionTitle(
                    title: 'Presupuestos',
                    icon: Icons.pie_chart_outline,
                  ),

                  if (thresholds.isNotEmpty)
                    ...thresholds.map(
                      (threshold) => ItemCard(
                        title: 'Notificar al ${int.tryParse((threshold * 100).toStringAsFixed(0)) ?? 0}% del presupuesto',
                        value: false,
                        onChanged: (value) {
                          // Aquí puedes manejar el cambio de estado
                        },
                      ),
                    ),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text('Otro porcentaje'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Slider(
                                value: _customThreshold,
                                onChanged: (value) {
                                  setState(() {
                                    _customThreshold = value;
                                  });
                                },
                                min: 0.0,
                                max: 1.0,
                              ),
                              Text('${(_customThreshold * 100).toStringAsFixed(0)}%'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
