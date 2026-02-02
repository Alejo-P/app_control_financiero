import 'package:control_financiero/app/app.dart';
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
import 'package:control_financiero/features/presupuestos/widgets/custom_dropdown.dart';
import 'package:control_financiero/features/shared/widgets/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PresupuestoFormPage extends StatefulWidget {
  final PresupuestoFormMode mode;
  final Presupuesto? presupuesto;

  const PresupuestoFormPage({super.key, required this.mode, this.presupuesto});

  @override
  State<PresupuestoFormPage> createState() => _PresupuestoFormPageState();
}

class _PresupuestoFormPageState extends State<PresupuestoFormPage> {
  final _hasUnsavedChanges = false;
  final meses = monthNames;
  final anios = generateYearList(DateTime.now().year, 10);
  late String mesSeleccionado;
  late int anioSeleccionado;
  late int categoriaSeleccionada;
  late IngresoPresupuestado ingresoPresupuestado;
  final _presupuestoAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    late AppState appState;
    categoriaSeleccionada = -1;
    ingresoPresupuestado = context.read<AppState>().ingresoPresupuestado!;
    if (widget.mode == PresupuestoFormMode.edit && widget.presupuesto != null) {
      mesSeleccionado = getMonthName(widget.presupuesto!.date);
      anioSeleccionado = widget.presupuesto!.date.year;
      categoriaSeleccionada = widget.presupuesto!.categoryId;
      _presupuestoAmountController.text = widget.presupuesto!.amount.toString();
    } else {
      final now = DateTime.now();
      mesSeleccionado = getMonthName(now);
      anioSeleccionado = now.year;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      appState = context.read<AppState>();
      final fechaPresupuesto = DateTime(
        anioSeleccionado,
        meses.indexOf(mesSeleccionado) + 1,
      );
      ingresoPresupuestado = await appState
          .getIngresoPresupuestadoByMonthAndYear(fechaPresupuesto);
      _presupuestoAmountController.text =
          ingresoPresupuestado.monto.toString();
    });
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
    return appState.categorias
        .where((cat) => cat.movementType == TipoMovimiento.gasto)
        .toList();
  }

  Future<void> _guardarIngresoPresupuesto() async {
    // Lógica para guardar el ingreso presupuestado
    final amountText = _presupuestoAmountController.text.trim();
    final value = double.tryParse(amountText.replaceAll(',', '.')) ?? 0.0;

    final nuevoIngresoPresupuestado = IngresoPresupuestado(
      monto: value,
      fecha: DateTime(anioSeleccionado, meses.indexOf(mesSeleccionado) + 1),
    );

    setState(() {
      ingresoPresupuestado = nuevoIngresoPresupuestado;
    });

    // 🔥 opcional: guardar en AppState / DB
    await context.read<AppState>().setIngresoPresupuestado(
      nuevoIngresoPresupuestado,
    );

    if (!mounted) return;

    AppSnackbar.success(context, 'Ingreso presupuestado guardado correctamente');

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
                      const Text(
                        'Selecciona el mes y año',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomDropdown<String>(
                            hintText: 'Mes',
                            items: meses,
                            selectedItem: mesSeleccionado,
                            onChanged: (value) {
                              setState(() => mesSeleccionado = value!);
                            },
                          ),
                          const SizedBox(width: 12),
                          CustomDropdown<int>(
                            hintText: 'Año',
                            items: anios,
                            selectedItem: anioSeleccionado,
                            onChanged: (value) {
                              setState(() => anioSeleccionado = value!);
                            },
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
                        style: TextStyle(fontSize: 13, color: Colors.grey),
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
                                  const SizedBox(height: 2),
                                  Text(
                                    '(Basado en tus ingresos)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.primary,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${ingresoPresupuestado.monto.toStringAsFixed(2)}',
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
            child: AmountInput(
              controller: _presupuestoAmountController,
            ),
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
