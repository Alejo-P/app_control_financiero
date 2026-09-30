import 'package:control_financiero/app/app_snackbar.dart';
import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/core/utils/record_date_limits.dart';
import 'package:control_financiero/features/presupuestos/models/presupuesto.dart';
import 'package:control_financiero/features/shared/widgets/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum RecordAction { copy, move }

class RecordActionsMenu extends StatefulWidget {
  final int id;
  final DateTime date;
  final Presupuesto? presupuesto;

  const RecordActionsMenu({
    super.key,
    required this.id,
    required this.date,
    this.presupuesto,
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
        if (!mounted) return;
        if (replacement != null) {
          final confirmed = await showConfirmDialog(
            context,
            title: 'Reemplazar presupuesto',
            content:
                'Ya existe un presupuesto de esta categoría para ${formatMonthYear(destination)} '
                'por \$${replacement.amount.toStringAsFixed(2)}. '
                '¿Deseas reemplazarlo por \$${budget.amount.toStringAsFixed(2)}?'
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
    } catch (_) {
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
            title: Text(move ? 'Mover presupuesto' : 'Copiar presupuesto'),
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
  Widget build(BuildContext context) => PopupMenuButton<RecordAction>(
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
}
