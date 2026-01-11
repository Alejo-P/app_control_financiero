import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/utils/color_utils.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';
import 'package:control_financiero/features/movimientos/widgets/text_input_card.dart';
import 'package:control_financiero/features/movimientos/widgets/ammount_input.dart';
import 'package:control_financiero/features/movimientos/widgets/detail_category_card.dart';
import 'package:control_financiero/features/movimientos/widgets/info_tipe_movement_card.dart';
import 'package:control_financiero/features/movimientos/widgets/tipo_movimiento_selector.dart';
import 'package:control_financiero/features/shared/widgets/confirm_dialog.dart';
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
  bool _hasUnsavedChanges = false;
  late DateTime selectedDate;
  late List<Categoria> categorias;
  late List<Categoria> categoriasFiltradas;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDate = getCurrentDateWithoutTime();
    categorias = [];
    categoriasFiltradas = [];

    // Escuchar cambios en los controladores de texto
    _amountController.addListener(_markAsDirty);
    _titleController.addListener(_markAsDirty);
    _noteController.addListener(_markAsDirty);
  }

  @override
  void dispose() {
    // Limpiar los controladores al desechar el widget
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // Marca que hay cambios no guardados
  void _markAsDirty() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  void _onChangeTipoMovimiento(TipoMovimiento newTipoMovimiento) {
    setState(() {
      _hasUnsavedChanges = true;
      category = 'Sin categoría';
      tipoMovimiento = newTipoMovimiento;
      categoriasFiltradas = categorias
          .where((categoria) => categoria.movementType == tipoMovimiento)
          .toList();
    });
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
        _hasUnsavedChanges = true;
        selectedDate = picked;
      });
    }
  }

  void _guardarMovimiento() {
    final amountText = _amountController.text.trim();
    final noteText = _noteController.text.trim();
    final amount = double.tryParse(amountText.replaceAll(',', '.')) ?? 0.0;

    debugPrint('Monto: $amount');
    debugPrint('Tipo de Movimiento: $tipoMovimiento');
    debugPrint('Categoría: $category');
    debugPrint('Fecha: ${formatDate(selectedDate)}');
    debugPrint('Nota: $noteText');
    setState(() {
      _hasUnsavedChanges = false;
    });

    Navigator.pop(context, true);
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final shouldLeave = await showConfirmDialog(
      context,
      title: 'Salir sin guardar',
      content: 'Tienes cambios sin guardar. ¿Seguro que deseas salir?',
    );

    return shouldLeave == true;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    categorias = appState.categorias;
    categoriasFiltradas = categorias
        .where((categoria) => categoria.movementType == tipoMovimiento)
        .toList();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Agregar Movimiento'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Guardar',
              onPressed: () async {
                final amountText = _amountController.text;
                final titleText = _titleController.text.trim();

                if (amountText.isEmpty ||
                    double.tryParse(amountText.replaceAll(',', '.')) == null ||
                    double.parse(amountText.replaceAll(',', '.')) <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ingrese un monto válido')),
                  );
                  return;
                }

                if (titleText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ingrese un título')),
                  );
                  return;
                }

                if (category.isEmpty || category == 'Sin categoría') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Seleccione una categoría')),
                  );
                  return;
                }

                final confirmed = await showConfirmAddDialog(
                  context,
                  titleModal: 'Confirmar movimiento',
                  title: titleText,
                  category: category,
                  tipoMovimiento: tipoMovimiento,
                  amount: amountText,
                  date: selectedDate,
                  note: _noteController.text.trim(),
                );

                if (confirmed == true) {
                  _guardarMovimiento();
                }
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TipoMovimientoSelector(onChanged: _onChangeTipoMovimiento),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AmountInput(controller: _amountController),
                        Container(
                          margin: const EdgeInsets.only(top: 20),
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextInputCard(
                                textController: _titleController,
                                placeholder: 'Agregar un título',
                                iconData: Icons.title,
                                iconColor: Colors.grey.shade600,
                              ),
                              Divider(color: Colors.grey[300]),
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
                              Divider(color: Colors.grey[300]),
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
                              Divider(color: Colors.grey[300]),
                              TextInputCard(
                                textController: _noteController,
                                placeholder: 'Agregar una nota (opcional)',
                                iconData: Icons.edit_note,
                                iconColor: Colors.grey.shade600,
                              ),
                            ],
                          ),
                        ),
                        InfoTipeMovementCard(tipoMovimiento: tipoMovimiento),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCategoriasModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      showDragHandle: true, // Muestra el indicador de arrastre
      builder: (_) {
        // Si la lista de categorías está vacía, mostrar un mensaje
        if (categoriasFiltradas.isEmpty) {
          return const Center(
            child: Text(
              'No hay categorías disponibles.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: categoriasFiltradas.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final categoria = categoriasFiltradas[index];
            final [r, g, b] = getRGBFromColor(categoria.iconColor);

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Color.fromRGBO(r, g, b, 0.15),
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
          _hasUnsavedChanges = true;
          category = categoriaSeleccionada.name;
        });
      }
    });
  }
}
