import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/features/presupuestos/models/ingreso_presupuestado.dart';
import 'package:control_financiero/features/presupuestos/presentation/presupuestos_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import '../../support/app_state_fakes.dart';

class _BudgetState extends TestAppState {
  _BudgetState(this.initialAmount) {
    currentTab = 1;
    loadingInitialData = false;
  }

  final double? initialAmount;

  @override
  double? get totalGastos => 100;

  @override
  IngresoPresupuestado? get ingresoPresupuestado => initialAmount == null
      ? null
      : IngresoPresupuestado(monto: initialAmount!, fecha: selectedBudgetMonth);
}

void main() {
  setUpAll(() => initializeDateFormatting('es_EC'));

  for (final initialAmount in <double?>[null, 150]) {
    testWidgets(
      'Guardar reacciona al monto con ingreso inicial $initialAmount',
      (tester) async {
        final state = _BudgetState(initialAmount);
        await tester.pumpWidget(
          ChangeNotifierProvider<AppState>.value(
            value: state,
            child: const MaterialApp(home: Scaffold(body: PresupuestosPage())),
          ),
        );
        await tester.pumpAndSettle();

        state.appBarActions.single.onPressed();
        await tester.pumpAndSettle();

        bool canSave() =>
            tester
                .widget<ElevatedButton>(
                  find.widgetWithText(ElevatedButton, 'Guardar'),
                )
                .onPressed !=
            null;

        expect(canSave(), initialAmount != null);
        for (final (text, enabled) in [
          ('150', true),
          ('99', false),
          ('100', true),
          ('0', false),
          ('', false),
          ('200', true),
        ]) {
          await tester.enterText(find.byType(TextFormField), text);
          await tester.pump();
          expect(canSave(), enabled, reason: 'Monto: $text');
        }

        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();
        state.appBarActions.single.onPressed();
        await tester.pumpAndSettle();
        expect(canSave(), initialAmount != null);
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();
        await tester.pumpWidget(const SizedBox.shrink());
        state.dispose();
      },
    );
  }
}
