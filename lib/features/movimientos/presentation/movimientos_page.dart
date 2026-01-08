import 'package:control_financiero/features/movimientos/widgets/balance_summary_card.dart';
import 'package:control_financiero/features/movimientos/widgets/category_chip.dart';
import 'package:control_financiero/features/movimientos/widgets/transactions_container.dart';
import 'package:control_financiero/features/shared/widgets/summary_card.dart';
import 'package:control_financiero/app/app_state.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:control_financiero/core/constants/movimiento_constants.dart';

class MovimientosPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    MovimientoFiltro selectedFilter = appState.movimientoFiltro;

    // Lista de fechas de movimientos únicos para agrupar (mas reciente a más antiguo)
    final fechasMovimientos = appState.uniqueMovementDates;

    final categories = [
      MovimientoFiltro.todos,
      MovimientoFiltro.ingresos,
      MovimientoFiltro.gastos,
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
                          icon: _iconFromFiltro(filtro),
                          iconColor: _colorFromFiltro(filtro),
                          onTap: () {
                            appState.changeMovimientoFiltro(filtro);
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  ...fechasMovimientos.map((fecha) {
                    // Filtrar movimientos por fecha y filtro seleccionado
                    final movimientosFiltrados = appState.getMovimientosByDateAndFilter(
                      fecha,
                      selectedFilter,
                    );
                    print("Movimientos filtrados para $fecha: ${movimientosFiltrados.length} movimientos");
                    print(movimientosFiltrados);

                    if (movimientosFiltrados.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return TransactionsContainer(
                      date: fecha,
                      movimientos: movimientosFiltrados,
                    );
                  }),
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
      default:
        return 'Todos';
    }
  }

  IconData _iconFromFiltro(MovimientoFiltro filtro) {
    switch (filtro) {
      case MovimientoFiltro.ingresos:
        return Icons.arrow_downward;
      case MovimientoFiltro.gastos:
        return Icons.arrow_upward;
      default:
        return Icons.list;
    }
  }

  Color _colorFromFiltro(MovimientoFiltro filtro) {
    switch (filtro) {
      case MovimientoFiltro.ingresos:
        return Colors.green;
      case MovimientoFiltro.gastos:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
