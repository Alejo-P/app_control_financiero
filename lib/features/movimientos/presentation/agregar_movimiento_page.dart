import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/features/movimientos/widgets/add_note_card.dart';
import 'package:control_financiero/features/movimientos/widgets/ammount_input.dart';
import 'package:control_financiero/features/movimientos/widgets/detail_category_card.dart';
import 'package:control_financiero/features/movimientos/widgets/tipo_movimiento_selector.dart';
import 'package:flutter/material.dart';

class AgregarMovimientoPage extends StatefulWidget {
  const AgregarMovimientoPage({super.key});

  @override
  State<AgregarMovimientoPage> createState() => _AgregarMovimientoPageState();
}

class _AgregarMovimientoPageState extends State<AgregarMovimientoPage> {
  String category = 'Sin categoría';
  TipoMovimiento tipoMovimiento = TipoMovimiento.gasto;
  
  void _onChangeTipoMovimiento(TipoMovimiento newTipoMovimiento) {
    setState(() {
      tipoMovimiento = newTipoMovimiento;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _amountController = TextEditingController();
    final _noteController = TextEditingController();
    final date = getCurrentDateWithoutTime();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Movimiento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Guardar',
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
        ],
      ),
      body: Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            TipoMovimientoSelector(
              onChanged: _onChangeTipoMovimiento,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AmountInput(
                        controller: _amountController
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DetailCategoryCard(
                              categoryName: 'Categoría',
                              categoryIcon: Icons.category,
                              iconColor: Colors.blue,
                            ),
                            Divider(
                              color: Colors.grey[300],
                            ),
                            DetailCategoryCard(
                              categoryName: 'Fecha',
                              categoryIcon: Icons.calendar_today,
                              iconColor: Colors.purple,
                              currentValue: formatDate(date),
                            ),
                            Divider(
                              color: Colors.grey[300],
                            ),
                            AddNoteCard(
                              noteController: _noteController,
                            ),
                          ],
                        )
                      ),
                      Center(
                        child: Container(
                          width: 170,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: tipoMovimiento == TipoMovimiento.gasto ? Colors.red.shade100 : Colors.green.shade100,
                          ),
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(top: 20),
                          padding: const EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.circle,
                                color: tipoMovimiento == TipoMovimiento.gasto ? Colors.red.shade700 : Colors.green.shade700,
                                size: 14,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Registrando como ${tipoMovimiento == TipoMovimiento.gasto ? 'gasto' : 'ingreso'}',
                                style: TextStyle(
                                  color: tipoMovimiento == TipoMovimiento.gasto ? Colors.red.shade700 : Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
