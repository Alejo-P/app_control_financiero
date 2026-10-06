import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/models/operation_result.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/features/presupuestos/models/category_card_info.dart';
import 'package:control_financiero/features/presupuestos/models/ingreso_presupuestado.dart';
import 'package:control_financiero/features/presupuestos/models/presupuesto.dart';
import 'package:control_financiero/features/shared/widgets/record_actions_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../support/app_state_fakes.dart';

class MenuState extends TestAppState {
  final Presupuesto? destination;
  final List<IngresoPresupuestado> budgetIncomeRecords;
  final List<Presupuesto> otherBudgets;
  int writes = 0;
  bool? moved;
  Presupuesto? confirmedReplacement;
  MenuState(
    this.destination,
    this.budgetIncomeRecords, {
    this.otherBudgets = const [],
  });

  @override
  Future<Presupuesto?> presupuestoEnDestino(
    int categoryId,
    DateTime date,
  ) async =>
      destination != null &&
          destination!.categoryId == categoryId &&
          isSameMonth(destination!.date, date)
      ? destination
      : null;

  @override
  Future<double> ingresoPresupuestadoAsignadoEnDestino(DateTime date) async =>
      [if (destination != null) destination!, ...otherBudgets]
          .where((budget) => isSameMonth(budget.date, date))
          .fold<double>(0.0, (sum, budget) => sum + budget.amount);

  @override
  Future<double> ingresoPresupuestadoTotalEnDestino(DateTime date) async {
    return budgetIncomeRecords
        .where((record) => isSameMonth(record.fecha, date))
        .fold<double>(0.0, (sum, record) => sum + record.monto);
  }

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
    for (final scenario in [
      (
        name: 'sin ingreso en destino',
        income: 0.0,
        defined: false,
        assigned: 0.0,
        replacement: 0.0,
        allowed: false,
      ),
      (
        name: 'ingreso cero',
        income: 0.0,
        defined: true,
        assigned: 0.0,
        replacement: 0.0,
        allowed: false,
      ),
      (
        name: 'saldo insuficiente',
        income: 150.0,
        defined: true,
        assigned: 40.0,
        replacement: 0.0,
        allowed: false,
      ),
      (
        name: 'saldo exacto',
        income: 150.0,
        defined: true,
        assigned: 30.0,
        replacement: 0.0,
        allowed: true,
      ),
      (
        name: 'reemplazo con saldo exacto',
        income: 150.0,
        defined: true,
        assigned: 30.0,
        replacement: 80.0,
        allowed: true,
      ),
      (
        name: 'reemplazo que supera el límite',
        income: 150.0,
        defined: true,
        assigned: 40.0,
        replacement: 80.0,
        allowed: false,
      ),
      (
        name: 'mes ya excedido que queda dentro del límite al reemplazar',
        income: 150.0,
        defined: true,
        assigned: 30.0,
        replacement: 200.0,
        allowed: true,
      ),
    ]) {
      testWidgets('${move ? 'mover' : 'copiar'}: ${scenario.name}', (
        tester,
      ) async {
        final now = currentDateTime;
        final month = DateTime(now.year, now.month);
        final source = Presupuesto(
          id: 1,
          categoryId: 7,
          date: DateTime(now.year, now.month - 1),
          amount: 120,
        );
        final sourceCard = CategoryCardInfo(
          icon: Icons.category,
          color: Colors.grey,
          title: 'Categoría de prueba',
          spent: 0,
          total: source.amount,
          date: source.date,
          percentage: 0,
          categoryId: source.categoryId,
          budgetId: source.id,
        );
        final replacement = scenario.replacement == 0
            ? null
            : Presupuesto(
                id: 2,
                categoryId: 7,
                date: month,
                amount: scenario.replacement,
              );
        final state = MenuState(
          replacement,
          [
            if (scenario.defined)
              IngresoPresupuestado(monto: scenario.income, fecha: month),
            // El ingreso de otro mes no habilita el destino seleccionado.
            IngresoPresupuestado(
              monto: 1000,
              fecha: DateTime(now.year, now.month + 1),
            ),
          ],
          otherBudgets: [
            Presupuesto(
              id: 3,
              categoryId: 8,
              date: month,
              amount: scenario.assigned,
            ),
            // Los presupuestos de otro mes no consumen el saldo del destino.
            Presupuesto(id: 4, categoryId: 9, date: source.date, amount: 1000),
          ],
        );
        await tester.pumpWidget(
          ChangeNotifierProvider<AppState>.value(
            value: state,
            child: MaterialApp(
              home: Scaffold(
                body: RecordActionsMenu(
                  id: 1,
                  date: source.date,
                  presupuesto: sourceCard,
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
        tester
            .widget<DropdownButtonFormField<DateTime>>(
              find.byType(DropdownButtonFormField<DateTime>),
            )
            .onChanged!(month);
        await tester.pumpAndSettle();
        await tester.tap(find.text(move ? 'Mover' : 'Copiar'));
        await tester.pumpAndSettle();
        if (scenario.allowed && replacement != null) {
          expect(find.text('Reemplazar presupuesto'), findsOneWidget);
          expect(state.writes, 0);
          await tester.tap(find.text('Confirmar'));
          await tester.pumpAndSettle();
        }
        expect(state.writes, scenario.allowed ? 1 : 0);
        if (scenario.allowed) {
          expect(state.moved, move);
          expect(state.confirmedReplacement, same(replacement));
          expect(find.text('Guardado'), findsOneWidget);
        } else {
          expect(find.text('Reemplazar presupuesto'), findsNothing);
          expect(
            find.textContaining(
              'No puedes ${move ? 'mover' : 'copiar'} un presupuesto',
            ),
            findsOneWidget,
          );
        }
        expect(tester.takeException(), isNull);
        expect(
          tester
              .widget<PopupMenuButton<RecordAction>>(
                find.byType(PopupMenuButton<RecordAction>),
              )
              .enabled,
          isTrue,
        );
      });
    }
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
          final sourceCard = CategoryCardInfo(
            icon: Icons.category,
            color: Colors.grey,
            title: 'Categoría de prueba',
            spent: 0,
            total: source.amount,
            date: source.date,
            percentage: 0,
            categoryId: source.categoryId,
            budgetId: source.id,
          );
          final destination = Presupuesto(
            id: 2,
            categoryId: 7,
            date: month,
            amount: 80,
          );
          final budgetIncomeRecords = [
            IngresoPresupuestado(id: 1, monto: 150, fecha: month),
            IngresoPresupuestado(
              id: 2,
              monto: 0,
              fecha: DateTime(now.year, now.month + 1),
            ),
          ];
          final state = MenuState(destination, budgetIncomeRecords);
          await tester.pumpWidget(
            ChangeNotifierProvider<AppState>.value(
              value: state,
              child: MaterialApp(
                home: Scaffold(
                  body: RecordActionsMenu(
                    id: 1,
                    date: source.date,
                    presupuesto: sourceCard,
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
