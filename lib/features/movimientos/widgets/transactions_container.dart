import 'package:control_financiero/app/app_routes.dart';
import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/features/movimientos/models/movimiento.dart';
import 'package:control_financiero/features/movimientos/models/movimiento_form_args.dart';
import 'package:control_financiero/features/movimientos/widgets/transaction_detail_card.dart';
import 'package:control_financiero/features/shared/widgets/widgets_container.dart';
import 'package:flutter/material.dart';
import 'package:control_financiero/app/app_state.dart';
import 'package:provider/provider.dart';

class TransactionsContainer extends StatelessWidget {
  final DateTime date;
  final List<Movimiento> movimientos;

  const TransactionsContainer({
    super.key,
    required this.date,
    required this.movimientos,
  });

  bool isCurrentMonth(DateTime date) {
    final now = currentDateTime;
    return date.year == now.year && date.month == now.month;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final appState = context.watch<AppState>();
    final formattedDate = formatRelativeDateWithMonth(date);
    final totalAmount = movimientos.fold<double>(0.0, (total, mov) {
      final categoria = appState.getCategoriaById(mov.categoryID);
      return categoria!.movementType == TipoMovimiento.gasto
          ? total - mov.amount
          : total + mov.amount;
    });

    return WidgetsContainer(
      title: formattedDate,
      summaryAmount: totalAmount < 0
          ? '-\$${totalAmount.abs().toStringAsFixed(2)}'
          : '+\$${totalAmount.toStringAsFixed(2)}',
      summaryAmountStyle: textTheme.labelMedium!.copyWith(
        fontWeight: FontWeight.bold,
        color: totalAmount >= 0 ? Colors.green : Colors.red,
      ),
      showDivider: false,
      children: movimientos.map((movimiento) {
        final categoria = appState.getCategoriaById(movimiento.categoryID);

        return TransactionDetailCard(
          title: movimiento.title,
          category: categoria!.name,
          type: _getTypeName(categoria.movementType),
          spent: movimiento.amount,
          icon: categoria.iconData,
          iconColor: Color(categoria.iconColorValue),
          time: movimiento.time,
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.movimientoFormRoute,
              arguments: MovimientoFormArgs(
                id: movimiento.id!, // Indica que es un movimiento existente
              ),
            );
          },
        );
      }).toList(),
    );
  }

  String _getTypeName(TipoMovimiento type) {
    switch (type) {
      case TipoMovimiento.ingreso:
        return 'Ingreso';
      case TipoMovimiento.gasto:
        return 'Gasto';
    }
  }
}
