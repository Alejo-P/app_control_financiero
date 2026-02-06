import 'package:control_financiero/app/app_snackbar.dart';
import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/constants/presupuesto_constants.dart';
import 'package:control_financiero/core/utils/color_utils.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';
import 'package:control_financiero/features/movimientos/widgets/ammount_input.dart';
import 'package:control_financiero/features/presupuestos/models/ingreso_presupuestado.dart';
import 'package:control_financiero/features/shared/widgets/grid_container.dart';
import 'package:control_financiero/features/presupuestos/models/presupuesto.dart';
import 'package:control_financiero/features/presupuestos/widgets/category_button.dart';
import 'package:control_financiero/features/shared/widgets/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PresupuestoFormPage extends StatefulWidget {
  final PresupuestoFormMode mode;
  final Presupuesto? presupuesto;
  final IngresoPresupuestado? ingresoPresupuestado;

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
  final meses = monthNames;
  final anios = generateYearList(DateTime.now().year, 10);
  late DateTime fechaPresupuesto;
  late int categoriaSeleccionada;
  late IngresoPresupuestado ingresoDisponible;
  final _presupuestoAmountController = TextEditingController();
  final _ingresoPresupuestadoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    //late AppState appState;
    categoriaSeleccionada = -1;
    fechaPresupuesto = DateTime.now();
    fechaPresupuesto = context.read<AppState>().selectedBudgetMonth;
    if (widget.ingresoPresupuestado != null) {
      ingresoDisponible = widget.ingresoPresupuestado!;
    } else {
      ingresoDisponible = IngresoPresupuestado(
        monto: 0.0,
        fecha: fechaPresupuesto,
      );
    }

    if (widget.mode == PresupuestoFormMode.edit && widget.presupuesto != null) {
      categoriaSeleccionada = widget.presupuesto!.categoryId;
      _presupuestoAmountController.text = widget.presupuesto!.amount.toString();
    }

    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   appState = context.read<AppState>();
    //   ingresoPresupuestado = await appState
    //       .getIngresoPresupuestadoByMonthAndYear(fechaPresupuesto);
    //   _ingresoPresupuestadoController.text = ingresoPresupuestado.monto > 0
    //       ? ingresoPresupuestado.monto.toString()
    //       : '';
    // });

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

  List<Categoria> get categoriasTipoGasto {
    final appState = context.read<AppState>();
    final totalPresupuesto = appState.totalIngresoPresupuestado ?? 0.0;
    return appState.categorias
        .where((cat) => cat.movementType == TipoMovimiento.gasto)
        .toList();
  }

  Future<void> _guardarIngresoPresupuesto() async {
    // Lógica para guardar el ingreso presupuestado
    final appState = context.read<AppState>();
    final amountText = _ingresoPresupuestadoController.text.trim();
    final value = double.tryParse(amountText.replaceAll(',', '.')) ?? 0.0;

    final nuevoIngresoPresupuestado = IngresoPresupuestado(
      monto: value,
      fecha: fechaPresupuesto,
    );

    setState(() {
      ingresoDisponible = nuevoIngresoPresupuestado;
    });

    // 🔥 opcional: guardar en AppState / DB
    await appState.setIngresoPresupuestado(nuevoIngresoPresupuestado);

    if (!mounted) return;

    if (!appState.transactionSuccess) {
      AppSnackbar.error(context, appState.transactionResultMessage);
      return;
    }

    AppSnackbar.success(context, appState.transactionResultMessage);

    Navigator.pop(context, true);
  }

  Future<void> _guardarPresupuesto() async {
    // Lógica para guardar el presupuesto
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final categorias = categoriasTipoGasto;

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
                      const Text(
                        'Seleccione una categoría',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Asigna un presupuesto a una categoría específica',
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
                      AmountInput(controller: _presupuestoAmountController),
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

          // TextField(
          //   controller: controller,
          //   keyboardType: const TextInputType.numberWithOptions(decimal: true),
          //   decoration: const InputDecoration(
          //     labelText: 'Monto',
          //     prefixIcon: Icon(Icons.attach_money),
          //   ),
          // ),
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
