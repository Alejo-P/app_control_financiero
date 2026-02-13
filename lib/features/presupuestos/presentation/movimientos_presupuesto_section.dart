import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/features/movimientos/models/movimiento.dart';
import 'package:control_financiero/features/movimientos/widgets/transactions_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MovimientosPresupuestoSection extends StatelessWidget {
  final List<Movimiento> movimientos;

  const MovimientosPresupuestoSection({
    super.key,
    this.movimientos = const [],
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final fechasMovimientos = appState.uniqueBudgetMovementDates;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Movimientos asociados a este presupuesto',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...fechasMovimientos.map((fecha) {
                    // Filtrar movimientos por fecha y filtro seleccionado
                    final movimientosFiltrados = movimientos
                        .where((mov) => isSameDay(mov.date, fecha))
                        .toList();

                    if (movimientosFiltrados.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return TransactionsContainer(
                      date: fecha,
                      movimientos: movimientosFiltrados,
                    );
                  }),
                  Center(
                    child: Text(
                      '${movimientos.length} movimiento${movimientos.length != 1 ? 's' : ''} en este presupuesto',
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
