import 'package:control_financiero/app/app_snackbar.dart';
import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/constants/presupuesto_constants.dart';
import 'package:control_financiero/core/utils/color_utils.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';
import 'package:control_financiero/features/movimientos/models/movimiento.dart';
import 'package:control_financiero/features/movimientos/widgets/ammount_input.dart';
import 'package:control_financiero/features/movimientos/widgets/transactions_container.dart';
import 'package:control_financiero/features/presupuestos/models/detalle_presupuesto.dart';
import 'package:control_financiero/features/presupuestos/models/ingreso_presupuestado.dart';
import 'package:control_financiero/features/shared/widgets/grid_container.dart';
import 'package:control_financiero/features/presupuestos/models/presupuesto.dart';
import 'package:control_financiero/features/presupuestos/widgets/category_button.dart';
import 'package:control_financiero/features/shared/widgets/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PresupuestoFormPage extends StatefulWidget {
  final PresupuestoFormMode mode;
  final DetallePresupuesto? presupuesto;
  final double? ingresoPresupuestado;

  const PresupuestoFormPage({
    super.key,
    required this.mode,
    this.presupuesto,
    this.ingresoPresupuestado,
  });

  @override
  State<PresupuestoFormPage> createState() => _PresupuestoFormPageState();
}

class _PresupuestoFormPageState extends State<PresupuestoFormPage> {
  bool _hasUnsavedChanges = false;
  List<Movimiento> movimientos = [];
  final meses = monthNames;
  final anios = generateYearList(DateTime.now().year, 10);
  late DateTime fechaPresupuesto;
  late int categoriaSeleccionada;
  int presupuestoId = 0;
  double ingresoPresupuestadoTotal = 0.0;
  late IngresoPresupuestado ingresoDisponible;
  final _presupuestoAmountController = TextEditingController();
  final _ingresoPresupuestadoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    //late AppState appState;
    categoriaSeleccionada = -1;
    fechaPresupuesto = DateTime.now();

    if (widget.mode == PresupuestoFormMode.create) {
      fechaPresupuesto = context.read<AppState>().selectedBudgetMonth;
    }

    if (widget.mode == PresupuestoFormMode.edit && widget.presupuesto != null) {
      categoriaSeleccionada = widget.presupuesto!.categoriaId;
      movimientos = widget.presupuesto!.movimientos;
      fechaPresupuesto = widget.presupuesto!.fechaPresupuesto;
      presupuestoId = widget.presupuesto!.idPresupuesto;
      _presupuestoAmountController.text = widget.presupuesto!.montoPresupuestado
          .toString();
    }

    ingresoDisponible = IngresoPresupuestado(
      monto: widget.ingresoPresupuestado ?? 0.0,
      fecha: fechaPresupuesto,
    );

    ingresoPresupuestadoTotal = widget.presupuesto?.totalPresupuestado ?? 0.0;
    _ingresoPresupuestadoController.text = ingresoPresupuestadoTotal
        .toStringAsFixed(2);

    _presupuestoAmountController.addListener(_markAsDirty);
    _ingresoPresupuestadoController.addListener(_markAsDirty);
  }

  @override
  void dispose() {
    _presupuestoAmountController.dispose();
    _ingresoPresupuestadoController.dispose();
    super.dispose();
  }

  void _markAsDirty() {
    // Si el campo esta vacío, no marcar como sucio
    if (_presupuestoAmountController.text.isEmpty &&
        _ingresoPresupuestadoController.text.isEmpty) {
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

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

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

  Future<void> _guardarIngresoPresupuesto() async {
    // Lógica para guardar el ingreso presupuestado
    final appState = context.read<AppState>();
    final amountText = _ingresoPresupuestadoController.text.trim();
    final value = double.tryParse(amountText.replaceAll(',', '.')) ?? 0.0;
    if (value <= 0) {
      AppSnackbar.error(
        context,
        'El ingreso presupuestado debe ser mayor a 0.',
      );
      return;
    }

    final nuevoIngresoPresupuestado = IngresoPresupuestado(
      monto: value,
      fecha: fechaPresupuesto,
    );

    await appState.setIngresoPresupuestado(nuevoIngresoPresupuestado);
    setState(() {
      ingresoDisponible = IngresoPresupuestado(
        monto: appState.totalIngresoPresupuestado ?? value,
        fecha: fechaPresupuesto,
      );
      ingresoPresupuestadoTotal =
          appState.ingresoPresupuestado?.monto ?? value;
    });

    if (!mounted) return;

    if (!appState.transactionSuccess) {
      AppSnackbar.error(context, appState.transactionResultMessage);
      return;
    }

    AppSnackbar.success(context, appState.transactionResultMessage);

    Navigator.pop(context, true);
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

    if (value > ingresoDisponible.monto) {
      AppSnackbar.error(
        context,
        'El monto del presupuesto no puede exceder el ingreso disponible.',
      );
      return;
    }

    if (ingresoDisponible.monto <= 0) {
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
      title: widget.mode == PresupuestoFormMode.create
          ? 'Crear presupuesto'
          : 'Actualizar presupuesto',
      content: widget.mode == PresupuestoFormMode.create
          ? '¿Deseas crear este presupuesto?'
          : '¿Deseas actualizar este presupuesto?',
    );
    if (confirm != true) return;

    final nuevoPresupuesto = Presupuesto(
      id: widget.mode == PresupuestoFormMode.edit ? presupuestoId : null,
      categoryId: categoriaSeleccionada,
      amount: value,
      date: fechaPresupuesto,
    );

    if (widget.mode == PresupuestoFormMode.create) {
      await appState.agregarPresupuesto(nuevoPresupuesto);
    } else if (widget.mode == PresupuestoFormMode.edit) {
      await appState.actualizarPresupuesto(nuevoPresupuesto);
    }

    if (!mounted) return;

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

    await appState.eliminarPresupuesto(presupuestoId);

    if (!mounted) return;

    if (!appState.transactionSuccess) {
      AppSnackbar.error(context, appState.transactionResultMessage);
      return;
    }

    AppSnackbar.success(context, appState.transactionResultMessage);

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final categorias = widget.mode == PresupuestoFormMode.create
        ? categoriasSinPresupuesto
        : [
            gategoriasSoloGastos.firstWhere(
              (cat) => cat.id == widget.presupuesto!.categoriaId,
              orElse: () => throw Exception('Categoría no encontrada'),
            ),
          ];
    final appState = context.watch<AppState>();
    final fechasMovimientos = appState.uniqueBudgetMovementDates;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final [r, g, b] = getRGBFromColor(colorScheme.primary);
    final primaryColorWithOpacity = Color.fromRGBO(r, g, b, 0.1);

    if (categorias.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.mode == PresupuestoFormMode.create
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
            widget.mode == PresupuestoFormMode.create
                ? 'Nuevo Presupuesto'
                : 'Editar Presupuesto',
          ),
          actions: [
            if (widget.mode == PresupuestoFormMode.edit)
              IconButton(
                tooltip: 'Eliminar Presupuesto',
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  await _eliminarPresupuesto();
                },
              ),

            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              tooltip: 'Guardar Presupuesto',
              onPressed: () async {
                await _guardarPresupuesto();
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
          child: Column(
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
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      Text(
                        widget.mode == PresupuestoFormMode.create
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
                        widget.mode == PresupuestoFormMode.create
                            ? 'El presupuesto se asignará a la categoría seleccionada.'
                            : 'El presupuesto actual está asignado a esta categoría.',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      // Aquí iría el listado de categorías con campos para ingresar el monto del presupuesto
                      GridContainer(
                        columns: 3,
                        children: categorias
                            .map(
                              (categoria) => CategoryButton(
                                icon: categoria.iconData,
                                title: categoria.name,
                                isSelected:
                                    categoriaSeleccionada == categoria.id,
                                onTap: () => _onChangeCategoria(categoria.id!),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        color: primaryColorWithOpacity,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: BorderSide(
                            color: colorScheme.primary,
                            width: 1.0,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.wallet_rounded,
                                size: 40,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Disponible para este presupuesto',
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
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: _mostrarModalIngresoPresupuestado,
                                child: Icon(
                                  Icons.edit,
                                  size: 30,
                                  color: colorScheme.primary,
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
                        isEditable: ingresoDisponible.monto > 0,
                        showLabel: false,
                      ),

                      if (movimientos.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          'Movimientos asociados a este presupuesto',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...fechasMovimientos.map((fecha) {
                          // Filtrar movimientos por fecha y filtro seleccionado
                          final movimientosFiltrados = movimientos
                              .where((mov) => isSameDay(mov.date, fecha))
                              .toList();

                          if (movimientosFiltrados.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return TransactionsContainer(
                            date: fecha,
                            movimientos: movimientosFiltrados,
                          );
                        }),
                        Center(
                          child: Text(
                            '${movimientos.length} movimientos en este presupuesto',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
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

  Future<void> _mostrarModalIngresoPresupuestado() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ingreso presupuestado'),
          content: SizedBox(
            height: 100,
            child: AmountInput(controller: _ingresoPresupuestadoController),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: _guardarIngresoPresupuesto,
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}
