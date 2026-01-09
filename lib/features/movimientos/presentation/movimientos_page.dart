import 'package:control_financiero/core/models/app_bar_action.dart';
import 'package:control_financiero/features/movimientos/models/totales_mensuales.dart';
import 'package:control_financiero/features/movimientos/widgets/balance_summary_card.dart';
import 'package:control_financiero/features/movimientos/widgets/category_chip.dart';
import 'package:control_financiero/features/movimientos/widgets/transactions_container.dart';
import 'package:control_financiero/features/shared/widgets/summary_card.dart';
import 'package:control_financiero/app/app_state.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:control_financiero/core/constants/movimiento_constants.dart';

class MovimientosPage extends StatefulWidget {
  const MovimientosPage({super.key});

  @override
  State<MovimientosPage> createState() => _MovimientosPageState();
}

class _MovimientosPageState extends State<MovimientosPage> {
  late AppState _appState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _appState = context.read<AppState>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _appState.setAppBarActions([
        AppBarAction(
          icon: Icons.add,
          tooltip: 'Nuevo movimiento',
          onPressed: () {
            Navigator.pushNamed(context, '/agregar_movimiento');
          },
        ),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    // Obtener totales de ingresos y gastos del mes seleccionado
    final totalMesActual = appState.totalesMensuales ??
        TotalesMensuales(ingresos: 0.0, gastos: 0.0);

    // Obtener el porcentaje de variación respecto al mes anterior
    final variationPercent = appState.variacionAhorro;
    
    // Filtro de movimientos seleccionado
    MovimientoFiltro selectedFilter = appState.movimientoFiltro;

    // Movimientos agrupados por fecha
    final fechasMovimientos = appState.uniqueMovementDates;

    final categories = [
      MovimientoFiltro.todos,
      MovimientoFiltro.ingresos,
      MovimientoFiltro.gastos,
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        // permite desplazamiento si el contenido es mayor que el espacio.
        children: [
          Expanded(
            child: fechasMovimientos.isEmpty
                ? _EmptyMovimientos()
                : SingleChildScrollView(
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
                        ammountIncome: totalMesActual.ingresos,
                        ammountExpense: totalMesActual.gastos,
                        variationPercent: variationPercent ?? 0.0,
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
                  // Lista de movimientos agrupados por fecha
                  ...fechasMovimientos.map((fecha) {
                    // Filtrar movimientos por fecha y filtro seleccionado
                    final movimientosFiltrados = appState.getMovimientosByDateAndFilter(
                      fecha,
                      selectedFilter,
                    );

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

class _EmptyMovimientos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No hay movimientos para mostrar.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          Text(
            'Agrega nuevos movimientos para empezar a llevar el control de tus finanzas.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
