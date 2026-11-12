import 'package:control_financiero/app/app_routes.dart';
import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';
import 'package:control_financiero/features/historial/models/expense_analysis_page_args.dart';
import 'package:control_financiero/features/historial/models/monthly_report_page_args.dart';
import 'package:control_financiero/features/historial/presentation/expense_analysis_form_page.dart';
import 'package:control_financiero/features/historial/presentation/expense_analysis_results_page.dart';
import 'package:control_financiero/features/historial/presentation/monthly_report_page.dart';
import 'package:control_financiero/features/historial/widgets/report_charts.dart';
import 'package:control_financiero/features/movimientos/models/detalle_movimiento.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'monthly_report_page_test.dart' as base;

Categoria category(int id, String name, TipoMovimiento type) => Categoria(
  id: id,
  name: name,
  description: '',
  movementType: type,
  categoryTypeID: 1,
  iconName: 'restaurant',
  iconColorValue: 0xFF000000,
);

class ExpenseState extends base.ReportState {
  final queries = <ExpenseAnalysisResultsPageArgs>[];
  final expenses = List.generate(
    21,
    (index) => DetalleMovimiento(
      id: index + 1,
      title: 'Compra ${index + 1}',
      amount: 10,
      movementType: TipoMovimiento.gasto,
      date: DateTime(2026, 1, 21 - index),
      categoryIcon: Icons.restaurant,
      categoryColor: null,
      categoryName: 'Alimentación',
    ),
  );

  ExpenseState() {
    categorias = [
      category(1, 'Alimentación', TipoMovimiento.gasto),
      category(2, 'Transporte', TipoMovimiento.gasto),
      category(3, 'Sueldo', TipoMovimiento.ingreso),
    ];
  }

  @override
  Future<List<DetalleMovimiento>> fetchExpenseAnalysis(
    ExpenseAnalysisResultsPageArgs filters,
  ) async {
    queries.add(filters);
    return expenses;
  }
}

Widget flow(ExpenseState state) => base.app(
  state,
  Navigator(
    onGenerateRoute: (settings) {
      final page = switch (settings.name) {
        AppRoutes.expenseAnalysisFormRoute => const ExpenseAnalysisFormPage(),
        AppRoutes.expenseAnalysisResultsRoute =>
          const ExpenseAnalysisResultsPage(),
        _ => const MonthlyReportPage(),
      };
      return MaterialPageRoute<void>(
        settings: settings.name == '/'
            ? RouteSettings(
                arguments: MonthlyReportPageArgs(month: DateTime(2026, 1)),
              )
            : settings,
        builder: (_) => page,
      );
    },
  ),
);

Future<void> show(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('conserva filtros al volver y permite limpiar el formulario', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final state = ExpenseState();
    state.categorias.addAll(
      List.generate(
        8,
        (index) => category(
          index + 4,
          'Categoría de prueba ${index + 1}',
          TipoMovimiento.gasto,
        ),
      ),
    );
    await tester.pumpWidget(flow(state));
    await tester.pumpAndSettle();
    await show(tester, find.text('Análisis de gastos'));
    await tester.tap(find.text('Análisis de gastos'));
    await tester.pumpAndSettle();

    final getResults = find.widgetWithText(ElevatedButton, 'Obtener resultados');
    await show(tester, getResults);
    expect(tester.widget<ElevatedButton>(getResults).onPressed, isNull);
    final selectCategories = find.text('Seleccionar categorías');
    await tester.ensureVisible(selectCategories);
    await tester.tap(selectCategories);
    await tester.pumpAndSettle();
    expect(find.text('Sueldo'), findsNothing);
    final food = find.widgetWithText(CheckboxListTile, 'Alimentación');
    await tester.tap(find.text('Marcar todas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Listo'));
    await tester.pumpAndSettle();
    expect(find.text('Listo'), findsNothing);
    final foodChip = find.widgetWithText(InputChip, 'Alimentación');
    final transportChip = find.widgetWithText(InputChip, 'Transporte');
    final lastChip = find.widgetWithText(InputChip, 'Categoría de prueba 8');
    final primary = Theme.of(tester.element(foodChip)).colorScheme.primary;
    final categoryChip = tester.widget<InputChip>(foodChip);
    expect(categoryChip.avatar, isA<Icon>());
    expect((categoryChip.avatar! as Icon).color, primary);
    expect((categoryChip.label as Text).style?.color, primary);
    expect(categoryChip.side, BorderSide(color: primary));
    expect(categoryChip.deleteIconColor, primary);
    expect(tester.getTopLeft(foodChip).dy, tester.getTopLeft(lastChip).dy);
    final chipRow = find.ancestor(
      of: foodChip,
      matching: find.byType(SingleChildScrollView),
    );
    final chipScroll = find.descendant(
      of: chipRow,
      matching: find.byType(Scrollable),
    );
    expect(
      tester.state<ScrollableState>(chipScroll).position.maxScrollExtent,
      greaterThan(0),
    );

    await tester.ensureVisible(selectCategories);
    await tester.tap(selectCategories);
    await tester.pumpAndSettle();
    expect(tester.widget<CheckboxListTile>(food).value, isTrue);
    await tester.tap(food);
    await tester.pumpAndSettle();
    Navigator.of(tester.element(food)).pop();
    await tester.pumpAndSettle();
    expect(foodChip, findsOneWidget);

    await tester.tap(selectCategories);
    await tester.pumpAndSettle();
    expect(tester.widget<CheckboxListTile>(food).value, isTrue);
    await tester.tap(find.text('Limpiar'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CheckboxListTile, 'Transporte'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Listo'));
    await tester.pumpAndSettle();
    expect(foodChip, findsNothing);

    final concept = find.byType(TextField);
    await tester.ensureVisible(concept);
    await tester.enterText(concept, 'Compra');
    final lastMonth = find.widgetWithText(ChoiceChip, 'Mes pasado');
    final allHistory = find.widgetWithText(ChoiceChip, 'Todo el historial');
    await tester.ensureVisible(lastMonth);
    expect(tester.widget<ChoiceChip>(lastMonth).selected, isFalse);
    await tester.tap(lastMonth);
    await tester.pumpAndSettle();
    final selectedChip = tester.widget<ChoiceChip>(lastMonth);
    expect(selectedChip.selected, isTrue);
    expect(selectedChip.labelStyle?.color, primary);
    expect(selectedChip.checkmarkColor, primary);
    expect(selectedChip.side, BorderSide(color: primary));
    expect(selectedChip.selectedColor, Colors.transparent);
    expect(tester.widget<ChoiceChip>(allHistory).selected, isFalse);
    expect(state.queries, isEmpty);
    await show(tester, getResults);
    await tester.tap(getResults);
    await tester.pumpAndSettle();
    expect(state.queries.single.categoryIds, [2]);
    expect(state.queries.single.concept, 'Compra');
    expect(state.queries.single.period, ExpenseAnalysisPeriod.lastMonth);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(concept).controller!.text, 'Compra');
    await tester.ensureVisible(lastMonth);
    expect(tester.widget<ChoiceChip>(lastMonth).selected, isTrue);
    await tester.ensureVisible(selectCategories);
    expect(transportChip, findsOneWidget);
    expect(find.widgetWithText(InputChip, 'Alimentación'), findsNothing);

    await tester.tap(find.byTooltip('Limpiar filtros'));
    await tester.pumpAndSettle();
    expect(tester.widget<ChoiceChip>(allHistory).selected, isTrue);
    expect(find.byType(InputChip), findsNothing);
    expect(tester.widget<TextField>(concept).controller!.text, isEmpty);
    expect(tester.widget<ElevatedButton>(getResults).onPressed, isNull);
    expect(state.queries, hasLength(1));
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Informe mensual'), findsOneWidget);
    expect(state.requested, [DateTime(2026, 1)]);
  });

  testWidgets('selección y sumas abarcan páginas y sobreviven a la búsqueda', (
    tester,
  ) async {
    final state = ExpenseState();
    await tester.pumpWidget(
      base.app(
        state,
        Navigator(
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            settings: RouteSettings(
              arguments: ExpenseAnalysisResultsPageArgs(
                period: ExpenseAnalysisPeriod.allHistory,
                today: DateTime(2026, 1),
                categories: [
                  ...state.categorias.take(2),
                  for (var index = 0; index < 12; index++)
                    category(
                      index + 4,
                      'Categoría de prueba ${index + 1}',
                      TipoMovimiento.gasto,
                    ),
                ],
                concept: 'Compra',
              ),
            ),
            builder: (_) => const ExpenseAnalysisResultsPage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('21 de 21'), findsOneWidget);
    final chips = find.byType(Chip);
    expect(chips, findsNWidgets(16));
    expect(
      {
        for (var index = 0; index < 16; index++)
          tester.getTopLeft(chips.at(index)).dy,
      },
      hasLength(2),
    );
    final horizontalFilters = find.byWidgetPredicate(
      (widget) =>
          widget is SingleChildScrollView &&
          widget.scrollDirection == Axis.horizontal,
    );
    final filterScroll = find.descendant(
      of: horizontalFilters,
      matching: find.byType(Scrollable),
    );
    expect(
      tester.state<ScrollableState>(filterScroll).position.maxScrollExtent,
      greaterThan(0),
    );
    final next = find.text('Siguiente');
    await show(tester, next);
    await tester.tap(next);
    await tester.pumpAndSettle();
    final lastExpense = find.widgetWithText(CheckboxListTile, 'Compra 21');
    await show(tester, lastExpense);
    await tester.tap(lastExpense);
    await tester.pumpAndSettle();

    final search = find.byType(TextField);
    await tester.ensureVisible(search);
    await tester.enterText(search, 'Compra 1');
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, 1200));
    await tester.pumpAndSettle();
    expect(find.text('20 de 21'), findsOneWidget);
    expect(find.text(reportMoney(200)), findsOneWidget);

    final selectAll = find.text('Marcar todos');
    await show(tester, selectAll);
    await tester.tap(selectAll);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Desmarcar todos'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, 1200));
    await tester.pumpAndSettle();
    expect(find.text('0 de 21'), findsOneWidget);
    expect(find.text(reportMoney(0)), findsNWidgets(2));
    expect(state.queries, hasLength(1));
  });
}
