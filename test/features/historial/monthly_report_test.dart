import 'package:control_financiero/features/historial/models/monthly_report.dart';
import 'package:control_financiero/features/historial/widgets/report_charts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

ReportCategory category(
  int id, {
  double spent = 0,
  double? budget,
  String? name,
  int color = 0xFF299C68,
  IconData icon = Icons.category,
  int? count,
}) => ReportCategory(
  id: id,
  name: name ?? 'Categoría $id',
  icon: icon,
  colorValue: color,
  spent: spent,
  count: count ?? (spent > 0 ? 1 : 0),
  budget: budget,
);

MonthlyReport report({
  double income = 850,
  double spent = 680,
  double previous = 743.17,
  List<ReportCategory> categories = const [],
}) => MonthlyReport(
  month: DateTime(2026, 1),
  income: income,
  spent: spent,
  previousSpent: previous,
  categories: categories,
);

void main() {
  test(
    'categoría conserva icono, conteo y redondea importes de la consulta',
    () {
      final value = ReportCategory.fromMap({
        'id': 1,
        'name': 'Alimentación',
        'icon': 'restaurant',
        'color': 0xFF299C68,
        'spent': 12.345,
        'budget': 20.005,
        'count': 3,
      });
      expect(value.icon, Icons.restaurant);
      expect(value.count, 3);
      expect(value.colorValue, 0xFF299C68);
      expect(value.spent, 12.35);
      expect(value.budget, 20.01);
      expect(value.remaining, 7.66);
    },
  );

  test('categoría sin icono usa el icono predeterminado', () {
    final value = ReportCategory.fromMap({'id': 1, 'name': 'Otros'});
    expect(value.icon, Icons.category);
    expect(value.count, 0);
    expect(value.budget, isNull);
  });

  test('balance, ahorro y comparación usan las bases acordadas', () {
    final value = report();
    expect(value.balance, 170);
    expect(value.savingsPercent, 20);
    expect(value.expenseChange, -63.17);
    expect(value.expenseChangePercent, closeTo(-8.5, .01));
    expect(value.previousMonth, DateTime(2025, 12));
  });

  test('ahorro cero, déficit y falta de ingresos', () {
    expect(report(income: 100, spent: 100).savingsPercent, 0);
    expect(report(income: 100, spent: 125).savingsPercent, -25);
    expect(report(income: 0, spent: 0).savingsPercent, isNull);
    expect(report(income: 0, spent: 100).savingsPercent, isNull);
    expect(report(income: 0, spent: 100).balance, -100);
  });

  test('variación cero, sin base, aumento y reducción total', () {
    expect(report(spent: 0, previous: 0).expenseChangePercent, 0);
    expect(report(spent: 100, previous: 0).expenseChangePercent, isNull);
    expect(report(spent: 100, previous: 0).expenseChange, 100);
    expect(report(spent: 0, previous: 100).expenseChangePercent, -100);
    expect(report(spent: 150, previous: 100).expenseChangePercent, 50);
    expect(report(spent: 100, previous: 100).expenseChangePercent, 0);
  });

  test('umbrales incluyen cada borde exacto y un centavo a cada lado', () {
    final cases = <double, ReportBudgetStatus>{
      0: ReportBudgetStatus.healthy,
      49.99: ReportBudgetStatus.healthy,
      50: ReportBudgetStatus.inUse,
      84.99: ReportBudgetStatus.inUse,
      85: ReportBudgetStatus.nearLimit,
      99.99: ReportBudgetStatus.nearLimit,
      100: ReportBudgetStatus.reached,
      100.01: ReportBudgetStatus.exceeded,
      125: ReportBudgetStatus.exceeded,
    };
    for (final entry in cases.entries) {
      expect(
        category(1, spent: entry.key, budget: 100).status,
        entry.value,
        reason: 'Consumo ${entry.key}',
      );
    }
  });

  test('cero asignado y presupuesto ausente son estados diferentes', () {
    expect(category(1, spent: 100).status, ReportBudgetStatus.none);
    expect(category(1, spent: 100).ratio, isNull);
    expect(category(1, budget: 0).status, ReportBudgetStatus.reached);
    expect(category(1, budget: 0).ratio, isNull);
    expect(
      category(1, budget: 0, spent: 25).status,
      ReportBudgetStatus.exceeded,
    );
    expect(category(1, budget: 0, spent: 25).ratio, isNull);
  });

  test(
    'incluye más de cinco categorías; presupuestos sin gasto y sin asignación al final',
    () {
      final source = [
        for (var i = 1; i <= 9; i++)
          category(i, spent: i * 10, budget: i.isEven ? 100 : null),
        category(10, budget: 50),
      ];
      final value = report(categories: source);
      expect(value.expenseCategories.length, 9);
      expect(value.expenseCategories.first.id, 9);
      expect(value.budgetCategories.length, 10);
      expect(
        value.budgetCategories.take(5).every((c) => c.budget != null),
        isTrue,
      );
      expect(
        value.budgetCategories.skip(5).every((c) => c.budget == null),
        isTrue,
      );
      expect(source.first.id, 1);
    },
  );

  test(
    'colores repetidos y similares se distinguen sin alterar las categorías',
    () {
      final source = [category(1), category(2), category(3, color: 0xFF299C69)];
      final colors = reportCategoryColors(source);
      expect(colors.values.toSet().length, 3);
      expect(colors[1], const Color(0xFF299C68));
      expect(source[1].colorValue, 0xFF299C68);
      expect(reportCategoryColors(source.reversed.toList()), colors);
      expect(reportPercent(0), '0 %');
      expect(reportMoney(1234.5), contains('1.234,50'));
    },
  );
}
