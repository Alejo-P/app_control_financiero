import 'package:control_financiero/features/historial/data/monthly_report_query.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class ReportTransaction extends Fake implements Transaction {
  final calls = <({String sql, List<Object?> args})>[];
  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    calls.add((sql: sql, args: arguments ?? []));
    return sql.contains('previous_spent')
        ? [
            {'income': 850, 'spent': 680, 'previous_spent': 743.17},
          ]
        : [
            {
              'id': 1,
              'name': 'Alimentación',
              'icon': 'restaurant',
              'color': 0xFF299C68,
              'spent': 680,
              'count': 25,
              'budget': 700,
            },
            {
              'id': 2,
              'name': 'Sin gastos',
              'color': 0xFF299C68,
              'spent': 0,
              'count': 0,
              'budget': 100,
            },
          ];
  }
}

class ReportDatabase extends Fake implements Database {
  final ReportTransaction txn;
  ReportDatabase(this.txn);
  @override
  Future<T> transaction<T>(
    Future<T> Function(Transaction) action, {
    bool? exclusive,
  }) => action(txn);
}

void main() {
  test(
    'enero consulta diciembre previo y ambas agregaciones comparten período sin paginar',
    () async {
      final transaction = ReportTransaction();
      final result = await MonthlyReportQuery.load(
        ReportDatabase(transaction),
        DateTime(2026, 1, 25),
      );
      expect(result.month, DateTime(2026, 1));
      expect(result.balance, 170);
      expect(result.categories.first.count, 25);
      expect(result.categories.first.icon, Icons.restaurant);
      expect(transaction.calls.last.sql, contains('c.icon_name as icon'));
      expect(result.categories.last.budget, 100);
      expect(transaction.calls.first.args, [
        '2026-01-01',
        '2026-01-01',
        '2026-01-01',
        '2025-12-01',
        '2026-02-01',
      ]);
      expect(transaction.calls.last.args, [
        '2026-01-01',
        '2026-02-01',
        '2026-01-01',
        '2026-02-01',
      ]);
      for (final call in transaction.calls) {
        expect(call.sql, isNot(contains('LIMIT')));
        expect(call.sql, isNot(contains('INSERT')));
        expect(call.sql, isNot(contains('UPDATE')));
        expect(call.sql, isNot(contains('DELETE')));
      }
    },
  );
}
