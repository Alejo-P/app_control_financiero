import 'package:control_financiero/core/database/db_helper.dart';
import 'package:control_financiero/core/database/db_tables.dart';
import 'package:control_financiero/core/models/operation_result.dart';
import 'package:control_financiero/features/notificaciones/models/notificacion.dart';
import 'package:sqflite/sqflite.dart';

class NotificacionLocalDataSource {
  final DBHelper _dbHelper = DBHelper.instance;

  Future<int> countNotificaciones() async {
    final db = await _dbHelper.database;

    final result = await db.query(
      NotificacionTable.table,
      columns: ['COUNT(*) as count'],
    );

    return result.first['count'] as int;
  }

  Future<int> countUnreadNotificaciones() async {
    final db = await _dbHelper.database;

    final int count =
        Sqflite.firstIntValue(
          await db.rawQuery(
            '''
            SELECT COUNT(*) FROM ${NotificacionTable.table}
            WHERE ${NotificacionTable.isRead} = ?
            ''',
            [0],
          ),
        ) ??
        0;

    return count;
  }

  Future<List<Notificacion>> fetchNotificaciones({int offset = 0}) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> results = await db.query(
      NotificacionTable.table,
      orderBy: '${NotificacionTable.createdAt} DESC',
      limit: 10,
      offset: offset,
    );

    return results.map((e) => Notificacion.fromMap(e)).toList();
  }

  Future<void> markAsRead(int id) async {
    final db = await _dbHelper.database;

    await db.update(
      NotificacionTable.table,
      {NotificacionTable.isRead: 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markAllAsRead() async {
    final db = await _dbHelper.database;

    await db.update(NotificacionTable.table, {NotificacionTable.isRead: 1});
  }

  Future<OperationResult<int>> insertNotificacion(
    Notificacion notificacion,
  ) async {
    final db = await _dbHelper.database;

    final id = await db.insert(NotificacionTable.table, notificacion.toMap());

    return OperationResult<int>(success: id > 0, data: id, message: '');
  }

  Future<OperationResult<int>> deleteNotificacion(int id) async {
    final db = await _dbHelper.database;

    final result = await db.delete(
      NotificacionTable.table,
      where: 'id = ?',
      whereArgs: [id],
    );

    return OperationResult<int>(success: result > 0, data: result, message: '');
  }
}
