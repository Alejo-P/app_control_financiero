import 'package:control_financiero/core/database/db_helper.dart';
import 'package:control_financiero/core/database/db_tables.dart';
import 'package:control_financiero/features/recordatorios/models/info_card_recordatorio.dart';

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
}
