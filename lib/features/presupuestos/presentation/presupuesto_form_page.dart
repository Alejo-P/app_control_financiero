// ignore_for_file: deprecated_member_use

import 'package:control_financiero/app/app_snackbar.dart';
import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/constants/notificacion_constants.dart';
import 'package:control_financiero/core/constants/presupuesto_constants.dart';
import 'package:control_financiero/core/utils/color_utils.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/core/utils/icon_mapper.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';
import 'package:control_financiero/features/movimientos/widgets/ammount_input.dart';
import 'package:control_financiero/features/notificaciones/models/notificacion.dart';
import 'package:control_financiero/features/presupuestos/models/detalle_presupuesto.dart';
import 'package:control_financiero/features/presupuestos/models/ingreso_presupuestado.dart';
import 'package:control_financiero/features/presupuestos/models/presupuesto_form_args.dart';
import 'package:control_financiero/features/shared/widgets/category_dropdown.dart';
import 'package:control_financiero/features/shared/widgets/custom_button.dart';
import 'package:control_financiero/features/presupuestos/models/presupuesto.dart';
import 'package:control_financiero/features/shared/widgets/confirm_dialog.dart';
import 'package:control_financiero/features/shared/widgets/loading_screen.dart';
import 'package:control_financiero/features/shared/widgets/not_found_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PresupuestoFormPage extends StatefulWidget {
  const PresupuestoFormPage({super.key});

  @override
  State<PresupuestoFormPage> createState() => _PresupuestoFormPageState();
}

class _PresupuestoFormPageState extends State<PresupuestoFormPage> {
  DetallePresupuesto? detallePresupuesto;
  PresupuestoFormMode modo = PresupuestoFormMode.create;
  bool isViewOnly = false;
  bool _enableSaveButton = false;
  bool _loaded = false;
  bool _isLoading = false;
  String _action = "Guardando";
  bool repeatBudget = false;
  DateTime fechaPresupuesto = currentDateTime;
  int categoriaSeleccionada = -1;
  int presupuestoId = 0;
  IngresoPresupuestado ingresoDisponible = IngresoPresupuestado(
    monto: 0.0,
    fecha: DateTime.now(),
  );
  final _presupuestoAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _presupuestoAmountController.addListener(_checkEnableSaveButton);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;

    final args =
        ModalRoute.of(context)!.settings.arguments as PresupuestoFormArgs;
    final id = args.id;
    final budgetedIncome = args.budgetedIncome;
    isViewOnly = args.viewOnly;
    fechaPresupuesto = args.fechaPresupuesto ?? DateTime.now();

    _load(id, budgetedIncome);

    _loaded = true;
  }

  Future<void> _load(int id, IngresoPresupuestado budgetedIncome) async {
    final appState = context.read<AppState>();

    setState(() {
      _isLoading = true;
      _action = "Cargando";
    });

    final result = await appState.obtenerDetallePresupuestoPorId(id);
    final sumaPresupuestos = await appState.obtenerSumaPresupuestosPorFecha(
      result?.fechaPresupuesto ?? fechaPresupuesto,
    );
    if (result != null) {
      _presupuestoAmountController.text = result.montoPresupuestado != 0.0
          ? result.montoPresupuestado.toStringAsFixed(2)
          : '';
      presupuestoId = result.id ?? 0;
      categoriaSeleccionada = result.categoriaId;
      fechaPresupuesto = result.fechaPresupuesto;
      repeatBudget = result.esRecurrente;
      _presupuestoAmountController.text = result.montoPresupuestado > 0
          ? result.montoPresupuestado.toStringAsFixed(2)
          : '';
    }
    if (!mounted) return;

    setState(() {
      ingresoDisponible = IngresoPresupuestado(
        monto: budgetedIncome.monto - sumaPresupuestos,
        fecha: fechaPresupuesto,
      );
      detallePresupuesto = result;
      _isLoading = false;

      modo = result != null && id != -1
          ? PresupuestoFormMode.edit
          : PresupuestoFormMode.create;
    });
    _checkEnableSaveButton();
  }

  @override
  void dispose() {
    _presupuestoAmountController.dispose();
    super.dispose();
  }

  bool _checkForChanges() {
    final categorias = modo == PresupuestoFormMode.create
        ? categoriasSinPresupuesto
        : [
            gategoriasSoloGastos.firstWhere(
              (cat) => cat.id == detallePresupuesto!.categoriaId,
              orElse: () => throw Exception('Categoría no encontrada'),
            ),
          ];

    final current = DetallePresupuesto(
      id: detallePresupuesto?.id,
      categoria: detallePresupuesto?.categoria ?? '',
      categoriaId: categoriaSeleccionada,
      icon: detallePresupuesto?.icon ?? Icons.category,
      iconColor: detallePresupuesto?.iconColor ?? Colors.grey,
      fechaPresupuesto: fechaPresupuesto,
      montoPresupuestado:
          double.tryParse(_presupuestoAmountController.text.trim()) ?? 0.0,
      esRecurrente: repeatBudget,
    );
    final original =
        detallePresupuesto ??
        DetallePresupuesto(
          categoria: '',
          categoriaId: categorias.isNotEmpty ? categorias.first.id! : -1,
          icon: Icons.category,
          iconColor: Colors.grey,
          fechaPresupuesto: fechaPresupuesto,
          montoPresupuestado: 0.0,
          esRecurrente: false,
        );

    return original != current;
  }

  void _checkEnableSaveButton() {
    final hasChanges = _checkForChanges();
    setState(() {
      _enableSaveButton = hasChanges;
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

  void _onChangeCategoria(int categoriaId) {
    setState(() {
      categoriaSeleccionada = categoriaId;
    });
    _checkEnableSaveButton();
  }

  List<Categoria> get gategoriasSoloGastos {
    final appState = context.read<AppState>();
    return appState.categorias
        .where((cat) => cat.movementType == TipoMovimiento.gasto)
        .toList();
  }

  List<Categoria> get categoriasSinPresupuesto {
    final appState = context.read<AppState>();
    final categoriasConPresupuesto = appState.presupuestos
        .map((presupuesto) => presupuesto.categoryId)
        .toSet();

    return appState.categorias
        .where(
          (cat) =>
              cat.movementType == TipoMovimiento.gasto &&
              !categoriasConPresupuesto.contains(cat.id),
        )
        .toList();
  }

  Future<void> _guardarPresupuesto() async {
    final appState = context.read<AppState>();
    final amountText = _presupuestoAmountController.text.trim();
    final value = double.tryParse(amountText.replaceAll(',', '.')) ?? 0.0;

    if (value <= 0) {
      AppSnackbar.error(
        context,
        'El monto del presupuesto debe ser mayor a 0.',
      );
      return;
    }

    if (value > ingresoDisponible.monto && modo == PresupuestoFormMode.create) {
      AppSnackbar.error(
        context,
        'El monto del presupuesto no puede exceder el ingreso disponible.',
      );
      return;
    }

    // Si estamos editando un presupuesto, permitir que el monto exceda el ingreso disponible solo si el nuevo monto es menor o igual al monto presupuestado originalmente (para evitar que el usuario reduzca el ingreso disponible al editar un presupuesto existente)
    if (modo == PresupuestoFormMode.edit &&
        value >
            ingresoDisponible.monto + detallePresupuesto!.montoPresupuestado) {
      AppSnackbar.error(
        context,
        'El monto del presupuesto no puede exceder el ingreso disponible.',
      );
      return;
    }

    if (ingresoDisponible.monto <= 0 && modo == PresupuestoFormMode.create) {
      AppSnackbar.error(
        context,
        'El ingreso presupuestado debe ser mayor a 0.',
      );
      return;
    }

    if (categoriaSeleccionada == -1) {
      AppSnackbar.error(context, 'Por favor, selecciona una categoría.');
      return;
    }

    final confirm = await showConfirmDialog(
      context,
      title: modo == PresupuestoFormMode.create
          ? 'Crear presupuesto'
          : 'Actualizar presupuesto',
      content: modo == PresupuestoFormMode.create
          ? '¿Deseas crear este presupuesto?'
          : '¿Deseas actualizar este presupuesto?',
    );
    if (confirm != true) return;
    setState(() {
      _action = "Guardando";
      _isLoading = true;
    });

    final nuevoPresupuesto = Presupuesto(
      id: modo == PresupuestoFormMode.edit ? presupuestoId : null,
      categoryId: categoriaSeleccionada,
      amount: value,
      date: fechaPresupuesto,
      repeatBudget: repeatBudget,
    );

    final result = modo == PresupuestoFormMode.create
        ? await appState.agregarPresupuesto(nuevoPresupuesto)
        : await appState.actualizarPresupuesto(nuevoPresupuesto);

    final notificacion = Notificacion(
      title: modo == PresupuestoFormMode.create
          ? 'Presupuesto creado'
          : 'Presupuesto actualizado',
      description:
          'El presupuesto para ${formatMonthYear(fechaPresupuesto)} ha sido ${modo == PresupuestoFormMode.create ? 'creado' : 'actualizado'} exitosamente.',
      type: TipoNotificacion.presupuesto,
      objectId: result ?? presupuestoId,
      iconName: IconMapper.toName(Icons.account_balance_wallet_rounded),
      iconColorValue: Colors.green.value,
      createdAt: currentDateTime,
      extraData: {
        'Categoria': gategoriasSoloGastos
            .firstWhere((cat) => cat.id == categoriaSeleccionada)
            .name,
        'Monto presupuestado': value,
        'Repetir mensualmente': repeatBudget ? 'Sí' : 'No',
      },
    );
    await appState.insertarNotificacion(notificacion);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      categoriaSeleccionada = -1;
      _presupuestoAmountController.clear();
    });

    if (!appState.transactionSuccess) {
      AppSnackbar.error(context, appState.transactionResultMessage);
      return;
    }

    AppSnackbar.success(context, appState.transactionResultMessage);

    Navigator.pop(context, true);
  }

  Future<void> _eliminarPresupuesto() async {
    final appState = context.read<AppState>();

    final shouldDelete = await showConfirmDialog(
      context,
      title: 'Eliminar presupuesto',
      content: '¿Estás seguro de que deseas eliminar este presupuesto?',
    );

    if (shouldDelete != true) return;
    setState(() {
      _action = "Eliminando";
      _isLoading = true;
    });

    await appState.eliminarPresupuesto(presupuestoId);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    if (!appState.transactionSuccess) {
      AppSnackbar.error(context, appState.transactionResultMessage);
      return;
    }

    AppSnackbar.success(context, appState.transactionResultMessage);

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final categorias = modo == PresupuestoFormMode.create
        ? categoriasSinPresupuesto
        : [
            gategoriasSoloGastos.firstWhere(
              (cat) => cat.id == detallePresupuesto!.categoriaId,
              orElse: () => throw Exception('Categoría no encontrada'),
            ),
          ];

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final [r, g, b] = getRGBFromColor(colorScheme.primary);
    final primaryColorWithOpacity = Color.fromRGBO(r, g, b, 0.1);

    if (categorias.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            isViewOnly
                ? 'Detalle de presupuesto'
                : modo == PresupuestoFormMode.create
                ? 'Nuevo Presupuesto'
                : 'Editar Presupuesto',
          ),
        ),
        body: const Center(
          child: Text(
            'No hay categorías disponibles. Por favor, crea una categoría primero.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (categoriaSeleccionada == -1) {
      categoriaSeleccionada = categorias.first.id!;
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isViewOnly
                ? 'Detalle de presupuesto'
                : modo == PresupuestoFormMode.create
                ? 'Nuevo Presupuesto'
                : 'Editar Presupuesto',
          ),
          actions: [
            if (modo == PresupuestoFormMode.edit && !isViewOnly)
              IconButton(
                tooltip: 'Eliminar Presupuesto',
                icon: Icon(
                  Icons.delete,
                  color: _isLoading ? Colors.grey : Colors.red,
                ),
                onPressed: _isLoading
                    ? null
                    : () async {
                        await _eliminarPresupuesto();
                      },
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
          child: _isLoading
              ? LoadingScreen(message: '$_action presupuesto...')
              : detallePresupuesto == null &&
                    (modo == PresupuestoFormMode.edit || isViewOnly)
              ? NotFoundState(
                  title: 'Presupuesto no encontrado',
                  message:
                      'El presupuesto que buscas no existe o fue eliminado.',
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Periodo del presupuesto',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: const Text(
                                    'Ajustando el presupuesto para la siguiente fecha:',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  formatMonthYear(fechaPresupuesto),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 12,
                              ),
                              child: const Divider(),
                            ),
                            Text(
                              modo == PresupuestoFormMode.create
                                  ? 'Selecciona una categoría'
                                  : 'Categoría del presupuesto',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              modo == PresupuestoFormMode.create
                                  ? 'El presupuesto se asignará a la categoría seleccionada.'
                                  : 'El presupuesto actual está asignado a esta categoría.',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                CategoryDropdown(
                                  categorias: categorias,
                                  selectedValue: categoriaSeleccionada,
                                  onChangeCategory: _onChangeCategoria,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (!isViewOnly)
                              Card(
                                color: primaryColorWithOpacity,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  side: BorderSide.none,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.wallet_rounded,
                                        size: 40,
                                        color: colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Monto disponible para este presupuesto',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: colorScheme.primary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '\$${ingresoDisponible.monto.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: colorScheme.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 20),
                            const Text(
                              'Monto del presupuesto',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            AmountInput(
                              controller: _presupuestoAmountController,
                              fontSize: 40,
                              isEditable:
                                  (ingresoDisponible.monto > 0 ||
                                      modo == PresupuestoFormMode.edit) &&
                                  !isViewOnly,
                              showLabel: false,
                            ),

                            if (!isViewOnly)
                              CustomButton(
                                text: modo == PresupuestoFormMode.create
                                    ? 'Guardar'
                                    : 'Actualizar',
                                icon: Icons.save,
                                width: WidgetWidth.fullWidth,
                                onTap: (_isLoading || !_enableSaveButton)
                                    ? null
                                    : _guardarPresupuesto,
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
}
