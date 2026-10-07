import 'package:control_financiero/features/movimientos/data/movimientos_local_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';

class SearchTransaction extends Fake implements Transaction {
  int total;
  final calls = <({String sql, List<Object?> args})>[];
  SearchTransaction(this.total);

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    calls.add((sql: sql, args: arguments ?? []));
    return sql.contains('COUNT(*)')
        ? [
            {'COUNT(*)': total},
          ]
        : [];
  }
}

class SearchDatabase extends Fake implements Database {
  final SearchTransaction txn;
  SearchDatabase(this.txn);
  @override
  Future<T> transaction<T>(
    Future<T> Function(Transaction) action, {
    bool? exclusive,
  }) => action(txn);
}

void main() {
  test(
    'conteo y página comparten filtros; texto con comodines es literal',
    () async {
      final txn = SearchTransaction(47);
      final result = await MovimientosLocalDataSource.querySearchPage(
        SearchDatabase(txn),
        categoryId: 9,
        text: ' SUPER%_ ',
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 7),
        page: 1,
      );
      expect(result.total, 47);
      expect(result.page, 1);
      expect(txn.calls.first.args, [9, 'super%_', '2026-10-01', '2026-10-07']);
      expect(txn.calls.last.args, [...txn.calls.first.args, 20]);
      for (final call in txn.calls) {
        expect(call.sql, contains('m.category_id = ?'));
        expect(call.sql, contains('instr('));
        expect(call.sql, contains('date(m.date) >= ?'));
        expect(call.sql, contains('date(m.date) <= ?'));
      }
      expect(
        txn.calls.last.sql,
        contains('ORDER BY m.date DESC, m.time DESC, m.id DESC'),
      );
      expect(txn.calls.last.sql, contains('LIMIT 20 OFFSET ?'));
    },
  );

  for (final total in [0, 20, 21, 40, 41]) {
    test('total $total ajusta página inexistente después de borrar', () async {
      final txn = SearchTransaction(total);
      final result = await MovimientosLocalDataSource.querySearchPage(
        SearchDatabase(txn),
        page: 8,
      );
      final expectedPage = total == 0 ? 0 : (total - 1) ~/ 20;
      expect(result.page, expectedPage);
      expect(txn.calls.last.args, [expectedPage * 20]);
      expect(txn.calls.first.sql, isNot(contains('WHERE')));
    });
  }
}
