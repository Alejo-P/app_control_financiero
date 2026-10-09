import 'package:control_financiero/core/utils/app_logger.dart';
import 'package:control_financiero/core/database/db_helper.dart';
import 'package:control_financiero/core/database/db_tables.dart';
import 'package:control_financiero/core/models/backup_content.dart';
import 'package:control_financiero/core/models/operation_result.dart';
import 'package:sqflite/sqflite.dart';

class BackupLocalDatasource {
  Future<void> _clearExistingData(Transaction tsx) async {
    final batch = tsx.batch();
    batch.delete(RecordatorioTable.table);
    batch.delete(MovimientosTable.table);
    batch.delete(PresupuestosTable.table);
    batch.delete(IngresoPresupuestadoTable.table);
    batch.delete(BudgetNotificationConfigTable.table);
    batch.delete(MovementNotificationConfigTable.table);
    batch.delete(BudgetNotificationEventsTable.table);
    batch.delete(CategoriasTable.table);
    batch.delete(TipoCategoriasTable.table);
    await batch.commit(noResult: true);
  }

  Future<void> _restoreDataFromBackup(
    Transaction tsx,
    BackupContent backupContent,
  ) async {
    final batch = tsx.batch();
    for (var tipo in backupContent.categoryTypes) {
      batch.insert(
        TipoCategoriasTable.table,
        tipo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    for (var categoria in backupContent.categories) {
      batch.insert(
        CategoriasTable.table,
        categoria.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    for (var ingreso in backupContent.budgetIncome) {
      batch.insert(
        IngresoPresupuestadoTable.table,
        ingreso.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    for (var movimiento in backupContent.movements) {
      batch.insert(
        MovimientosTable.table,
        movimiento.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    for (var presupuesto in backupContent.budgets) {
      batch.insert(
        PresupuestosTable.table,
        presupuesto.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    for (var notifConfig in backupContent.budgetNotifications) {
      batch.insert(
        BudgetNotificationConfigTable.table,
        notifConfig.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    for (var config in backupContent.movementNotificationConfigs) {
      batch.insert(
        MovementNotificationConfigTable.table,
        config.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    for (var recordatorio in backupContent.reminders) {
      batch.insert(
        RecordatorioTable.table,
        recordatorio.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<OperationResult<void>> restoreDataFromBackup(
    BackupContent backupContent,
  ) async {
    try {
      final db = await DBHelper.instance.database;

      await db.transaction((tsx) async {
        await _clearExistingData(tsx);
        await _restoreDataFromBackup(tsx, backupContent);
      });

      return OperationResult(
        success: true,
        message: 'Datos restaurados correctamente desde el respaldo',
      );
    } on Exception catch (error, stackTrace) {
      AppLogger.reportError('Restaurar tablas del respaldo', error, stackTrace);
      return OperationResult(
        success: false,
        message: 'Error al restaurar datos desde el respaldo',
      );
    }
  }
}
