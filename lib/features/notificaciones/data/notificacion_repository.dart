import 'package:control_financiero/core/models/operation_result.dart';
import 'package:control_financiero/features/notificaciones/data/notificacion_local_datasource.dart';
import 'package:control_financiero/features/notificaciones/models/budget_notification_event.dart';
import 'package:control_financiero/features/notificaciones/models/notificacion.dart';

class NotificacionRepository {
  final NotificacionLocalDataSource localDataSource;

  NotificacionRepository(this.localDataSource);

  Future<List<Notificacion>> fetchNotificaciones({int offset = 0}) async {
    return await localDataSource.fetchNotificaciones(offset: offset);
  }

  Future<Notificacion?> fetchNotificacionById(int id) async {
    return await localDataSource.fetchNotificacionById(id);
  }

  Future <Notificacion?> fetchLatestNotificacionByType(String type) async {
    return await localDataSource.fetchLatestNotificacionByType(type);
  }

  Future<List<double>> fetchGlobalEnabledThresholds() async {
    final budgetNotifications = await localDataSource.fetchGlobalEnabledThresholds();
    
    return budgetNotifications.map((n) => n.threshold).toList();
  }

  Future<List<double>> fetchEnabledThresholdsByCategoryId(
    int categoryID,
  ) async {
    final budgetNotifications = await localDataSource.fetchEnabledThresholdsByCategoryId(
      categoryID,
    );
    
    return budgetNotifications.map((n) => n.threshold).toList();
  }

  Future<List<BudgetNotificationEvent>>
  fetchBudgetNotificationEventsByCategoryIdAndDate(
    int categoryId,
    DateTime date,
  ) async {
    return await localDataSource
        .fetchBudgetNotificationEventsByCategoryIdAndDate(categoryId, date);
  }

  Future<int> countNotificaciones() async {
    final count = await localDataSource.countNotificaciones();

    return count;
  }

  Future<int> getUnreadCount() async {
    final count = await localDataSource.countUnreadNotificaciones();

    return count;
  }

  Future<int> getUnreadCountByType(String type) async {
    final count = await localDataSource.countUnreadNotificacionesByType(type);

    return count;
  }

  Future<void> markAsRead(int id) async {
    await localDataSource.markAsRead(id);
  }

  Future<void> markAllRead() async {
    await localDataSource.markAllAsRead();
  }

  Future<OperationResult<int>> addNotificacion(
    Notificacion notificacion,
  ) async {
    final result = await localDataSource.insertNotificacion(notificacion);

    return result;
  }

  Future<OperationResult<int>> addBudgetNotificationEvent(
    BudgetNotificationEvent event,
  ) async {
    final result = await localDataSource.insertBudgetNotificationEvent(event);

    return result;
  }

  Future<OperationResult<int>> updateBudgetNotificationEvent(
    BudgetNotificationEvent event,
  ) async {
    final result = await localDataSource.updateBudgetNotificationEvent(event);

    return result;
  }

  Future<bool> deleteNotificacion(int id) async {
    final result = await localDataSource.deleteNotificacion(id);

    return result.success;
  }

  Future<OperationResult<int>> deleteAllNotificaciones() async {
    final result = await localDataSource.deleteAllNotificaciones();

    return result;
  }
}
