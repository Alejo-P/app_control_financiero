import 'package:control_financiero/core/utils/app_logger.dart';
import 'package:control_financiero/core/database/db_helper.dart';
import 'package:control_financiero/core/database/db_tables.dart';
import 'package:control_financiero/core/models/operation_result.dart';
import 'package:control_financiero/features/recordatorios/models/detalle_recordatorio.dart';
import 'package:control_financiero/features/recordatorios/models/info_card_recordatorio.dart';
import 'package:control_financiero/features/recordatorios/models/recordatorio.dart';
import 'package:sqflite/sqflite.dart';

class RecordatoriosLocalDataSource {
  final DBHelper _dbHelper = DBHelper.instance;
  final Database? _database;
  RecordatoriosLocalDataSource({Database? database}) : _database = database;

  Future<List<Recordatorio>> fetchAllRecordatorios() async {
    final db = _database ?? await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      RecordatorioTable.table,
    );

    return maps.map(Recordatorio.fromMap).toList();
  }

  Future<List<InfoCardRecordatorio>> fetchAllDetailedRecordatorios() async {
    final db = _database ?? await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT
          r.${RecordatorioTable.id} AS id,
          r.${RecordatorioTable.title} AS title,
          r.${RecordatorioTable.enabled} AS is_enabled,
          r.${RecordatorioTable.isDefault} AS is_default,
          r.${RecordatorioTable.scheduledAt} AS scheduled_at,
          r.${RecordatorioTable.recurrencia} AS recurrency,
          r.${RecordatorioTable.categoryId} AS category_id,
          c.${CategoriasTable.name} AS category_name,
          c.${CategoriasTable.iconName} AS category_icon,
          c.${CategoriasTable.iconColorValue} AS category_color
        FROM ${RecordatorioTable.table} r
        LEFT JOIN ${CategoriasTable.table} c ON r.${RecordatorioTable.categoryId} = c.${CategoriasTable.id}
      ''');

    return maps.map(InfoCardRecordatorio.fromMap).toList();
  }

  Future<InfoCardRecordatorio?> fetchDetailedRecordatorioById(int id) async {
    final db = _database ?? await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
        SELECT
          r.${RecordatorioTable.id} AS id,
          r.${RecordatorioTable.title} AS title,
          r.${RecordatorioTable.enabled} AS is_enabled,
          r.${RecordatorioTable.isDefault} AS is_default,
          r.${RecordatorioTable.scheduledAt} AS scheduled_at,
          r.${RecordatorioTable.recurrencia} AS recurrency,
          r.${RecordatorioTable.categoryId} AS category_id,
          c.${CategoriasTable.name} AS category_name,
          c.${CategoriasTable.iconName} AS category_icon,
          c.${CategoriasTable.iconColorValue} AS category_color
        FROM ${RecordatorioTable.table} r
        LEFT JOIN ${CategoriasTable.table} c ON r.${RecordatorioTable.categoryId} = c.${CategoriasTable.id}
        WHERE r.id = ?
      ''',
      [id],
    );

    if (maps.isEmpty) return null;
    return InfoCardRecordatorio.fromMap(maps.first);
  }

  Future<DetalleRecordatorio?> fetchDetalleRecordatorioById(int id) async {
    final db = _database ?? await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
        SELECT
          r.${RecordatorioTable.id} AS id,
          r.${RecordatorioTable.title} AS title,
          r.${RecordatorioTable.description} AS description,
          r.${RecordatorioTable.enabled} AS is_enabled,
          r.${RecordatorioTable.scheduledAt} AS scheduled_at,
          r.${RecordatorioTable.recurrencia} AS recurrency,
          r.${RecordatorioTable.isDefault} AS is_default,
          c.${CategoriasTable.id} AS category_id,
          c.${CategoriasTable.name} AS category_name,
          c.${CategoriasTable.iconName} AS category_icon,
          c.${CategoriasTable.iconColorValue} AS category_color
        FROM ${RecordatorioTable.table} r
        JOIN ${CategoriasTable.table} c ON r.${RecordatorioTable.categoryId} = c.${CategoriasTable.id}
        WHERE r.${RecordatorioTable.id} = ?
      ''',
      [id],
    );

    if (maps.isNotEmpty) {
      return DetalleRecordatorio.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<OperationResult<int?>> insertRecordatorio(
    Recordatorio recordatorio,
  ) async {
    final db = _database ?? await _dbHelper.database;
    try {
      final id = await db.insert(RecordatorioTable.table, recordatorio.toMap());
      return OperationResult<int?>(
        message: 'Recordatorio insertado con éxito',
        data: id,
        success: true,
      );
    } catch (e, stackTrace) {
      AppLogger.reportError('Crear recordatorio', e, stackTrace);
      return OperationResult<int?>(
        message: 'Error al insertar el recordatorio: $e',
        success: false,
      );
    }
  }

  Future<OperationResult<int?>> updateRecordatorio(
    Recordatorio recordatorio,
  ) async {
    final db = _database ?? await _dbHelper.database;
    try {
      final date = resolveReminderDate(
        recordatorio.scheduledAt,
        recordatorio.recurrencia,
        DateTime.now(),
      );
      if (date == null) {
        return OperationResult<int?>(
          success: false,
          message:
              'La fecha del recordatorio está vencida. Seleccione una fecha futura.',
        );
      }
      final count = await db.update(
        RecordatorioTable.table,
        recordatorio.copyWith(scheduledAt: date).toMap(),
        where: '${RecordatorioTable.id} = ?',
        whereArgs: [recordatorio.id],
      );
      return OperationResult<int?>(
        message: 'Recordatorio actualizado con éxito',
        data: count,
        success: true,
      );
    } catch (e, stackTrace) {
      AppLogger.reportError('Actualizar recordatorio', e, stackTrace);
      return OperationResult<int?>(
        message: 'Error al actualizar el recordatorio: $e',
        success: false,
      );
    }
  }

  Future<OperationResult<int?>> updateRecordatorioEnabled(
    int id,
    bool enabled,
  ) async {
    final db = _database ?? await _dbHelper.database;
    try {
      return await db.transaction((txn) async {
        final values = <String, Object?>{
          RecordatorioTable.enabled: enabled ? 1 : 0,
        };
        if (enabled) {
          final rows = await txn.query(
            RecordatorioTable.table,
            where: '${RecordatorioTable.id} = ?',
            whereArgs: [id],
          );
          if (rows.isEmpty) {
            return OperationResult<int?>(
              success: false,
              message: 'El recordatorio no existe.',
            );
          }
          final reminder = Recordatorio.fromMap(rows.single);
          final date = resolveReminderDate(
            reminder.scheduledAt,
            reminder.recurrencia,
            DateTime.now(),
          );
          if (date == null) {
            return OperationResult<int?>(
              success: false,
              message:
                  'No se puede reactivar recordatorios vencidos sin recurrencia.',
            );
          }
          values[RecordatorioTable.scheduledAt] = date.toIso8601String();
        }
        final count = await txn.update(
          RecordatorioTable.table,
          values,
          where: '${RecordatorioTable.id} = ?',
          whereArgs: [id],
        );
        return OperationResult<int?>(
          message: 'Estado del recordatorio actualizado con éxito',
          data: count,
          success: count > 0,
        );
      });
    } catch (e, stackTrace) {
      AppLogger.reportError('Cambiar estado del recordatorio', e, stackTrace);
      return OperationResult<int?>(
        message: 'Error al actualizar el estado del recordatorio: $e',
        success: false,
      );
    }
  }

  Future<OperationResult<int?>> deleteRecordatorio(int id) async {
    final db = _database ?? await _dbHelper.database;
    try {
      final rowsAffected = await db.delete(
        RecordatorioTable.table,
        where: '${RecordatorioTable.id} = ?',
        whereArgs: [id],
      );
      return OperationResult<int?>(
        message: 'Recordatorio eliminado con éxito',
        data: rowsAffected,
        success: true,
      );
    } catch (e, stackTrace) {
      AppLogger.reportError('Eliminar recordatorio', e, stackTrace);
      return OperationResult<int?>(
        message: 'Error al eliminar el recordatorio: $e',
        success: false,
      );
    }
  }

  Future<OperationResult<int>> deleteAllRecordatorios() async {
    final db = _database ?? await _dbHelper.database;
    final result = await db.delete(RecordatorioTable.table);

    return OperationResult<int>(
      success: result > 0,
      data: result,
      message: result > 0
          ? 'Todos los recordatorios eliminados exitosamente.'
          : 'Error al eliminar los recordatorios.',
    );
  }
}
