import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/models/app_bar_action.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/features/historial/models/month_data.dart';
import 'package:control_financiero/features/historial/widgets/accordeon_content.dart';
import 'package:control_financiero/features/historial/widgets/month_accordeon_card.dart';
import 'package:control_financiero/features/shared/widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  late AppState _appState;
  int? expandedIndex;
  List<ExpansionTileController> controllers = [];
  final ScrollController scrollController = ScrollController();
  List<GlobalKey> itemKeys = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _appState = context.read<AppState>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _appState.setAppBarActions([
        AppBarAction(
          onPressed: () => showYearSelector(context),
          label: _appState.selectedHistoryMonth.year.toString(),
          icon: Icons.filter_list,
        ),
      ]);
    });
  }

  void _initControllers(
    List<MonthData> history,
    DateTime selectedMovementsMonth,
  ) {
    controllers = List.generate(
      history.length,
      (_) => ExpansionTileController(),
    );
    itemKeys = List.generate(history.length, (_) => GlobalKey());

    int indexToExpand = -1;

    // 🥇 1. Buscar mes seleccionado
    indexToExpand = history.indexWhere(
      (m) => isSameMonth(m.month, selectedMovementsMonth),
    );

    // 🥈 2. Si no existe, buscar mes actual
    if (indexToExpand == -1) {
      final now = currentDateTime;

      indexToExpand = history.indexWhere((m) => isSameMonth(m.month, now));
    }

    // 🥉 3. Si tampoco existe → usar el primero
    if (indexToExpand == -1 && history.isNotEmpty) {
      indexToExpand = 0;
    }

    expandedIndex = indexToExpand;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controllers.isNotEmpty && expandedIndex != null) {
        controllers[expandedIndex!].expand();

        final context = itemKeys[expandedIndex!].currentContext;

        if (context != null) {
          Scrollable.ensureVisible(
            context,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            alignment: 0.2,
          );
        }
      }
    });
  }

  void handleExpand(int index) {
    for (int i = 0; i < controllers.length; i++) {
      if (i == index) {
        if (!controllers[i].isExpanded) {
          controllers[i].expand();
        }
        expandedIndex = i;
      } else {
        if (controllers[i].isExpanded) {
          controllers[i].collapse();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final selectedMovementsMonth = appState.selectedMovementsMonth;

    final isLoading = appState.isLoadingHistory;
    final history = appState.historialAnual;

    if (appState.loadingInitialData) {
      return LoadingScreen(message: 'Cargando datos de movimientos...');
    }

    if (expandedIndex == null && history.isNotEmpty) {
      final now = currentDateTime;

      final index = history.indexWhere(
        (m) => m.month.year == now.year && m.month.month == now.month,
      );

      expandedIndex = index != -1 ? index : 0; // fallback al primero
    }

    if (history.isNotEmpty && controllers.length != history.length) {
      _initControllers(history, selectedMovementsMonth);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Column(
        children: [
          Expanded(
            child: isLoading
                ? LoadingScreen(
                    message: 'Cargando historial de ingresos y gastos',
                  )
                : history.isEmpty
                ? _EmptyHistorial()
                : ListView(
                    controller: scrollController,
                    children: [
                      ...history.asMap().entries.map((entry) {
                        final index = entry.key;
                        final monthData = entry.value;

                        final sameMonth = isSameMonth(
                          monthData.month,
                          appState.selectedMovementsMonth,
                        );

                        return Container(
                          key: itemKeys[index],
                          child: MonthAccordionCard(
                            controller: controllers[index],
                            isHighlighted: expandedIndex == index,
                            onExpansionChanged: (isExpanded) {
                              if (isExpanded) {
                                handleExpand(index);
                              }
                            },
                            month: monthData.month,
                            balance: monthData.balance,
                            content: AccordeonContent(
                              spent: monthData.spent,
                              totalIncome: monthData.income,
                              onTapButton: sameMonth
                                  ? null
                                  : () => {
                                      appState.gotoMovements(monthData.month),
                                    },
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> showYearSelector(BuildContext context) async {
    final appState = context.read<AppState>();
    final currentYear = appState.selectedHistoryMonth.year;

    final selectedYear = await showModalBottomSheet<int>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        final textTheme = theme.textTheme;
        final years = appState.aniosDisponibles;

        if (years.isEmpty) {
          return const Center(child: Text("No hay datos disponibles"));
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Seleccionar año",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Solo aparecerán aquellos que tengan movimientos registrados",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: years.map((year) {
                  final isSelected = year == currentYear;

                  return ListTile(
                    title: Text(
                      year.toString(),
                      style: textTheme.displayMedium?.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected ? const Icon(Icons.check) : null,
                    onTap: () => Navigator.pop(context, year),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );

    if (selectedYear != null && selectedYear != currentYear) {
      controllers = [];
      expandedIndex = null;
      appState.changeHistoryYear(selectedYear);
    }
  }
}

class _EmptyHistorial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final selectedYear = appState.selectedHistoryMonth.year;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            'No hay resumenes para visualizar en $selectedYear.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          Text(
            'El resumen mensual se genera en base a la actividad registrada  cada mes del año',
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
