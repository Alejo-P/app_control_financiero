import 'package:control_financiero/core/database/db_helper.dart';
import 'package:control_financiero/core/database/db_tables.dart';
import 'package:control_financiero/core/models/operation_result.dart';
import 'package:control_financiero/features/recordatorios/models/detalle_recordatorio.dart';
import 'package:control_financiero/features/recordatorios/models/info_card_recordatorio.dart';
import 'package:control_financiero/features/recordatorios/models/recordatorio.dart';

class RecordatoriosLocalDataSource {
  final DBHelper _dbHelper = DBHelper.instance;

  Future<List<InfoCardRecordatorio>> fetchAllRecordatorios() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT
          r.${RecordatorioTable.id} AS id,
          r.${RecordatorioTable.title} AS title,
          r.${RecordatorioTable.enabled} AS is_enabled,
          r.${RecordatorioTable.scheduledAt} AS scheduled_at,
          r.${RecordatorioTable.recurrencia} AS recurrency,
          c.${CategoriasTable.name} AS category_name,
          c.${CategoriasTable.iconName} AS category_icon,
          c.${CategoriasTable.iconColorValue} AS category_color
        FROM ${RecordatorioTable.table} r
        JOIN ${CategoriasTable.table} c ON r.${RecordatorioTable.categoryId} = c.${CategoriasTable.id}
      ''');

    return maps.map(InfoCardRecordatorio.fromMap).toList();
  }

  Future<DetalleRecordatorio?> fetchDetalleRecordatorioById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
        SELECT
          r.${RecordatorioTable.id} AS id,
          r.${RecordatorioTable.title} AS title,
          r.${RecordatorioTable.description} AS description,
          r.${RecordatorioTable.enabled} AS is_enabled,
          r.${RecordatorioTable.scheduledAt} AS scheduled_at,
          r.${RecordatorioTable.amount} AS amount,
          r.${RecordatorioTable.recurrencia} AS recurrency,
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
    final db = await _dbHelper.database;
    try {
      final id = await db.insert(RecordatorioTable.table, recordatorio.toMap());
      return OperationResult<int?>(
        message: 'Recordatorio insertado con éxito',
        data: id,
        success: true,
      );
    } catch (e) {
      return OperationResult<int?>(
        message: 'Error al insertar el recordatorio: $e',
        success: false,
      );
    }
  }

  Future<OperationResult<int?>> updateRecordatorio(
    Recordatorio recordatorio,
  ) async {
    final db = await _dbHelper.database;
    try {
      final count = await db.update(
        RecordatorioTable.table,
        recordatorio.toMap(),
        where: '${RecordatorioTable.id} = ?',
        whereArgs: [recordatorio.id],
      );
      return OperationResult<int?>(
        message: 'Recordatorio actualizado con éxito',
        data: count,
        success: true,
      );
    } catch (e) {
      return OperationResult<int?>(
        message: 'Error al actualizar el recordatorio: $e',
        success: false,
      );
    }
  }
}
