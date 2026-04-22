// ignore_for_file: deprecated_member_use

import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/constants/notificacion_constants.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/core/utils/icon_mapper.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';
import 'package:control_financiero/features/movimientos/models/detalle_movimiento.dart';
import 'package:control_financiero/features/movimientos/models/movimiento.dart';
import 'package:control_financiero/app/app_snackbar.dart';
import 'package:control_financiero/features/movimientos/models/movimiento_form_args.dart';
import 'package:control_financiero/features/notificaciones/models/budget_notification_event.dart';
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
  final DateTime? fechaInicial;

  const MovimientoFormPage({super.key, this.fechaInicial});

  @override
  State<MovimientoFormPage> createState() => _MovimientoFormPageState();
}

class _MovimientoFormPageState extends State<MovimientoFormPage> {
  DetalleMovimiento? detalleMovimiento;
  MovimientoFormMode modo = MovimientoFormMode.create;
  bool isViewOnly = false;
  bool _isLoading = false; // Variable para controlar el estado de carga
  bool _loaded = false;
  bool _enableSaveButton = false;
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
  List<Categoria> categorias = [];
  List<Categoria> categoriasFiltradas = [];
  DateTime selectedDate = getCurrentDateWithoutTime();
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _amountController.addListener(_checkEnableSaveButton);
    _noteController.addListener(_checkEnableSaveButton);
    _titleController.addListener(_checkEnableSaveButton);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;

    final args =
        ModalRoute.of(context)!.settings.arguments as MovimientoFormArgs;
    final id = args.id;
    final fechaInicial = args.fechaInicial;
    isViewOnly = args.viewOnly;

    if (modo == MovimientoFormMode.create && fechaInicial != null) {
      final fechaNormalizada = normalizeDate(fechaInicial);
      selectedDate = !isCurrentMonth(fechaNormalizada)
          ? fechaNormalizada
          : getCurrentDateWithoutTime();
    }

    if (id != -1) {
      _load(id);
    }

    _loaded = true;
  }

  Future<void> _load(int id) async {
    final appState = context.read<AppState>();

    setState(() {
      _isLoading = true;
      _action = "Cargando";
    });

    final result = await appState.obtenerDetalleMovimientoPorId(id);
    if (result != null) {
      _amountController.text = result.amount != 0.0
          ? result.amount.toString()
          : '';
      _titleController.text = result.title;
      _noteController.text = result.note;
      categoryId = result.categoryId ?? -1;
      selectedDate = result.date;
      movementTime = result.time ?? TimeOfDay.now();
      movementId = result.id ?? 0;
      categoryName = result.categoryName ?? 'Sin categoría';
      categoryIcon = result.categoryIcon;
      categoryColor = result.categoryColor ?? Colors.blue;
      isEnabledRepeatMovement = result.isEnabledRepeatMovement;
      repeatMovement = result.repeatMovement;
      tipoMovimiento = result.movementType;
    }

    if (!mounted) return;

    setState(() {
      detalleMovimiento = result;
      _isLoading = false;

      modo = result != null && id != -1
          ? MovimientoFormMode.edit
          : MovimientoFormMode.create;
    });
    _checkEnableSaveButton();
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
    final original =
        detalleMovimiento ??
        DetalleMovimiento(
          title: '',
          amount: 0.0,
          movementType: TipoMovimiento.gasto,
          date: selectedDate,
          categoryName: 'Sin categoría',
          categoryIcon: Icons.category,
          categoryColor: Colors.blue,
          categoryId: -1,
          time: movementTime,
          note: '',
          isEnabledRepeatMovement: false,
          repeatMovement: false,
        );

    return (original != current);
  }

  void _checkEnableSaveButton() {
    final hasChanges = _checkForChanges();
    setState(() {
      _enableSaveButton = hasChanges;
    });
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
    _checkEnableSaveButton();
  }

  void _onCategoriaSelected(Categoria categoria) {
    setState(() {
      categoryId = categoria.id!;
      categoryName = categoria.name;
      categoryIcon = categoria.iconData;
      categoryColor = categoria.iconColor;
      isEnabledRepeatMovement = categoria.enabledRepeatMovement;
    });
    _checkEnableSaveButton();
  }

  Future<void> _selectDate(BuildContext context) async {
    final currentDay = currentDateTime;
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
      _checkEnableSaveButton();
    }
  }

  Future<void> _guardarMovimiento() async {
    if (!_formKey.currentState!.validate()) {
      AppSnackbar.error(
        context,
        'Por favor corrige los errores en el formulario',
      );
      return;
    }

    final appState = context.read<AppState>();
    final amountText = _amountController.text.trim();
    final noteText = _noteController.text.trim();
    final amount = double.tryParse(amountText.replaceAll(',', '.')) ?? 0.0;
    final titleText = _titleController.text.trim();

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
        if (noteText.isNotEmpty) Text('Nota: $noteText'),

        if (repeatMovement) Text('El movimiento se repetirá mensualmente'),
      ],
    );
    if (confirmed != true) return;

    setState(() {
      _action = "Guardando";
      _isLoading = true; // Activar indicador de carga
    });

    // Crear el objeto Movimiento
    final movimiento = Movimiento(
      id: modo == MovimientoFormMode.edit ? movementId : null,
      title: titleText,
      categoryID: categoryId,
      amount: amount,
      date: selectedDate,
      time: modo == MovimientoFormMode.edit ? movementTime : TimeOfDay.now(),
      note: noteText,
      repeatMovement: repeatMovement,
    );

    final isUpdateMovement = modo == MovimientoFormMode.edit;
    final result = isUpdateMovement
        ? await appState.actualizarMovimiento(movimiento)
        : await appState.agregarMovimiento(movimiento);

    if (!mounted) return;

    final notificacion = Notificacion(
      title: '${isUpdateMovement ? 'Actualizacion' : 'Creacion'} de movimiento',
      description:
          'El movimiento "${movimiento.title}" ha sido ${isUpdateMovement ? 'actualizado' : 'creado'} exitosamente.',
      type: TipoNotificacion.movimiento,
      objectId: result ?? movimiento.id!,
      iconName: IconMapper.toName(Icons.compare_arrows_outlined),
      iconColorValue: Colors.blue.value,
      createdAt: currentDateTime,
      extraData: {
        "Categoría": categoryName,
        "Concepto": movimiento.title,
        'Monto': movimiento.amount,
        'Nota': movimiento.note.isNotEmpty ? movimiento.note : '(Sin nota)',
        'Fecha creacion': formatDate(movimiento.date),
        'Hora creacion': movimiento.time.format(context),
        'Repetir mensualmente': movimiento.repeatMovement ? 'Sí' : 'No',
      },
    );
    await appState.insertarNotificacion(notificacion);

    final porcentagesPresupuesto = await appState.getThresholdsToNotify(
      movimiento.categoryID,
      movimiento.date,
    );

    if (porcentagesPresupuesto.isNotEmpty) {
      for (final porcentaje in porcentagesPresupuesto) {
        await appState.insertarNotificacion(
          Notificacion(
            title: 'Alerta de presupuesto',
            description:
                'Has alcanzado el $porcentaje% de tu presupuesto para la categoría $categoryName.',
            type: TipoNotificacion.presupuesto,
            iconName: IconMapper.toName(Icons.warning_amber_outlined),
            iconColorValue: Colors.red.value,
            createdAt: currentDateTime,
            extraData: {
              'Categoría': categoryName,
              'Porcentaje alcanzado': '$porcentaje%',
              'Fecha': formatDate(movimiento.date),
            },
          ),
          showNotification: true,
        );

        await appState.insertarBudgetNotificationEvent(
          BudgetNotificationEvent(
            categoryId: movimiento.categoryID,
            year: movimiento.date.year,
            month: movimiento.date.month,
            threshold: porcentaje,
            createdAt: currentDateTime,
          ),
        );
      }
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false; // Desactivar indicador de carga
    });

    if (!appState.transactionSuccess) {
      AppSnackbar.error(context, appState.transactionResultMessage);
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
      _isLoading = true; // Activar indicador de carga
    });

    await appState.eliminarMovimiento(movementId, categoryId);

    if (!mounted) return;
    setState(() {
      _isLoading = false; // Desactivar indicador de carga
    });

    if (!appState.transactionSuccess) {
      AppSnackbar.error(context, appState.transactionResultMessage);
      return;
    }

    AppSnackbar.success(context, appState.transactionResultMessage);

    Navigator.pop(context, true);
  }

  void _toggleRepeatMovement(bool value) {
    setState(() {
      repeatMovement = value;
    });
    _checkEnableSaveButton();
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
            isViewOnly
                ? 'Detalle del movimiento'
                : modo == MovimientoFormMode.create
                ? 'Agregar Movimiento'
                : 'Editar Movimiento',
          ),
          actions: [
            if (modo == MovimientoFormMode.edit && !isViewOnly)
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

            if (!isViewOnly)
              IconButton(
                icon: Icon(
                  Icons.check,
                  color: (_isLoading || !_enableSaveButton)
                      ? Colors.grey
                      : Colors.green,
                ),
                tooltip: 'Guardar',
                onPressed: _isLoading || !_enableSaveButton
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
              : detalleMovimiento == null && modo == MovimientoFormMode.edit
              ? _EmptyMovimiento()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TipoMovimientoSelector(
                      tipoMovimiento: tipoMovimiento,
                      onChanged: _onChangeTipoMovimiento,
                      isViewOnly: isViewOnly,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AmountInput(
                                controller: _amountController,
                                isEditable: !isViewOnly,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'El monto es obligatorio';
                                  }
                                  final amount = double.tryParse(
                                    value.trim().replaceAll(',', '.'),
                                  );
                                  if (amount == null || amount <= 0) {
                                    return 'Ingrese un monto válido';
                                  }
                                  return null;
                                },
                              ),
                              WidgetsContainer(
                                title: 'Detalles del movimiento',
                                padding: const EdgeInsets.all(12),
                                children: [
                                  TextInputCard(
                                    textController: _titleController,
                                    placeholder: 'Titulo del movimiento',
                                    isEditable: !isViewOnly,
                                    iconData: Icons.title,
                                    iconColor: Colors.grey.shade600,
                                    maxLines: 1,
                                    maxLength: 50,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'El título es obligatorio';
                                      }
                                      return null;
                                    },
                                  ),
                                  InkWell(
                                    onTap: () async => isViewOnly
                                        ? null
                                        : await _openCategoriasModal(context),
                                    borderRadius: BorderRadius.circular(12),
                                    child: DetailCategoryCard(
                                      categoryName: 'Categoría',
                                      categoryIcon: categoryIcon,
                                      iconColor: categoryColor,
                                      currentValue: categoryName,
                                      showArrow: !isViewOnly,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => isViewOnly
                                        ? null
                                        : _selectDate(context),
                                    borderRadius: BorderRadius.circular(12),
                                    child: DetailCategoryCard(
                                      categoryName: 'Fecha',
                                      categoryIcon: Icons.calendar_today,
                                      iconColor: Colors.purple,
                                      currentValue: formatDate(selectedDate),
                                      showArrow: !isViewOnly,
                                    ),
                                  ),
                                  TextInputCard(
                                    textController: _noteController,
                                    placeholder: 'Agregar una nota (opcional)',
                                    isEditable: !isViewOnly,
                                    iconData: Icons.edit_note,
                                    iconColor: Colors.grey.shade600,
                                    maxLines: 3,
                                    maxLength: 200,
                                    validator: (value) {
                                      if (value != null && value.length > 200) {
                                        return 'La nota no puede exceder los 200 caracteres';
                                      }
                                      return null;
                                    },
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
                                        onChanged: isViewOnly
                                            ? null
                                            : _toggleRepeatMovement,
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

class _EmptyMovimiento extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.sentiment_dissatisfied_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No se encontro el movimiento.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          Text(
            'Posiblemente se busco un movimiento que no existe o fue eliminado.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
