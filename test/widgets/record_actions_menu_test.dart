import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/models/operation_result.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/features/presupuestos/models/presupuesto.dart';
import 'package:control_financiero/features/shared/widgets/record_actions_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../support/app_state_fakes.dart';

class MenuState extends TestAppState {
  final Presupuesto destination;
  int writes = 0;
  bool? moved;
  Presupuesto? confirmedReplacement;
  MenuState(this.destination);

  @override
  Future<Presupuesto?> presupuestoEnDestino(
    int categoryId,
    DateTime date,
  ) async => destination;

  @override
  Future<OperationResult<int>> transferirPresupuesto(
    int id,
    DateTime date, {
    required bool move,
    Presupuesto? replacement,
  }) async {
    writes++;
    moved = move;
    confirmedReplacement = replacement;
    return const OperationResult(success: true, data: 1, message: 'Guardado');
  }
}

void main() {
  for (final move in [false, true]) {
    for (final confirm in [false, true]) {
      testWidgets(
        '${move ? 'mover' : 'copiar'}: ${confirm ? 'confirmar' : 'cancelar'} reemplazo',
        (tester) async {
          final now = currentDateTime;
          final month = DateTime(now.year, now.month);
          final source = Presupuesto(
            id: 1,
            categoryId: 7,
            date: DateTime(now.year, now.month - 1),
            amount: 120,
          );
          final destination = Presupuesto(
            id: 2,
            categoryId: 7,
            date: month,
            amount: 80,
          );
          final state = MenuState(destination);
          await tester.pumpWidget(
            ChangeNotifierProvider<AppState>.value(
              value: state,
              child: MaterialApp(
                home: Scaffold(
                  body: RecordActionsMenu(
                    id: 1,
                    date: source.date,
                    presupuesto: source,
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Acciones'));
          await tester.pumpAndSettle();
          await tester.tap(
            find.text(move ? 'Mover a otra fecha' : 'Copiar a otra fecha'),
          );
          await tester.pumpAndSettle();
          final dropdown = tester.widget<DropdownButtonFormField<DateTime>>(
            find.byType(DropdownButtonFormField<DateTime>),
          );
          dropdown.onChanged!(month);
          await tester.pumpAndSettle();
          await tester.tap(find.text(move ? 'Mover' : 'Copiar'));
          await tester.pumpAndSettle();
          expect(find.text('Reemplazar presupuesto'), findsOneWidget);
          expect(state.writes, 0);
          await tester.tap(find.text(confirm ? 'Confirmar' : 'Cancelar'));
          await tester.pumpAndSettle();
          expect(state.writes, confirm ? 1 : 0);
          if (confirm) {
            expect(state.moved, move);
            expect(state.confirmedReplacement, same(destination));
            expect(find.text('Guardado'), findsOneWidget);
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
