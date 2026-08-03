import 'package:control_financiero/app/app_routes.dart';
import 'package:control_financiero/core/models/app_bar_action.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/features/movimientos/models/movimiento_form_args.dart';
import 'package:control_financiero/features/movimientos/models/totales_mensuales.dart';
import 'package:control_financiero/features/movimientos/presentation/movimiento_search_page.dart';
import 'package:control_financiero/features/notificaciones/presentation/notificaciones_page.dart';
import 'package:control_financiero/features/movimientos/widgets/balance_summary_card.dart';
import 'package:control_financiero/features/movimientos/widgets/category_chip.dart';
import 'package:control_financiero/features/movimientos/widgets/transactions_container.dart';
import 'package:control_financiero/features/shared/widgets/loading_screen.dart';
import 'package:control_financiero/features/shared/widgets/month_selection.dart';
import 'package:control_financiero/features/shared/widgets/summary_card.dart';
import 'package:control_financiero/app/app_state.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:control_financiero/core/constants/movimiento_constants.dart';

class MovimientosPage extends StatefulWidget {
  const MovimientosPage({super.key});

  @override
  State<MovimientosPage> createState() => _MovimientosPageState();
}

class _MovimientosPageState extends State<MovimientosPage> {
  final ScrollController _controller = ScrollController();
  late AppState _appState;

  @override
  void initState() {
    super.initState();

    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _appState = context.read<AppState>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifSinLeer = _appState.notifSinLeer;
      _appState.setAppBarActions([
        AppBarAction(
          icon: Icons.notifications_active_outlined,
          badgeCount: notifSinLeer,
          tooltip: notifSinLeer > 0
              ? '$notifSinLeer notificaciones no leidas'
              : 'Sin notificaciones',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => NotificacionesPage()),
            );
          },
        ),
        AppBarAction(
          icon: Icons.search,
          tooltip: 'Buscar movimiento',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    MovimientoSearchPage(listaCategorias: _appState.categorias),
              ),
            );
          },
        ),
      ]);

      _appState.setFloatingActionButton(
        FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              AppRoutes.movimientoFormRoute,
              arguments: MovimientoFormArgs(
                id: -1, // Indica que es un nuevo movimiento
                fechaInicial: _appState.selectedMovementsMonth,
              ),
            );
          },
          tooltip: 'Agregar movimiento',
          elevation: 2,
          child: const Icon(Icons.add),
        ),
      );
    });
  }

  void _onScroll() {
    if (_appState.isLoadingMonth) return;

    if (_controller.position.userScrollDirection == ScrollDirection.reverse) {
      _appState.setShowFloatingActionButton(false);
    } else if (_controller.position.userScrollDirection ==
        ScrollDirection.forward) {
      _appState.setShowFloatingActionButton(true);
    }
  }

  Future<void> _changeMonth(DateTime newMonth) async {
    _appState.setShowFloatingActionButton(false);

    if (_controller.hasClients) {
      _controller.jumpTo(0);
    }

    await _appState.changeMovementsMonth(newMonth);

    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (_controller.hasClients) {
        _controller.jumpTo(0);
      }
      _appState.setShowFloatingActionButton(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    // Indicador de carga para el mes seleccionado
    final isLoading = appState.isLoadingMonth;

    // Obtener el mes seleccionado
    final selectedMonth = appState.selectedMovementsMonth;

    // Obtener totales de ingresos y gastos del mes seleccionado
    final totalMesActual =
        appState.totalesMensuales ??
        TotalesMensuales(ingresos: 0.0, gastos: 0.0);

    // Obtener el porcentaje de variación respecto al mes anterior
    final variationPercent = appState.variacionAhorro;

    // Filtro de movimientos seleccionado
    MovimientoFiltro selectedFilter = appState.movimientoFiltro;

    // Movimientos agrupados por fecha
    final fechasMovimientos = appState.uniqueMovementDates;

    final movimientosFiltradosDelMes = fechasMovimientos
        .expand(
          (fecha) => appState.getMovimientosByDateAndFilter(
            fecha,
            filtro: selectedFilter,
          ),
        )
        .toList();

    final categories = [
      MovimientoFiltro.todos,
      MovimientoFiltro.ingresos,
      MovimientoFiltro.gastos,
    ];

    if (appState.loadingInitialData) {
      return LoadingScreen(message: 'Cargando datos de movimientos...');
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: Column(
        // permite desplazamiento si el contenido es mayor que el espacio.
        children: [
          MonthSelection(
            initialDate: selectedMonth,
            isLoading: isLoading,
            onMonthChanged: (newMonth) async {
              await _changeMonth(newMonth);
            },
          ),
          const SizedBox(height: 6),
          Expanded(
            child: isLoading
                ? LoadingScreen(
                    message:
                        'Cargando movimientos para\n ${formatMonthYear(selectedMonth)}...',
                  )
                : fechasMovimientos.isEmpty
                ? _EmptyMovimientos()
                : SingleChildScrollView(
                    controller: _controller,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 215,
                          child: SummaryCard(
                            title:
                                'Balance Mensual (${formatMonthYear(selectedMonth)})',
                            icon: Icons.account_balance,
                            backgroundColor: Colors.blue,
                            content: BalanceSummaryCard(
                              ammountIncome: totalMesActual.ingresos,
                              ammountExpense: totalMesActual.gastos,
                              variationPercent: variationPercent ?? 0.0,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        SizedBox(
                          height: 35,
                          child: Center(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (
                                    var i = 0;
                                    i < categories.length;
                                    i++
                                  ) ...[
                                    CategoryChip(
                                      label: categories[i].label,
                                      selected: categories[i] == selectedFilter,
                                      icon: categories[i].icon,
                                      iconColor: categories[i].color,
                                      onTap: () {
                                        appState.changeMovimientoFiltro(
                                          categories[i],
                                        );
                                      },
                                    ),
                                    if (i != categories.length - 1)
                                      const SizedBox(width: 8),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        if (movimientosFiltradosDelMes.isEmpty &&
                            selectedFilter != MovimientoFiltro.todos)
                          _EmptyFilteredMovimientos(filtro: selectedFilter)
                        else
                          // Lista de movimientos agrupados por fecha
                          ...fechasMovimientos.map((fecha) {
                            // Filtrar movimientos por fecha y filtro seleccionado
                            final movimientosFiltrados = appState
                                .getMovimientosByDateAndFilter(
                                  fecha,
                                  filtro: selectedFilter,
                                );

                            if (movimientosFiltrados.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return TransactionsContainer(
                              date: fecha,
                              movimientos: movimientosFiltrados,
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

class _EmptyMovimientos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final selectedMonth = appState.selectedMovementsMonth;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            'No hay movimientos para ${formatMonthYear(selectedMonth)}.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          Text(
            'Agrega nuevos movimientos para empezar a llevar el control de tus finanzas.',
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

class _EmptyFilteredMovimientos extends StatelessWidget {
  final MovimientoFiltro filtro;

  const _EmptyFilteredMovimientos({required this.filtro});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      margin: const EdgeInsets.symmetric(vertical: 20.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.filter_alt_off, size: 72, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No existen movimientos de tipo ${_labelFromFiltro(filtro).toLowerCase()}',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _labelFromFiltro(MovimientoFiltro filtro) {
    switch (filtro) {
      case MovimientoFiltro.ingresos:
        return 'Ingresos';
      case MovimientoFiltro.gastos:
        return 'Gastos';
      default:
        return 'Todos';
    }
  }
}
