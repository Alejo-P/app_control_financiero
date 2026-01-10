import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';
import 'package:control_financiero/features/movimientos/widgets/add_note_card.dart';
import 'package:control_financiero/features/movimientos/widgets/ammount_input.dart';
import 'package:control_financiero/features/movimientos/widgets/detail_category_card.dart';
import 'package:control_financiero/features/movimientos/widgets/info_tipe_movement_card.dart';
import 'package:control_financiero/features/movimientos/widgets/tipo_movimiento_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AgregarMovimientoPage extends StatefulWidget {
  const AgregarMovimientoPage({super.key});

  @override
  State<AgregarMovimientoPage> createState() => _AgregarMovimientoPageState();
}

class _AgregarMovimientoPageState extends State<AgregarMovimientoPage> {
  String category = 'Sin categoría';
  TipoMovimiento tipoMovimiento = TipoMovimiento.gasto;
  late DateTime selectedDate;
  late List<Categoria> categorias;
  
  @override
  void initState() {
    super.initState();
    selectedDate = getCurrentDateWithoutTime();
    categorias = [];
  }

  void _onChangeTipoMovimiento(TipoMovimiento newTipoMovimiento) {
    setState(() {
      tipoMovimiento = newTipoMovimiento;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    categorias = appState.categorias;
    final _amountController = TextEditingController();
    final _noteController = TextEditingController();

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
                            InkWell(
                              onTap: () => _openCategoriasModal(context),
                              borderRadius: BorderRadius.circular(12),
                              child: DetailCategoryCard(
                                categoryName: 'Categoría',
                                categoryIcon: Icons.category,
                                iconColor: Colors.blue,
                                currentValue: category,
                              ),
                            ),
                            Divider(
                              color: Colors.grey[300],
                            ),
                            InkWell(
                              onTap: () => _selectDate(context),
                              borderRadius: BorderRadius.circular(12),
                              child: DetailCategoryCard(
                                categoryName: 'Fecha',
                                categoryIcon: Icons.calendar_today,
                                iconColor: Colors.purple,
                                currentValue: formatDate(selectedDate),
                              ),
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
                      InfoTipeMovementCard(tipoMovimiento:  tipoMovimiento),
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _openCategoriasModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        // Si la lista de categorías está vacía, mostrar un mensaje
        if (categorias.isEmpty) {
          return const Center(
            child: Text(
              'No hay categorías disponibles.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: categorias.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final categoria = categorias[index];

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: categoria.iconColor.withOpacity(0.2),
                child: Icon(categoria.iconData, color: categoria.iconColor),
              ),
              title: Text(
                categoria.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                categoria.description,
                style: const TextStyle(color: Colors.grey),
              ),
              onTap: () {
                Navigator.pop(context, categoria);
              },
            );
          },
        );
      },
    ).then((categoriaSeleccionada) {
      if (categoriaSeleccionada != null) {
        setState(() {
          category = categoriaSeleccionada.name;
        });
      }
    });
  }
}
