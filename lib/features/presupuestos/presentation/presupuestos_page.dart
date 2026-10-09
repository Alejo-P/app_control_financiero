import 'package:control_financiero/core/tutorials/tutorial_host.dart';
import 'package:control_financiero/core/tutorials/tutorial_step.dart';
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
import 'package:flutter/rendering.dart';
import 'package:control_financiero/features/shared/widgets/record_actions_menu.dart';

class PresupuestosPage extends StatefulWidget {
  const PresupuestosPage({super.key});

  @override
  State<PresupuestosPage> createState() => _PresupuestosPageState();
}

class _PresupuestosPageState extends State<PresupuestosPage> {
  late AppState _appState;
  final ScrollController _controller = ScrollController();
  final _ingresoPresupuestadoController = TextEditingController();
  bool _isSaveButtonEnabled = false;
  (DateTime, double?)? _controlsSignature;

  @override
  void initState() {
    super.initState();
    _ingresoPresupuestadoController.addListener(_checkEnableSaveButton);
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _ingresoPresupuestadoController.removeListener(_checkEnableSaveButton);
    _ingresoPresupuestadoController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _appState = context.read<AppState>();
    final signature = (
      _appState.selectedBudgetMonth,
      _appState.ingresoPresupuestado?.monto,
    );
    if (_controlsSignature == signature) return;
    _controlsSignature = signature;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _appState.currentTab != 1) return;
      _appState.setAppBarActions([
        AppBarAction(
          iconWidget: const WalletEditIcon(),
          tutorialStep: TutorialStep.budgetIncome,
          tooltip: 'Editar ingreso presupuestado',
          onPressed: () async {
            await _mostrarModalIngresoPresupuestado();
          },
        ),
      ]);

      if (_appState.ingresoPresupuestado != null &&
          _appState.ingresoPresupuestado!.monto > 0) {
        _appState.setFloatingActionButton(
          FloatingActionButton(
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
            tooltip: 'Nuevo presupuesto',
            elevation: 2,
            child: const Icon(Icons.add),
          ),
        );
      } else {
        _appState.clearFloatingActionButton();
      }
    });
  }

  void _onScroll() {
    if (_appState.isLoadingBudget) return;

    if (_controller.offset <= 0) {
      if (!_appState.showFAB) {
        _appState.setShowFloatingActionButton(true);
      }
      return;
    }

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

    await _appState.changeBudgetMonth(newMonth);

    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (_controller.hasClients) {
        _controller.jumpTo(0);
      }
      _appState.setShowFloatingActionButton(true);
    });
  }

  void _checkEnableSaveButton() {
    final amountText = _ingresoPresupuestadoController.text.trim();
    final value = double.tryParse(amountText.replaceAll(',', '.')) ?? 0.0;
    final totalGastos = _appState.totalGastos ?? 0.0;

    setState(() {
      _isSaveButtonEnabled = value > 0 && value >= totalGastos;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final presupuestos = appState.presupuestos;
    final presupuestosDefinidos = presupuestos
        .where((p) => p.budgetId != null)
        .toList();
    final presupuestosSinDefinir = presupuestos
        .where((p) => p.budgetId == null && p.spent > 0)
        .toList();
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
          TutorialTarget(
            step: TutorialStep.budgetMonth,
            child: MonthSelection(
              initialDate: selectedMonth,
              isLoading: isLoading,
              allowFutureMonths: true,
              onMonthChanged: (newMonth) async {
                await _changeMonth(newMonth);
              },
            ),
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
                    controller: _controller,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 215,
                          child: TutorialTarget(
                            step: TutorialStep.budgetSummary,
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
                        ),
                        const SizedBox(height: 8),
                        ...presupuestosDefinidos.map((budgetDetails) {
                          final first =
                              budgetDetails == presupuestosDefinidos.first;
                          final card = GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.presupuestoFormRoute,
                                arguments: PresupuestoFormArgs(
                                  id: budgetDetails.budgetId!,
                                  budgetedIncome:
                                      appState.ingresoPresupuestado!,
                                  viewOnly: false,
                                ),
                              );
                            },
                            child: CategoryCard(
                              actions: RecordActionsMenu(
                                id: budgetDetails.budgetId!,
                                date: budgetDetails.date,
                                presupuesto: budgetDetails,
                                tutorialStep: first
                                    ? TutorialStep.budgetMenu
                                    : null,
                              ),
                              icon: budgetDetails.icon,
                              title: budgetDetails.title,
                              spent: budgetDetails.spent,
                              total: budgetDetails.total,
                              color: budgetDetails.color,
                              percentage: budgetDetails.percentage,
                              remainingAmount: budgetDetails.remainingAmount,
                              isOverBudget: budgetDetails.isOverBudget,
                            ),
                          );
                          return first
                              ? TutorialTarget(
                                  step: TutorialStep.budgetCard,
                                  child: card,
                                )
                              : card;
                        }),
                        if (presupuestosSinDefinir.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(color: colorScheme.tertiary),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  'Gastos sin presupuesto',
                                  style: textTheme.labelMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(color: colorScheme.tertiary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...presupuestosSinDefinir.map((budgetDetails) {
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              leading: IconContainer(
                                icon: budgetDetails.icon,
                                color: budgetDetails.color,
                                size: 26,
                              ),
                              title: Text(
                                budgetDetails.title,
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
                                '\$${(budgetDetails.spent).toStringAsFixed(2)}',
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
          content: AmountInput(
            controller: _ingresoPresupuestadoController,
            fontSize: 40,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            CustomButton(
              onTap: _isSaveButtonEnabled ? _guardarIngresoPresupuesto : null,
              text: 'Guardar',
            ),
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
