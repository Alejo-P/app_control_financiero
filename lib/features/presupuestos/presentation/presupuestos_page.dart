import 'package:control_financiero/core/constants/presupuesto_constants.dart';
import 'package:control_financiero/core/models/app_bar_action.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/features/presupuestos/models/detalle_presupuesto.dart';
import 'package:control_financiero/features/presupuestos/presentation/presupuesto_form_page.dart';
import 'package:control_financiero/features/presupuestos/widgets/total_budget_summary_card.dart';
import 'package:control_financiero/features/shared/widgets/loading_screen.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _appState = context.read<AppState>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _appState.setAppBarActions([
        AppBarAction(
          icon: Icons.add,
          tooltip: 'Nuevo presupuesto',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PresupuestoFormPage(
                  mode: PresupuestoFormMode.create,
                  ingresoPresupuestado:
                      _appState.totalIngresoPresupuestado ?? 0.0,
                ),
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

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
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
                          height: 210,
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
                        SizedBox(height: 8),
                        ...sortedBudgets.map((budgetDetails) {
                          final presupuesto = budgetDetails['presupuesto'];
                          final categoryDetails = getCategoryDetailsById(
                            presupuesto.categoryId,
                          );

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PresupuestoFormPage(
                                    mode: PresupuestoFormMode.edit,
                                    presupuesto: DetallePresupuesto(
                                      idPresupuesto: presupuesto.id!,
                                      categoria: categoryDetails['name'],
                                      categoriaId: presupuesto.categoryId,
                                      montoPresupuestado: presupuesto.amount,
                                      totalPresupuestado: ingresoPresupuestado?.monto ?? 0.0,
                                      icon: categoryDetails['icon'],
                                      iconColor: categoryDetails['iconColor'],
                                      fechaPresupuesto: presupuesto.date,
                                      movimientos: categoryDetails['movements'],
                                      esRecurrente: presupuesto.repeatBudget,
                                    ),
                                    ingresoPresupuestado:
                                        appState.totalIngresoPresupuestado ??
                                        0.0,
                                  ),
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
                      ],
                    ),
                  ),
          ),
        ],
      ),
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
