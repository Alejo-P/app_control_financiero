import 'package:control_financiero/core/database/db_tables.dart';
import 'package:control_financiero/features/presupuestos/data/presupuestos_local_datasource.dart';
import 'package:control_financiero/features/presupuestos/models/presupuesto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';

class MemoryTransaction extends Fake implements Transaction {
  final Map<int, Map<String, Object?>> rows;
  bool failWrite = false;
  MemoryTransaction(this.rows);

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
    if (whereArgs!.length == 1) {
      final row = rows[whereArgs.first];
      return row == null ? [] : [Map.of(row)];
    }
    return rows.values
        .where(
          (row) =>
              row[PresupuestosTable.categoryId] == whereArgs[0] &&
              (row[PresupuestosTable.date] as String).substring(0, 7) ==
                  whereArgs[1],
        )
        .map(Map<String, Object?>.of)
        .toList();
  }

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    rows.remove(whereArgs!.first);
    return 1;
  }

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    if (failWrite) throw StateError('write failed');
    final id = whereArgs!.first as int;
    rows[id] = {...values, PresupuestosTable.id: id};
    return 1;
  }

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    if (failWrite) throw StateError('write failed');
    rows[99] = {...values, PresupuestosTable.id: 99};
    return 99;
  }
}

class MemoryDatabase extends Fake implements Database {
  final MemoryTransaction txn;
  MemoryDatabase(this.txn);
  @override
  Future<T> transaction<T>(
    Future<T> Function(Transaction) action, {
    bool? exclusive,
  }) async {
    final snapshot = txn.rows.map(
      (id, row) => MapEntry(id, Map<String, Object?>.of(row)),
    );
    try {
      return await action(txn);
    } catch (_) {
      txn.rows
        ..clear()
        ..addAll(snapshot);
      rethrow;
    }
  }
}

void main() {
  final source = Presupuesto(
    id: 1,
    categoryId: 7,
    date: DateTime(2026, 8),
    amount: 120,
    repeatBudget: true,
  );
  final target = Presupuesto(
    id: 2,
    categoryId: 7,
    date: DateTime(2026, 9),
    amount: 80,
  );
  late MemoryTransaction txn;
  late PresupuestosLocalDataSource data;
  setUp(() {
    txn = MemoryTransaction({
      1: {...source.toMap(), PresupuestosTable.id: 1},
      2: {...target.toMap(), PresupuestosTable.id: 2},
    });
    data = PresupuestosLocalDataSource(database: MemoryDatabase(txn));
  });

  test(
    'sin confirmación no modifica ninguno de los dos presupuestos',
    () async {
      final result = await data.transferPresupuesto(
        1,
        target.date,
        move: false,
      );
      expect(result.success, isFalse);
      expect(txn.rows.keys, unorderedEquals([1, 2]));
      expect(txn.rows[2]![PresupuestosTable.amount], 80);
    },
  );
  test('copiar reemplaza destino, conserva origen y crea otro ID', () async {
    final result = await data.transferPresupuesto(
      1,
      target.date,
      move: false,
      replacement: target,
    );
    expect(result.success, isTrue);
    expect(result.data, 99);
    expect(txn.rows.keys, unorderedEquals([1, 99]));
    expect(Presupuesto.fromMap(txn.rows[1]!).date, source.date);
    final copied = Presupuesto.fromMap(txn.rows[99]!);
    expect(copied.date, target.date);
    expect(copied.amount, source.amount);
    expect(copied.repeatBudget, isTrue);
  });
  test('mover conserva el ID del origen y reemplaza destino', () async {
    final result = await data.transferPresupuesto(
      1,
      target.date,
      move: true,
      replacement: target,
    );
    expect(result.data, 1);
    expect(txn.rows.keys, [1]);
    expect(Presupuesto.fromMap(txn.rows[1]!).date, target.date);
  });
  test(
    'un destino cambiado después de confirmar requiere otra confirmación',
    () async {
      txn.rows[2]![PresupuestosTable.amount] = 90.0;
      final result = await data.transferPresupuesto(
        1,
        target.date,
        move: true,
        replacement: target,
      );
      expect(result.success, isFalse);
      expect(txn.rows.keys, unorderedEquals([1, 2]));
    },
  );
  test('un error de escritura revierte el reemplazo', () async {
    txn.failWrite = true;
    await expectLater(
      data.transferPresupuesto(1, target.date, move: true, replacement: target),
      throwsStateError,
    );
    expect(txn.rows.keys, unorderedEquals([1, 2]));
    expect(Presupuesto.fromMap(txn.rows[1]!).date, source.date);
  });
}
