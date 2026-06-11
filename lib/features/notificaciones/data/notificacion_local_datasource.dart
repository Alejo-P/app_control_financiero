import 'package:control_financiero/core/database/db_helper.dart';
import 'package:control_financiero/core/database/db_tables.dart';
import 'package:control_financiero/core/models/operation_result.dart';
import 'package:control_financiero/core/utils/app_logger.dart';
import 'package:control_financiero/features/notificaciones/models/budget_notification.dart';
import 'package:control_financiero/features/notificaciones/models/budget_notification_event.dart';
import 'package:control_financiero/features/notificaciones/models/movement_notification_config.dart';
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

  Future<int> countUnreadNotificacionesByType(String type) async {
    final db = await _dbHelper.database;

    final int count =
        Sqflite.firstIntValue(
          await db.rawQuery(
            '''
            SELECT COUNT(*) FROM ${NotificacionTable.table}
            WHERE ${NotificacionTable.isRead} = ? AND ${NotificacionTable.type} = ?
            ''',
            [0, type],
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

  Future<Notificacion?> fetchNotificacionById(int id) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> result = await db.query(
      NotificacionTable.table,
      where: '${NotificacionTable.id} = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return Notificacion.fromMap(result.first);
    }

    AppLogger.log(
      'Notificación con id $id no encontrada en la base de datos',
      level: LogLevel.warning,
    );
    return null;
  }

  Future<Notificacion?> fetchLatestNotificacionByType(String type) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> result = await db.query(
      NotificacionTable.table,
      where: '${NotificacionTable.type} = ?',
      whereArgs: [type],
      orderBy: '${NotificacionTable.createdAt} DESC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      return Notificacion.fromMap(result.first);
    }

    return null;
  }

  Future<List<BudgetNotification>> fetchBudgetNotifications() async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> results = await db.query(
      BudgetNotificationConfigTable.table,
    );

    return results.map((e) => BudgetNotification.fromMap(e)).toList();
  }

  Future<BudgetNotification?> fetchBudgetNotification(int id) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> result = await db.query(
      BudgetNotificationConfigTable.table,
      where: '${BudgetNotificationConfigTable.id} = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return BudgetNotification.fromMap(result.first);
    }

    return null;
  }

  Future<List<BudgetNotification>> fetchAllBudgetNotifications() async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> result = await db.query(
      BudgetNotificationConfigTable.table,
    );

    if (result.isNotEmpty) {
      return result.map((e) => BudgetNotification.fromMap(e)).toList();
    }

    return [];
  }

  Future<List<MovementNotificationConfig>>
  fetchAllMovementNotificationConfigs() async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> results = await db.query(
      MovementNotificationConfigTable.table,
    );

    return results.map((e) => MovementNotificationConfig.fromMap(e)).toList();
  }

  Future<MovementNotificationConfig?> fetchMovementNotificationConfigByType(
    String typeKey,
  ) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> result = await db.query(
      MovementNotificationConfigTable.table,
      where: '${MovementNotificationConfigTable.typeKey} = ?',
      whereArgs: [typeKey],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return MovementNotificationConfig.fromMap(result.first);
    }

    return null;
  }

  Future<OperationResult<int>> insertOrUpdateMovementNotificationConfig(
    MovementNotificationConfig config,
  ) async {
    final db = await _dbHelper.database;

    if (config.id != null) {
      final result = await db.update(
        MovementNotificationConfigTable.table,
        config.toMap(),
        where: '${MovementNotificationConfigTable.id} = ?',
        whereArgs: [config.id],
      );

      return OperationResult<int>(
        success: result > 0,
        data: config.id!,
        message: '',
      );
    }

    final updated = await db.update(
      MovementNotificationConfigTable.table,
      config.toMap(),
      where: '${MovementNotificationConfigTable.typeKey} = ?',
      whereArgs: [config.typeKey],
    );

    if (updated > 0) {
      final existing = await fetchMovementNotificationConfigByType(
        config.typeKey,
      );
      return OperationResult<int>(
        success: true,
        data: existing?.id,
        message: '',
      );
    }

    final id = await db.insert(
      MovementNotificationConfigTable.table,
      config.toMap(),
    );

    return OperationResult<int>(success: id > 0, data: id, message: '');
  }

  Future<List<BudgetNotification>> fetchGlobalEnabledThresholds() async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> results = await db.query(
      BudgetNotificationConfigTable.table,
      where:
          '${BudgetNotificationConfigTable.isEnabled} = ? AND ${BudgetNotificationConfigTable.categoryId} IS NULL',
      whereArgs: [1],
    );

    return results.map((e) => BudgetNotification.fromMap(e)).toList();
  }

  Future<List<BudgetNotification>> fetchEnabledThresholdsByCategoryId(
    int categoryID,
  ) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> result = await db.query(
      BudgetNotificationConfigTable.table,
      where:
          '${BudgetNotificationConfigTable.categoryId} = ? AND ${BudgetNotificationConfigTable.isEnabled} = ?',
      whereArgs: [categoryID, 1],
    );

    if (result.isNotEmpty) {
      return result.map((e) => BudgetNotification.fromMap(e)).toList();
    }

    return [];
  }

  Future<OperationResult<int>> insertOrUpdateBudgetNotification(
    BudgetNotification notification,
  ) async {
    final db = await _dbHelper.database;

    if (notification.id != null) {
      // Actualizar
      final result = await db.update(
        BudgetNotificationConfigTable.table,
        notification.toMap(),
        where: '${BudgetNotificationConfigTable.id} = ?',
        whereArgs: [notification.id],
      );

      return OperationResult<int>(
        success: result > 0,
        data: notification.id!,
        message: '',
      );
    } else {
      // Insertar
      final id = await db.insert(
        BudgetNotificationConfigTable.table,
        notification.toMap(),
      );

      return OperationResult<int>(success: id > 0, data: id, message: '');
    }
  }

  Future<OperationResult<int>> deleteBudgetNotification(int id) async {
    final db = await _dbHelper.database;

    final existing = await fetchBudgetNotification(id);
    if (existing == null) {
      return OperationResult<int>(
        success: false,
        data: 0,
        message: 'Notificación no encontrada',
      );
    }

    if (existing.isDefault) {
      return OperationResult<int>(
        success: false,
        data: 0,
        message: 'No se puede eliminar la configuración por defecto',
      );
    }

    final result = await db.delete(
      BudgetNotificationConfigTable.table,
      where: '${BudgetNotificationConfigTable.id} = ?',
      whereArgs: [id],
    );

    return OperationResult<int>(success: result > 0, data: result, message: '');
  }

  Future<OperationResult<int>> deleteAllBudgetNotifications() async {
    final db = await _dbHelper.database;

    final result = await db.delete(BudgetNotificationConfigTable.table);

    return OperationResult<int>(success: result > 0, data: result, message: '');
  }

  Future<List<BudgetNotificationEvent>> fetchBudgetNotificationEvents() async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> results = await db.query(
      BudgetNotificationEventsTable.table,
    );

    return results.map((e) => BudgetNotificationEvent.fromMap(e)).toList();
  }

  Future<List<BudgetNotificationEvent>>
  fetchBudgetNotificationEventsByCategoryIdAndDate(
    int categoryId,
    DateTime date,
  ) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      BudgetNotificationEventsTable.table,
      where:
          '${BudgetNotificationEventsTable.categoryId} = ? AND ${BudgetNotificationEventsTable.year} = ? AND ${BudgetNotificationEventsTable.month} = ?',
      whereArgs: [categoryId, date.year, date.month],
    );

    return result.map((e) => BudgetNotificationEvent.fromMap(e)).toList();
  }

  Future<OperationResult<int>> insertBudgetNotificationEvent(
    BudgetNotificationEvent event,
  ) async {
    final db = await _dbHelper.database;

    final id = await db.insert(
      BudgetNotificationEventsTable.table,
      event.toMap(),
    );

    return OperationResult<int>(success: id > 0, data: id, message: '');
  }

  Future<OperationResult<int>> updateBudgetNotificationEvent(
    BudgetNotificationEvent event,
  ) async {
    final db = await _dbHelper.database;

    final result = await db.update(
      BudgetNotificationEventsTable.table,
      event.toMap(),
      where: '${BudgetNotificationEventsTable.id} = ?',
      whereArgs: [event.id],
    );

    return OperationResult<int>(
      success: result > 0,
      data: event.id!,
      message: '',
    );
  }

  Future<OperationResult<int>> deleteAllBudgetNotificationEvent() async {
    final db = await _dbHelper.database;

    final result = await db.delete(BudgetNotificationEventsTable.table);

    return OperationResult<int>(success: result > 0, data: result, message: '');
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

  Future<OperationResult<int>> deleteAllNotificaciones() async {
    final db = await _dbHelper.database;

    final result = await db.delete(NotificacionTable.table);

    return OperationResult<int>(success: result > 0, data: result, message: '');
  }
}
