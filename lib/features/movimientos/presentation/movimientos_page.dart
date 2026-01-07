import 'package:control_financiero/features/movimientos/widgets/balance_summary_card.dart';
import 'package:control_financiero/features/movimientos/widgets/category_chip.dart';
import 'package:control_financiero/features/shared/widgets/summary_card.dart';
import 'package:flutter/material.dart';

enum MovimientoFiltro {
  todos,
  ingresos,
  gastos,
}

class MovimientosPage extends StatefulWidget {
  const MovimientosPage({super.key});

  @override
  State<MovimientosPage> createState() => _MovimientosPageState();
}

class _MovimientosPageState extends State<MovimientosPage> {
  MovimientoFiltro selectedFilter = MovimientoFiltro.todos;

  @override
  Widget build(BuildContext context) {
    final categories = [
      MovimientoFiltro.todos,
      MovimientoFiltro.ingresos,
      MovimientoFiltro.gastos
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
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
                    height: 210,
                    child: SummaryCard(
                      title: 'Balance Mensual',
                      icon: Icons.account_balance,
                      backgroundColor: Colors.blue,
                      content: BalanceSummaryCard(
                        ammountIncome: 1200,
                        ammountExpense: 900,
                        variationPercent: 10.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  // Aquí puedes agregar más widgets relacionados con los movimientos
                  SizedBox(
                    height: 35,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (context, index) => SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final filtro = categories[index];

                        return CategoryChip(
                          label: _labelFromFiltro(filtro),
                          selected: filtro == selectedFilter,
                          onTap: () {
                            if (filtro == selectedFilter) return;
                            
                            setState(() {
                              selectedFilter = filtro;
                            });
                            print('Filtrar por $filtro');
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _labelFromFiltro(MovimientoFiltro filtro) {
    switch (filtro) {
      case MovimientoFiltro.ingresos:
        return 'Ingresos';
      case MovimientoFiltro.gastos:
        return 'Gastos';
      case MovimientoFiltro.todos:
      default:
        return 'Todos';
    }
  }
}
