import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/features/movimientos/models/movimiento.dart';
import 'package:control_financiero/features/movimientos/presentation/movimiento_form_page.dart';
import 'package:control_financiero/features/movimientos/widgets/transaction_detail_card.dart';
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

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final formattedDate =
        '${date.day} de ${_getMonthName(date.month)}, ${date.year}';
    final totalAmount = movimientos.fold<double>(0.0, (total, mov) {
      return mov.type == TipoMovimiento.gasto
          ? total - mov.ammount
          : total + mov.ammount;
    });

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedDate,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                totalAmount < 0
                    ? '-\$${totalAmount.abs().toStringAsFixed(2)}'
                    : '+\$${totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: totalAmount < 0 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: movimientos.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 16),
                itemBuilder: (context, index) {
                  final movimiento = movimientos[index];
                  final categoria = appState.getCategoriaById(
                    movimiento.categoryID,
                  );

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MovimientoFormPage(
                            mode: MovimientoFormMode.edit,
                            movimiento: movimiento,
                          ),
                        ),
                      );
                    },
                    child: TransactionDetailCard(
                    title: movimiento.title,
                    category: categoria!.name,
                    type: _getTypeName(movimiento.type),
                    spent: movimiento.ammount,
                    icon: categoria.iconData,
                    iconColor: Color(
                      categoria.iconColorValue,
                    ),
                    time: movimiento.time,
                  )
                  )
                  ;
                },
              ),
            ),
          ),
        ],
      ),
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

  String _getMonthName(int month) {
    const monthNames = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return monthNames[month - 1];
  }
}
