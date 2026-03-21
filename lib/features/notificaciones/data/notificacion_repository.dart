import 'package:control_financiero/features/notificaciones/data/notificacion_local_datasource.dart';
import 'package:control_financiero/features/notificaciones/models/notificacion.dart';

class NotificacionRepository {
  final NotificacionLocalDataSource localDataSource;
  final List<Notificacion> notificaciones = [];

  NotificacionRepository(this.localDataSource);

  Future<List<Notificacion>> fetchNotificaciones({int offset = 0}) async {
    notificaciones.clear();

    notificaciones.addAll(
      await localDataSource.fetchNotificaciones(offset: offset),
    );

    return notificaciones;
  }

  Future<int> countNotificaciones() async {
    final count = await localDataSource.countNotificaciones();

    return count;
  }

  Future<int> getUnreadCount() async {
    final count = await localDataSource.countUnreadNotificaciones();

    return count;
  }

  Future<void> markAsRead(int id) async {
    await localDataSource.markAsRead(id);
  }

  Future<void> markAllRead() async {
    await localDataSource.markAllAsRead();
  }

  Future<bool> addNotificacion(Notificacion notificacion) async {
    final result = await localDataSource.insertNotificacion(notificacion);
    if (result.success) {
      notificaciones.add(notificacion.copyWith(id: result.data!));
    }

    return result.success;
  }

  Future<bool> deleteNotificacion(int id) async {
    final result = await localDataSource.deleteNotificacion(id);
    if (result.success) {
      notificaciones.removeWhere((n) => n.id == id);
    }

    return result.success;
  }
}
