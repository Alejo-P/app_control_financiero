import 'package:control_financiero/app/app_snackbar.dart';
import 'package:control_financiero/app/app_routes.dart';
import 'package:control_financiero/core/models/app_bar_action.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/features/movimientos/widgets/ammount_input.dart';
import 'package:control_financiero/features/presupuestos/models/ingreso_presupuestado.dart';
import 'package:control_financiero/features/presupuestos/models/presupuesto_form_args.dart';
import 'package:control_financiero/features/presupuestos/widgets/total_budget_summary_card.dart';
import 'package:control_financiero/features/shared/widgets/custom_button.dart';
import 'package:control_financiero/features/shared/widgets/icon_container.dart';
import 'package:control_financiero/features/shared/widgets/loading_screen.dart';
import 'package:control_financiero/features/shared/custom_icons/wallet_edit_icon.dart';
import 'package:control_financiero/features/shared/widgets/summary_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/features/shared/widgets/month_selection.dart';
import 'package:control_financiero/features/presupuestos/widgets/category_card.dart';

class PresupuestosPage extends StatefulWidget {
  const PresupuestosPage({super.key});

  @override
  State<PresupuestosPage> createState() => _PresupuestosPageState();
}

class _PresupuestosPageState extends State<PresupuestosPage> {
  late AppState _appState;
  final _ingresoPresupuestadoController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _appState = context.read<AppState>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _appState.setAppBarActions([
        AppBarAction(
          iconWidget: const WalletEditIcon(),
          tooltip: 'Editar ingreso presupuestado',
          onPressed: () async {
            await _mostrarModalIngresoPresupuestado();
          },
        ),

        if (_appState.ingresoPresupuestado != null &&
            _appState.ingresoPresupuestado!.monto > 0)
          AppBarAction(
            icon: Icons.add,
            tooltip: 'Nuevo presupuesto',
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.presupuestoFormRoute,
                arguments: PresupuestoFormArgs(
                  id: -1,
                  budgetedIncome: _appState.ingresoPresupuestado!,
                  viewOnly: false,
                  fechaPresupuesto: _appState.selectedBudgetMonth,
                ),
              );
            },
          ),
      ]);
    });
  }

  Map<String, dynamic> getCategoryDetailsById(int categoryId) {
    final categoria = _appState.getCategoriaById(categoryId);
    final gastosAcumulados = _appState.getGastoAcumuladoPorCategoriaEnMes(
      categoryId,
    );
    final movimientos = _appState.getMovimientosPresupuestoByCategoriaId(
      categoryId,
    );

    return {
      'name': categoria?.name ?? 'Categoría Desconocida',
      'icon': categoria?.iconData ?? Icons.category,
      'iconColor': categoria?.iconColor ?? Colors.grey,
      'spent': gastosAcumulados,
      'movements': movimientos,
    };
  }

  List<Map<String, dynamic>> get sortedBudgets => getSortedPresupuestos();

  List<Map<String, dynamic>> getSortedPresupuestos() {
    final presupuestos = _appState.presupuestos;

    // Combinar presupuestos con detalles de categoría y gasto acumulado
    final categoriesWithSpending = presupuestos.map((presupuesto) {
      final categoryDetails = getCategoryDetailsById(presupuesto.categoryId);
      return {
        'presupuesto': presupuesto,
        'name': categoryDetails['name'],
        'icon': categoryDetails['icon'],
        'iconColor': categoryDetails['iconColor'],
        'spent': categoryDetails['spent'],
        'percentage': presupuesto.amount == 0
            ? 0.0
            : categoryDetails['spent'] / presupuesto.amount,
      };
    }).toList();

    // Ordenar por porcentaje gastado (mayor a menor)
    categoriesWithSpending.sort((a, b) {
      final percentageA = a['percentage'] as double;
      final percentageB = b['percentage'] as double;
      return percentageB.compareTo(percentageA);
    });

    return categoriesWithSpending;
  }

  List<Map<String, dynamic>> get categoriasSinPresupuestoConGasto {
    final categoriasConPresupuesto = _appState.presupuestos
        .map((presupuesto) => presupuesto.categoryId)
        .toSet();

    final categoriasConGasto = _appState.movimientosPresupuestos
        .map((movimiento) => movimiento.categoryID)
        .toSet();

    return categoriasConGasto
        .where((categoriaId) => !categoriasConPresupuesto.contains(categoriaId))
        .map((categoriaId) {
          final categoria = _appState.getCategoriaById(categoriaId);

          return {
            'id': categoriaId,
            'name': categoria?.name ?? 'Categoría desconocida',
            'icon': categoria?.iconData ?? Icons.category,
            'iconColor': categoria?.iconColor ?? Colors.grey,
            'spent': _appState.getGastoAcumuladoPorCategoriaEnMes(categoriaId),
          };
        })
        .where((categoria) => (categoria['spent'] as double) > 0)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final presupuestos = appState.presupuestos;
    final totalGastos = appState.totalGastos ?? 0.0;

    // Indicador de carga para el mes seleccionado
    final isLoading = appState.isLoadingBudget;

    // Obtener el mes seleccionado
    final selectedMonth = appState.selectedBudgetMonth;
    final ingresoPresupuestado = appState.ingresoPresupuestado;
    if (appState.loadingInitialData) {
      return LoadingScreen(message: 'Cargando datos de presupuesto...');
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MonthSelection(
            initialDate: selectedMonth,
            isLoading: isLoading,
            onMonthChanged: (newMonth) async {
              await appState.changeBudgetMonth(newMonth);
            },
          ),
          const SizedBox(height: 6),
          Expanded(
            child: isLoading
                ? LoadingScreen(
                    message:
                        'Cargando datos de presupuesto para\n ${formatMonthYear(selectedMonth)}...',
                  )
                : presupuestos.isEmpty
                ? _EmptyPresupuestos()
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 215,
                          child: SummaryCard(
                            title: 'Resumen de Presupuesto',
                            icon: Icons.calendar_month,
                            backgroundColor: Colors.teal,
                            content: TotalBudgetSummaryCard(
                              totalBudget: ingresoPresupuestado?.monto ?? 0.0,
                              spentAmount: totalGastos,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...sortedBudgets.map((budgetDetails) {
                          final presupuesto = budgetDetails['presupuesto'];
                          final categoryDetails = getCategoryDetailsById(
                            presupuesto.categoryId,
                          );

                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.presupuestoFormRoute,
                                arguments: PresupuestoFormArgs(
                                  id: presupuesto.id!,
                                  budgetedIncome:
                                      appState.ingresoPresupuestado!,
                                  viewOnly: false,
                                ),
                              );
                            },
                            child: CategoryCard(
                              icon: categoryDetails['icon'],
                              title: categoryDetails['name'],
                              spent: categoryDetails['spent'],
                              total: presupuesto.amount,
                              color: categoryDetails['iconColor'],
                              percentage: budgetDetails['percentage'],
                            ),
                          );
                        }),
                        if (categoriasSinPresupuestoConGasto.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: Divider(color: colorScheme.tertiary)),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  'Gastos sin presupuesto',
                                  style: textTheme.labelMedium
                                      ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                              Expanded(child: Divider(color: colorScheme.tertiary)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...categoriasSinPresupuestoConGasto.map((categoria) {
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                              leading: IconContainer(
                                icon: categoria['icon'],
                                color: categoria['iconColor'],
                                size:26,
                              ),
                              title: Text(
                                categoria['name'],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: textTheme.labelMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                              subtitle: Text(
                                'Sin presupuesto asignado',
                                style: textTheme.labelSmall,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              trailing: Text(
                                '\$${(categoria['spent'] as double).toStringAsFixed(2)}',
                                style: textTheme.labelMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _guardarIngresoPresupuesto() async {
    // Lógica para guardar el ingreso presupuestado
    final appState = context.read<AppState>();
    final amountText = _ingresoPresupuestadoController.text.trim();
    final fechaPresupuesto = appState.selectedBudgetMonth;
    final totalGastos = appState.totalGastos ?? 0.0;
    final value = double.tryParse(amountText.replaceAll(',', '.')) ?? 0.0;
    if (value <= 0) {
      AppSnackbar.error(
        context,
        'El ingreso presupuestado debe ser mayor a 0.',
      );
      return;
    }

    if (value < totalGastos) {
      AppSnackbar.error(
        context,
        'El ingreso presupuestado no puede ser menor al total de gastos (\$${totalGastos.toStringAsFixed(2)}).',
      );
      return;
    }

    final nuevoIngresoPresupuestado = IngresoPresupuestado(
      monto: value,
      fecha: fechaPresupuesto,
    );

    await appState.setIngresoPresupuestado(nuevoIngresoPresupuestado);

    if (!mounted) return;

    if (!appState.transactionSuccess) {
      AppSnackbar.error(context, appState.transactionResultMessage);
      return;
    }

    AppSnackbar.success(context, appState.transactionResultMessage);

    Navigator.pop(context, true);
  }

  Future<void> _mostrarModalIngresoPresupuestado() async {
    final appState = context.read<AppState>();
    final ingresoPresupuestado = appState.ingresoPresupuestado;
    _ingresoPresupuestadoController.text =
        (ingresoPresupuestado != null && ingresoPresupuestado.monto > 0)
        ? ingresoPresupuestado.monto.toStringAsFixed(2)
        : '';
    final fechaPresupuesto = appState.selectedBudgetMonth;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Ingreso presupuestado para ${formatMonthYear(fechaPresupuesto)}',
          ),
          content: SizedBox(
            height: 120,
            child: AmountInput(controller: _ingresoPresupuestadoController),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            CustomButton(onTap: _guardarIngresoPresupuesto, text: 'Guardar'),
          ],
        );
      },
    );
  }
}

class _EmptyPresupuestos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final selectedMonth = appState.selectedBudgetMonth;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_balance_wallet_rounded,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No hay presupuestos para ${formatMonthYear(selectedMonth)}.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          Text(
            'Agrega nuevos presupuestos para empezar a llevar el control de tus finanzas.',
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
