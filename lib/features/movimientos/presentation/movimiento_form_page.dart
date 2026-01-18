import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';
import 'package:control_financiero/features/movimientos/models/movimiento.dart';
import 'package:control_financiero/app/app_snackbar.dart';
import 'package:control_financiero/features/shared/widgets/icon_container.dart';
import 'package:control_financiero/features/shared/widgets/text_input_card.dart';
import 'package:control_financiero/features/movimientos/widgets/ammount_input.dart';
import 'package:control_financiero/features/shared/widgets/detail_category_card.dart';
import 'package:control_financiero/features/movimientos/widgets/info_tipe_movement_card.dart';
import 'package:control_financiero/features/movimientos/widgets/tipo_movimiento_selector.dart';
import 'package:control_financiero/features/shared/widgets/confirm_dialog.dart';
import 'package:control_financiero/features/shared/widgets/widgets_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MovimientoFormPage extends StatefulWidget {
  final MovimientoFormMode mode;
  final Movimiento? movimiento;

  const MovimientoFormPage({super.key, required this.mode, this.movimiento});

  @override
  State<MovimientoFormPage> createState() => _MovimientoFormPageState();
}

class _MovimientoFormPageState extends State<MovimientoFormPage> {
  int categoryId = -1;
  int movementId = 0;
  String categoryName = 'Sin categoría';
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

    if (widget.mode == MovimientoFormMode.edit && widget.movimiento != null) {
      _amountController.text = widget.movimiento!.ammount.toString();
      _noteController.text = widget.movimiento!.note;
      _titleController.text = widget.movimiento!.title;
      categoryId = widget.movimiento!.categoryID;
      selectedDate = widget.movimiento!.date;
      tipoMovimiento = widget.movimiento!.type;
      movementId = widget.movimiento!.id!;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final appState = context.read<AppState>();
        final category = appState.getCategoriaById(categoryId);

        if (category == null) return;

        setState(() {
          categoryName = category.name;
        });
      });
    }

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
    _titleController.dispose();
    super.dispose();
  }

  // Marca que hay cambios no guardados
  void _markAsDirty() {
    // Si el campo esta vacío, no marcar como sucio
    if (_amountController.text.isEmpty &&
        _titleController.text.isEmpty &&
        _noteController.text.isEmpty) {
      setState(() {
        _hasUnsavedChanges = false;
      });
      return;
    }

    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  void _onChangeTipoMovimiento(TipoMovimiento newTipoMovimiento) {
    setState(() {
      categoryId = -1;
      categoryName = 'Sin categoría';
      tipoMovimiento = newTipoMovimiento;
      categoriasFiltradas = categorias
          .where((categoria) => categoria.movementType == tipoMovimiento)
          .toList();
    });
  }

  void _onCategoriaSelected(Categoria categoria) {
    setState(() {
      _hasUnsavedChanges = true;
      categoryId = categoria.id!;
      categoryName = categoria.name;
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

  Future<void> _guardarMovimiento() async {
    final amountText = _amountController.text.trim();
    final noteText = _noteController.text.trim();
    final amount = double.tryParse(amountText.replaceAll(',', '.')) ?? 0.0;
    final titleText = _titleController.text.trim();

    if (amountText.isEmpty ||
        double.tryParse(amountText.replaceAll(',', '.')) == null ||
        double.parse(amountText.replaceAll(',', '.')) <= 0) {
      AppSnackbar.error(context, 'Ingrese un monto válido');
      return;
    }

    if (titleText.isEmpty) {
      AppSnackbar.error(context, 'Ingrese un título');
      return;
    }

    if (categoryId == -1) {
      AppSnackbar.warning(
        context,
        'Seleccione una categoría para el movimiento',
      );
      return;
    }

    final confirmed = await showConfirmAddDialog(
      context,
      titleModal: 'Confirmar movimiento',
      content: [
        Text('Título: $titleText'),
        Text('Monto: \$$amountText'),
        Text(
          'Tipo: ${tipoMovimiento == TipoMovimiento.gasto ? 'Gasto' : 'Ingreso'}',
        ),
        Text('Categoría: $categoryName'),
        Text('Fecha: ${formatDate(selectedDate)}'),
        if (_noteController.text.trim().isNotEmpty)
          Text('Nota: ${_noteController.text.trim()}'),
      ],
    );
    if (confirmed != true) return;

    setState(() {
      _hasUnsavedChanges = false;
    });

    // Crear el objeto Movimiento
    final movimiento = Movimiento(
      id: widget.mode == MovimientoFormMode.edit ? movementId : null,
      title: titleText,
      categoryID: categoryId,
      type: tipoMovimiento,
      ammount: amount,
      date: selectedDate,
      time: TimeOfDay.now(),
      note: noteText,
    );

    if (widget.mode == MovimientoFormMode.edit) {
      await context.read<AppState>().actualizarMovimiento(movimiento);
    } else {
      await context.read<AppState>().agregarMovimiento(movimiento);
    }

    if (mounted) {
      AppSnackbar.success(
        context,
        context.read<AppState>().transactionResultMessage,
      );
      Navigator.pop(context, true);
    }
  }

  Future<void> _eliminarMovimiento() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Eliminar movimiento',
      content:
          '¿Estás seguro de que deseas eliminar este movimiento?',
    );
    if (confirmed != true) return;

    await context.read<AppState>().eliminarMovimiento(movementId);

    if (mounted) {
      AppSnackbar.success(
        context,
        context.read<AppState>().transactionResultMessage,
      );
      Navigator.pop(context, true);
    }
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final appState = context.read<AppState>();
    categorias = appState.categorias;
    categoriasFiltradas = categorias
        .where((categoria) => categoria.movementType == tipoMovimiento)
        .toList();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.mode == MovimientoFormMode.create
                ? 'Agregar Movimiento'
                : 'Editar Movimiento',
          ),
          actions: [
            if (widget.mode == MovimientoFormMode.edit)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Eliminar',
                onPressed: () async {
                  await _eliminarMovimiento();
                },
              ),

            if (_hasUnsavedChanges)
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                tooltip: 'Guardar',
                onPressed: () async {
                  await _guardarMovimiento();
                },
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TipoMovimientoSelector(
                tipoMovimiento: tipoMovimiento,
                onChanged: _onChangeTipoMovimiento,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AmountInput(controller: _amountController),
                      WidgetsContainer(
                        title: 'Detalles del movimiento',
                        padding: const EdgeInsets.all(12),
                        children: [
                          TextInputCard(
                            textController: _titleController,
                            placeholder: 'Titulo del movimiento',
                            iconData: Icons.title,
                            iconColor: Colors.grey.shade600,
                          ),
                          InkWell(
                            onTap: () async => await _openCategoriasModal(context),
                            borderRadius: BorderRadius.circular(12),
                            child: DetailCategoryCard(
                              categoryName: 'Categoría',
                              categoryIcon: Icons.category,
                              iconColor: Colors.blue,
                              currentValue: categoryName,
                            ),
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
                          TextInputCard(
                            textController: _noteController,
                            placeholder: 'Agregar una nota (opcional)',
                            iconData: Icons.edit_note,
                            iconColor: Colors.grey.shade600,
                          ),
                        ],
                      ),
                      InfoTipeMovementCard(tipoMovimiento: tipoMovimiento),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openCategoriasModal(BuildContext context) async {
    await showModalBottomSheet(
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

            return ListTile(
              selected: categoria.id == categoryId,
              selectedTileColor: Colors.grey.shade200,
              selectedColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: IconContainer(
                icon: categoria.iconData,
                color: categoria.iconColor,
                size: 26,
              ),
              title: Text(
                categoria.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                categoria.description.isNotEmpty
                    ? categoria.description
                    : '(Sin descripción)',
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
      if (categoriaSeleccionada != null && categoriaSeleccionada is Categoria) {
        _onCategoriaSelected(categoriaSeleccionada);
      }
    });
  }
}
