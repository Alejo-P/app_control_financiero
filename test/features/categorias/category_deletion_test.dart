import 'package:control_financiero/core/database/db_tables.dart';
import 'package:control_financiero/features/categorias/data/categorias_local_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';

class _Database extends Fake implements Database {
  final _Transaction txn = _Transaction();
  @override
  Future<T> transaction<T>(
    Future<T> Function(Transaction) action, {
    bool? exclusive,
  }) => action(txn);
}

class _Transaction extends Fake implements Transaction {
  String? referenceTable;
  bool deleted = false;
  bool failDelete = false;
  bool isDefault = false;

  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    expect(whereArgs, [7]);
    if (table == CategoriasTable.table) {
      return [
        {'id': 7, 'is_default': isDefault ? 1 : 0},
      ];
    }
    expect(where, 'category_id = ?');
    return table == referenceTable
        ? [
            {'id': 12},
          ]
        : [];
  }

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    if (failDelete) throw Exception('database unavailable');
    expect(table, CategoriasTable.table);
    expect(whereArgs, [7]);
    deleted = true;
    return 1;
  }
}

void main() {
  for (final table in [
    MovimientosTable.table,
    PresupuestosTable.table,
    RecordatorioTable.table,
    BudgetNotificationEventsTable.table,
  ]) {
    test('rechaza borrado con referencias en $table', () async {
      final db = _Database();
      db.txn.referenceTable = table;
      final result = await CategoriasLocalDataSource(
        database: db,
      ).deleteCategoria(7);
      expect(result.success, isFalse);
      expect(result.message, contains('asociados'));
      expect(db.txn.deleted, isFalse);
    });
  }

  test('permite borrar una categoría sin relaciones', () async {
    final db = _Database();
    final result = await CategoriasLocalDataSource(
      database: db,
    ).deleteCategoria(7);
    expect(result.success, isTrue);
    expect(db.txn.deleted, isTrue);
  });

  test('un fallo de SQLite se devuelve como error recuperable', () async {
    final db = _Database();
    db.txn.failDelete = true;
    final result = await CategoriasLocalDataSource(
      database: db,
    ).deleteCategoria(7);
    expect(result.success, isFalse);
    expect(result.message, contains('Inténtalo nuevamente'));
  });

  test('conserva la protección de categorías predeterminadas', () async {
    final db = _Database();
    db.txn.isDefault = true;
    final result = await CategoriasLocalDataSource(
      database: db,
    ).deleteCategoria(7);
    expect(result.success, isFalse);
    expect(db.txn.deleted, isFalse);
  });
}
