import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/core/utils/icon_mapper.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';
import 'package:control_financiero/features/movimientos/models/detalle_movimiento.dart';
import 'package:control_financiero/features/movimientos/models/movimiento.dart';
import 'package:control_financiero/app/app_snackbar.dart';
import 'package:control_financiero/features/notificaciones/models/notificacion.dart';
import 'package:control_financiero/features/shared/widgets/icon_container.dart';
import 'package:control_financiero/features/shared/widgets/loading_screen.dart';
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
  final DetalleMovimiento? movimiento;
  final DateTime? fechaInicial;

  const MovimientoFormPage({
    super.key,
    required this.mode,
    this.movimiento,
    this.fechaInicial,
  });

  @override
  State<MovimientoFormPage> createState() => _MovimientoFormPageState();
}

class _MovimientoFormPageState extends State<MovimientoFormPage> {
  bool _canCloseWindow = false; // Variable para controlar el cierre sin cambios
  bool _isLoading = false; // Variable para controlar el estado de carga
  int categoryId = -1;
  int movementId = 0;
  IconData categoryIcon = Icons.category;
  Color categoryColor = Colors.blue;
  String categoryName = 'Sin categoría';
  TimeOfDay movementTime = TimeOfDay.now();
  TipoMovimiento tipoMovimiento = TipoMovimiento.gasto;
  bool isEnabledRepeatMovement = false;
  bool repeatMovement = false;
  String _action = "Guardando";
  late DateTime selectedDate;
  late List<Categoria> categorias;
  late List<Categoria> categoriasFiltradas;
  late DetalleMovimiento initialMovimiento;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    categorias = [];
    categoriasFiltradas = [];
    selectedDate = getCurrentDateWithoutTime();

    if (widget.mode == MovimientoFormMode.create &&
        widget.fechaInicial != null) {
      final fechaInicial = widget.fechaInicial ?? DateTime.now();
      final fechaNormalizada = normalizeDate(fechaInicial);
      selectedDate = !isCurrentMonth(fechaNormalizada)
          ? fechaNormalizada
          : getCurrentDateWithoutTime();
    }

    initialMovimiento = DetalleMovimiento(
      id: widget.movimiento?.id ?? 0,
      title: widget.movimiento?.title ?? '',
      amount: widget.movimiento?.amount ?? 0.0,
      movementType: widget.movimiento?.movementType ?? tipoMovimiento,
      date: widget.movimiento?.date ?? selectedDate,
      categoryIcon: widget.movimiento?.categoryIcon ?? categoryIcon,
      categoryColor: widget.movimiento?.categoryColor ?? categoryColor,
      categoryName: widget.movimiento?.categoryName ?? categoryName,
      isEnabledRepeatMovement:
          widget.movimiento?.isEnabledRepeatMovement ?? isEnabledRepeatMovement,
      repeatMovement: widget.movimiento?.repeatMovement ?? repeatMovement,
      categoryId: widget.movimiento?.categoryId ?? categoryId,
      time: widget.movimiento?.time ?? movementTime,
      note: widget.movimiento?.note ?? '',
    );

    _amountController.text = initialMovimiento.amount != 0.0
        ? initialMovimiento.amount.toString()
        : '';
    _titleController.text = initialMovimiento.title;
    _noteController.text = initialMovimiento.note;
    categoryId = initialMovimiento.categoryId ?? -1;
    selectedDate = initialMovimiento.date;
    movementTime = initialMovimiento.time ?? TimeOfDay.now();
    movementId = widget.movimiento?.id ?? 0;
    categoryName = initialMovimiento.categoryName ?? 'Sin categoría';
    categoryIcon = initialMovimiento.categoryIcon;
    categoryColor = initialMovimiento.categoryColor ?? Colors.blue;
    isEnabledRepeatMovement = initialMovimiento.isEnabledRepeatMovement;
    repeatMovement = initialMovimiento.repeatMovement;
    tipoMovimiento = initialMovimiento.movementType;
  }

  @override
  void dispose() {
    // Limpiar los controladores al desechar el widget
    _amountController.dispose();
    _noteController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  // Verificar si existe un cambio en los valores del formulario con respecto a los valores iniciales
  bool _checkForChanges() {
    if (_canCloseWindow) return true;

    final original = initialMovimiento;
    final current = DetalleMovimiento(
      id: movementId,
      title: _titleController.text.trim(),
      amount:
          double.tryParse(_amountController.text.trim().replaceAll(',', '.')) ??
          0.0,
      movementType: tipoMovimiento,
      date: selectedDate,
      categoryName: categoryName,
      categoryIcon: categoryIcon,
      categoryColor: categoryColor,
      categoryId: categoryId,
      time: movementTime,
      note: _noteController.text.trim(),
      isEnabledRepeatMovement: isEnabledRepeatMovement,
      repeatMovement: repeatMovement,
    );
    return original != current;
  }

  void _onChangeTipoMovimiento(TipoMovimiento newTipoMovimiento) {
    if (newTipoMovimiento == tipoMovimiento) return;

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
      categoryId = categoria.id!;
      categoryName = categoria.name;
      categoryIcon = categoria.iconData;
      categoryColor = categoria.iconColor;
      isEnabledRepeatMovement = categoria.enabledRepeatMovement;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final currentDay = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(currentDay.year - 3),
      lastDate: DateTime(currentDay.year, currentDay.month, currentDay.day),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _guardarMovimiento() async {
    final appState = context.read<AppState>();
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

    // Si el movimiento tiene activado los movimientos recurrentes y se usa una categoria que no los permite, indicar que se desactivaran los movimientos recurrentes
    if (repeatMovement && !isEnabledRepeatMovement) {
      final shouldContinue = await showConfirmDialog(
        context,
        title: 'Desactivar movimiento recurrente',
        content:
            'La categoría seleccionada no permite movimientos recurrentes. ¿Desea continuar y desactivar esta opción?',
      );

      if (shouldContinue != true) {
        return;
      }

      setState(() {
        repeatMovement = false;
      });
    }

    if (!mounted) return;

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

        if (repeatMovement) Text('El movimiento se repetirá mensualmente'),
      ],
    );
    if (confirmed != true) return;

    setState(() {
      _action = "Guardando";
      _canCloseWindow = true; // Permitir cerrar sin preguntar por cambios
      _isLoading = true; // Activar indicador de carga
    });

    // Crear el objeto Movimiento
    final movimiento = Movimiento(
      id: widget.mode == MovimientoFormMode.edit ? movementId : null,
      title: titleText,
      categoryID: categoryId,
      amount: amount,
      date: selectedDate,
      time: widget.mode == MovimientoFormMode.edit
          ? movementTime
          : TimeOfDay.now(),
      note: noteText,
      repeatMovement: repeatMovement,
    );

    if (widget.mode == MovimientoFormMode.edit) {
      await appState.actualizarMovimiento(movimiento);
    } else {
      await appState.agregarMovimiento(movimiento);
    }

    final notificacion = Notificacion(
      title: 'Creacion de movimiento',
      description: 'Creaste un nuevo movimiento',
      iconName: IconMapper.toName(Icons.compare_arrows_outlined),
      iconColorValue: Colors.blue.value,
      createdAt: DateTime.now(),
    );

    await appState.insertarNotificacion(notificacion);

    if (!mounted) return;
    setState(() {
      _isLoading = false; // Desactivar indicador de carga
    });

    if (!appState.transactionSuccess) {
      AppSnackbar.error(context, appState.transactionResultMessage);
      setState(() {
        _canCloseWindow = false; // Volver a bloquear el cierre sin guardar
      });
      return;
    }

    AppSnackbar.success(context, appState.transactionResultMessage);

    Navigator.pop(context, true);
  }

  Future<void> _eliminarMovimiento() async {
    final appState = context.read<AppState>();
    final confirmed = await showConfirmDialog(
      context,
      title: 'Eliminar movimiento',
      content: '¿Estás seguro de que deseas eliminar este movimiento?',
    );
    if (confirmed != true) return;
    setState(() {
      _action = "Eliminando";
      _canCloseWindow = true; // Permitir cerrar sin preguntar por cambios
      _isLoading = true; // Activar indicador de carga
    });

    await appState.eliminarMovimiento(movementId, categoryId);

    if (!mounted) return;
    setState(() {
      _isLoading = false; // Desactivar indicador de carga
    });

    if (!appState.transactionSuccess) {
      AppSnackbar.error(context, appState.transactionResultMessage);
      setState(() {
        _canCloseWindow = false; // Volver a bloquear el cierre sin guardar
      });
      return;
    }

    AppSnackbar.success(context, appState.transactionResultMessage);

    Navigator.pop(context, true);
  }

  void _toggleRepeatMovement(bool value) {
    setState(() {
      repeatMovement = value;
    });
  }

  Future<bool> _onWillPop() async {
    final hasChanges = _checkForChanges();
    if (!hasChanges) return true;

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
          title: Text(
            widget.mode == MovimientoFormMode.create
                ? 'Agregar Movimiento'
                : 'Editar Movimiento',
          ),
          actions: [
            if (widget.mode == MovimientoFormMode.edit)
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: _isLoading ? Colors.grey : Colors.red,
                ),
                tooltip: 'Eliminar',
                onPressed: _isLoading
                    ? null
                    : () async {
                        await _eliminarMovimiento();
                      },
              ),

            IconButton(
              icon: Icon(
                Icons.check,
                color: _isLoading ? Colors.grey : Colors.green,
              ),
              tooltip: 'Guardar',
              onPressed: _isLoading
                  ? null
                  : () async {
                      await _guardarMovimiento();
                    },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
          child: _isLoading
              ? LoadingScreen(message: '$_action movimiento...')
              : Column(
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
                                  maxLines: 1,
                                  maxLength: 50,
                                ),
                                InkWell(
                                  onTap: () async =>
                                      await _openCategoriasModal(context),
                                  borderRadius: BorderRadius.circular(12),
                                  child: DetailCategoryCard(
                                    categoryName: 'Categoría',
                                    categoryIcon: categoryIcon,
                                    iconColor: categoryColor,
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
                                  maxLines: 3,
                                  maxLength: 200,
                                ),
                              ],
                            ),
                            if (isEnabledRepeatMovement)
                              WidgetsContainer(
                                title: 'Movimiento recurrente',
                                description:
                                    'Este movimiento se repetirá mensualmente en la fecha seleccionada.',
                                padding: const EdgeInsets.all(12),
                                children: [
                                  DetailCategoryCard(
                                    categoryName:
                                        'Repetir movimiento mensualmente',
                                    categoryIcon: Icons.repeat,
                                    iconColor: Colors.orange,
                                    trailing: Switch(
                                      value: repeatMovement,
                                      onChanged: _toggleRepeatMovement,
                                    ),
                                  ),
                                ],
                              ),
                            InfoTipeMovementCard(
                              tipoMovimiento: tipoMovimiento,
                            ),
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
