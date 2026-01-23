import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/constants/presupuesto_constants.dart';
import 'package:control_financiero/core/utils/color_utils.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
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

  @override
  void initState() {
    super.initState();
    categoriaSeleccionada = -1;
    if (widget.mode == PresupuestoFormMode.edit && widget.presupuesto != null) {
      mesSeleccionado = getMonthName(widget.presupuesto!.date);
      anioSeleccionado = widget.presupuesto!.date.year;
      categoriaSeleccionada = widget.presupuesto!.categoryId;
    } else {
      final now = DateTime.now();
      mesSeleccionado = getMonthName(now);
      anioSeleccionado = now.year;
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

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final categorias = appState.categorias;

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
                            mainAxisAlignment: MainAxisAlignment.start,
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
                                    '\$0.00',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ],
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
}
