import 'package:control_financiero/core/utils/app_logger.dart';
import 'package:control_financiero/app/app_snackbar.dart';
import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/core/utils/record_date_limits.dart';
import 'package:control_financiero/features/presupuestos/models/category_card_info.dart';
import 'package:control_financiero/features/presupuestos/models/presupuesto.dart';
import 'package:control_financiero/features/shared/widgets/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:control_financiero/core/tutorials/tutorial_host.dart';
import 'package:control_financiero/core/tutorials/tutorial_step.dart';

enum RecordAction { copy, move }

class RecordActionsMenu extends StatefulWidget {
  final int id;
  final DateTime date;
  final CategoryCardInfo? presupuesto;
  final TutorialStep? tutorialStep;

  const RecordActionsMenu({
    super.key,
    required this.id,
    required this.date,
    this.presupuesto,
    this.tutorialStep,
  });

  @override
  State<RecordActionsMenu> createState() => _RecordActionsMenuState();
}

class _RecordActionsMenuState extends State<RecordActionsMenu> {
  bool _busy = false;

  Future<void> _execute(RecordAction action) async {
    if (_busy) return;
    setState(() => _busy = true);
    final appState = context.read<AppState>();
    final feedbackContext = Scaffold.of(context).context;
    final move = action == RecordAction.move;
    final budget = widget.presupuesto;
    try {
      final DateTime? destination;
      if (budget == null) {
        final limits = RecordDateLimits.movimientos();
        destination = await showDatePicker(
          context: context,
          initialDate: limits.clamp(widget.date),
          firstDate: limits.first,
          lastDate: limits.last,
          helpText: move
              ? 'Mover movimiento a otra fecha'
              : 'Copiar movimiento a otra fecha',
        );
      } else {
        destination = await _pickBudgetMonth(move);
      }
      if (destination == null || !mounted) return;
      Presupuesto? replacement;
      double budgetAsignadoInDestination;
      double budgetTotalInDestination;
      if (budget != null) {
        if (isSameMonth(budget.date, destination)) {
          AppSnackbar.error(
            context,
            'Selecciona un mes diferente al de origen.',
          );
          return;
        }
        replacement = await appState.presupuestoEnDestino(
          budget.categoryId,
          destination,
        );

        budgetAsignadoInDestination = await appState
            .ingresoPresupuestadoAsignadoEnDestino(destination);

        budgetTotalInDestination = await appState
            .ingresoPresupuestadoTotalEnDestino(destination);

        final totalFinal =
            budgetAsignadoInDestination -
            (replacement?.amount ?? 0) +
            budget.total;

        if (!mounted) return;
        if (totalFinal > budgetTotalInDestination) {
          AppSnackbar.error(
            context,
            'No puedes ${move ? 'mover' : 'copiar'} un presupuesto que supere el ingreso presupuestado disponible en el mes de destino (\$${budgetTotalInDestination.toStringAsFixed(2)}).',
          );
          return;
        }

        if (replacement != null) {
          final confirmed = await showConfirmDialog(
            context,
            title: 'Reemplazar presupuesto',
            content:
                'Ya existe un presupuesto de esta categoría para ${formatMonthYear(destination)} '
                'por \$${replacement.amount.toStringAsFixed(2)}. '
                '¿Deseas reemplazarlo por \$${budget.total.toStringAsFixed(2)}?'
                '${move ? '\nEl presupuesto de origen se trasladará al mes seleccionado.' : '\nEl presupuesto de origen se conservará.'}',
          );
          if (confirmed != true || !mounted) return;
        }
      }
      final result = budget == null
          ? await appState.transferirMovimiento(
              widget.id,
              destination,
              move: move,
            )
          : await appState.transferirPresupuesto(
              widget.id,
              destination,
              move: move,
              replacement: replacement,
            );
      if (!feedbackContext.mounted) return;
      if (result.success) {
        AppSnackbar.success(feedbackContext, result.message);
      } else {
        AppSnackbar.error(feedbackContext, result.message);
      }
    } catch (error, stackTrace) {
      AppLogger.reportError('Copiar o mover registro', error, stackTrace);
      if (feedbackContext.mounted) {
        AppSnackbar.error(
          feedbackContext,
          'No se pudo guardar la operación. Vuelve a intentarlo.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<DateTime?> _pickBudgetMonth(bool move) {
    final limits = RecordDateLimits.presupuestos();
    final months = List.generate(
      25,
      (index) => DateTime(limits.first.year, limits.first.month + index),
    );
    var selected = limits.clamp(DateTime(widget.date.year, widget.date.month));
    return showDialog<DateTime>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text(
              move ? 'Mover presupuesto' : 'Copiar presupuesto',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            content: DropdownButtonFormField<DateTime>(
              initialValue: selected,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Mes de destino'),
              items: months
                  .map(
                    (month) => DropdownMenuItem(
                      value: month,
                      child: Text(formatMonthYear(month)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setDialogState(() => selected = value);
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, selected),
                child: Text(move ? 'Mover' : 'Copiar'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final menu = PopupMenuButton<RecordAction>(
      padding: EdgeInsets.zero,
      style: const ButtonStyle(
        padding: WidgetStatePropertyAll(EdgeInsets.zero),
        minimumSize: WidgetStatePropertyAll(Size(32, 48)),
        maximumSize: WidgetStatePropertyAll(Size(32, 48)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.standard,
      ),
      enabled: !_busy,
      tooltip: 'Acciones',
      icon: Icon(_busy ? Icons.hourglass_top : Icons.more_vert),
      onSelected: _execute,
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: RecordAction.copy,
          child: ListTile(
            leading: Icon(Icons.copy),
            title: Text('Copiar a otra fecha'),
          ),
        ),
        const PopupMenuItem(
          value: RecordAction.move,
          child: ListTile(
            leading: Icon(Icons.event),
            title: Text('Mover a otra fecha'),
          ),
        ),
      ],
    );
    if (widget.tutorialStep == null) return menu;
    return TutorialTarget(step: widget.tutorialStep!, child: menu);
  }
}
