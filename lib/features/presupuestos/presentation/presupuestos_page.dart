import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/features/presupuestos/widgets/total_budget_summary_card.dart';
import 'package:control_financiero/features/shared/widgets/loading_screen.dart';
import 'package:control_financiero/features/shared/widgets/summary_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:control_financiero/app/app_state.dart';
import '../../shared/widgets/month_selection.dart';
import '../widgets/category_card.dart';

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
      _appState.clearAppBarActions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    // Indicador de carga para el mes seleccionado
    final isLoading = appState.isLoadingBudget;

    // Obtener el mes seleccionado
    final selectedMonth = appState.selectedBudgetMonth;

    if (appState.loadingInitialData) {
      return LoadingScreen(
        message: 'Cargando datos de presupuesto...'
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MonthSelection(
            initialDate: selectedMonth,
            onMonthChanged: (newMonth) async {
              await appState.changeBudgetMonth(newMonth);
            },
          ),
          const SizedBox(height: 6),

          // Hacemos que la lista de categorías ocupe el espacio restante
          // para evitar overflow en pantallas pequeñas. El SingleChildScrollView
          // permite desplazamiento si el contenido es mayor que el espacio.
          Expanded(
            child: isLoading
                ? LoadingScreen()
                : false // TODO: Aquí iría la condición para verificar si hay presupuestos
                ? _EmptyPresupuestos()
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 210, // ajusta a gusto
                          child: SummaryCard(
                            title: 'Resumen de Presupuesto',
                            icon: Icons.calendar_month,
                            backgroundColor: Colors.teal,
                            content: TotalBudgetSummaryCard(
                              totalBudget: 2000,
                              spentAmount: 1766.50,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Categorías',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(height: 8),
                        Divider(),
                        CategoryCard(
                          icon: Icons.home,
                          title: 'Vivienda',
                          spent: 950,
                          total: 1000,
                          color: Colors.blue,
                        ),
                        CategoryCard(
                          icon: Icons.restaurant,
                          title: 'Alimentación',
                          spent: 380,
                          total: 500,
                          color: Colors.orange,
                        ),
                        CategoryCard(
                          icon: Icons.directions_car,
                          title: 'Transporte',
                          spent: 120,
                          total: 200,
                          color: Colors.green,
                        ),
                        CategoryCard(
                          icon: Icons.sports_esports,
                          title: 'Ocio',
                          spent: 154.5,
                          total: 200,
                          color: Colors.purple,
                        ),
                        CategoryCard(
                          icon: Icons.shopping_cart,
                          title: 'Compras',
                          spent: 200,
                          total: 250,
                          color: Colors.red,
                        ),
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
            'No hay movimientos para ${formatMonthYear(selectedMonth)}.',
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
