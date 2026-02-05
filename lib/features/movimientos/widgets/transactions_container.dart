import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/features/movimientos/models/detalle_movimiento.dart';
import 'package:control_financiero/features/movimientos/models/movimiento.dart';
import 'package:control_financiero/features/movimientos/presentation/movimiento_form_page.dart';
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
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  @override
  Widget build(BuildContext context) {
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
      summaryAmountStyle: TextStyle(
        color: totalAmount < 0 ? Colors.red : Colors.green,
        fontWeight: FontWeight.bold,
      ),
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MovimientoFormPage(
                  mode: MovimientoFormMode.edit,
                  movimiento: DetalleMovimiento(
                    id: movimiento.id,
                    title: movimiento.title,
                    amount: movimiento.amount,
                    movementType: categoria.movementType,
                    date: movimiento.date,
                    categoryName: categoria.name,
                    categoryId: categoria.id,
                    time: movimiento.time,
                    note: movimiento.note,
                  ),
                ),
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
