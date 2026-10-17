import 'package:control_financiero/core/database/db_tables.dart';
import 'package:control_financiero/features/recordatorios/data/recordatorios_local_datasource.dart';
import 'package:control_financiero/features/recordatorios/models/recordatorio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';

class _Store extends Fake implements Database, Transaction {
  Map<String, Object?> row;
  int writes = 0;
  _Store(Recordatorio reminder) : row = reminder.toMap();

  @override
  Future<T> transaction<T>(
    Future<T> Function(Transaction) action, {
    bool? exclusive,
  }) => action(this);

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
  }) async => [Map.of(row)];

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    writes++;
    row.addAll(values);
    return 1;
  }
}

void main() {
  final now = DateTime(2026, 10, 12, 10);
  Recordatorio reminder(Recurrencia recurrence, {bool enabled = false}) =>
      Recordatorio(
        id: 1,
        title: 'Pago',
        scheduledAt: DateTime(2020, 1, 1, 8),
        recurrencia: recurrence,
        enabled: enabled,
      );

  test('fecha futura se conserva y fecha exacta sin recurrencia vence', () {
    final future = now.add(const Duration(minutes: 1));
    expect(resolveReminderDate(future, Recurrencia.diario, now), future);
    expect(resolveReminderDate(now, Recurrencia.ninguno, now), isNull);
    expect(
      resolveReminderDate(now, Recurrencia.diario, now),
      DateTime(2026, 10, 13, 10),
    );
  });

  test('todas las recurrencias avanzan hasta la primera ocurrencia futura', () {
    final expected = {
      Recurrencia.diario: DateTime(2026, 10, 13, 8),
      Recurrencia.semanal: DateTime(2026, 10, 14, 8),
      Recurrencia.mensual: DateTime(2026, 11, 1, 8),
      Recurrencia.anual: DateTime(2027, 1, 1, 8),
    };
    for (final entry in expected.entries) {
      expect(
        resolveReminderDate(DateTime(2020, 1, 1, 8), entry.key, now),
        entry.value,
      );
    }
  });

  test('mensual conserva el día 31 y anual conserva el 29 de febrero', () {
    expect(
      resolveReminderDate(
        DateTime(2026, 1, 31, 8),
        Recurrencia.mensual,
        DateTime(2026, 2, 1),
      ),
      DateTime(2026, 3, 31, 8),
    );
    expect(
      resolveReminderDate(
        DateTime(2024, 2, 29, 8),
        Recurrencia.anual,
        DateTime(2026, 10, 12),
      ),
      DateTime(2028, 2, 29, 8),
    );
  });

  test('reactivar vencido sin recurrencia rechaza sin escribir', () async {
    final store = _Store(reminder(Recurrencia.ninguno));
    final data = RecordatoriosLocalDataSource(database: store);
    final result = await data.updateRecordatorioEnabled(1, true);
    expect(result.success, isFalse);
    expect(store.writes, 0);
    expect(store.row[RecordatorioTable.enabled], 0);
  });

  test('reactivar recurrente persiste fecha futura y enabled juntos', () async {
    final store = _Store(reminder(Recurrencia.diario));
    final data = RecordatoriosLocalDataSource(database: store);
    final before = DateTime.now();
    final result = await data.updateRecordatorioEnabled(1, true);
    expect(result.success, isTrue);
    expect(store.writes, 1);
    expect(store.row[RecordatorioTable.enabled], 1);
    expect(Recordatorio.fromMap(store.row).scheduledAt.isAfter(before), isTrue);
  });

  test('editar recurrente desactivado avanza fecha sin activarlo', () async {
    final original = reminder(Recurrencia.mensual);
    final store = _Store(original);
    final data = RecordatoriosLocalDataSource(database: store);
    final before = DateTime.now();
    final result = await data.updateRecordatorio(original);
    expect(result.success, isTrue);
    expect(store.row[RecordatorioTable.enabled], 0);
    expect(Recordatorio.fromMap(store.row).scheduledAt.isAfter(before), isTrue);
  });

  test('editar vencido sin recurrencia rechaza sin escribir', () async {
    final original = reminder(Recurrencia.ninguno);
    final store = _Store(original);
    final result = await RecordatoriosLocalDataSource(
      database: store,
    ).updateRecordatorio(original);
    expect(result.success, isFalse);
    expect(store.writes, 0);
  });

  test('desactivar vencido sin recurrencia está permitido', () async {
    final original = reminder(Recurrencia.ninguno, enabled: true);
    final store = _Store(original);
    final result = await RecordatoriosLocalDataSource(
      database: store,
    ).updateRecordatorioEnabled(1, false);
    expect(result.success, isTrue);
    expect(store.row[RecordatorioTable.enabled], 0);
    expect(Recordatorio.fromMap(store.row).scheduledAt, original.scheduledAt);
  });
}
