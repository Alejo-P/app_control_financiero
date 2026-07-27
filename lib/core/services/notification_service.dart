import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:control_financiero/app/app_routes.dart';
import 'package:control_financiero/core/services/navigation_service.dart';
import 'package:control_financiero/features/notificaciones/data/notificacion_local_datasource.dart';
import 'package:control_financiero/features/notificaciones/data/notificacion_repository.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';

int getSummaryId(String type) {
  return type.codeUnits.fold(0, (a, b) => a + b);
}

bool _isMobile() {
  return Platform.isAndroid || Platform.isIOS;
}

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final _notificationRepository = NotificacionRepository(
    NotificacionLocalDataSource(),
  );

  static Future<void> init() async {
    const android = AndroidInitializationSettings('ic_notification');

    const settings = InitializationSettings(android: android);

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;

        if (payload != null) {
          handleNotificationTap(payload);
        }
      },
    );
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    required int id,
    required String type,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'channel_id',
      'Notificaciones',
      icon: 'ic_notification',
      importance: Importance.max,
      priority: Priority.high,
      groupKey: 'notif_group_$type',
    );

    final details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      id,
      title,
      body,
      details,
      payload: 'notificacion:$id',
    );

    final unreadCount = await _notificationRepository.getUnreadCountByType(
      type,
    );

    if (unreadCount > 0) {
      await _showSummaryNotification(type, unreadCount);
    } else {
      await cancelNotification(getSummaryId(type));
    }
  }

  static Future<void> _showSummaryNotification(
    String type,
    int unreadCount,
  ) async {
    final latest = await _notificationRepository.fetchLatestNotificacionByType(
      type,
    );

    final androidDetails = AndroidNotificationDetails(
      'channel_id',
      'Notificaciones',
      icon: 'ic_notification',
      importance: Importance.max,
      priority: Priority.high,
      groupKey: 'notif_group_$type',
      setAsGroupSummary: true,
      styleInformation: InboxStyleInformation(
        [latest?.title ?? 'Notificaciones'],
        contentTitle: 'Notificaciones',
        summaryText: 'Tienes $unreadCount nuevas notificaciones',
      ),
    );

    final details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      getSummaryId(type),
      'Tienes $unreadCount nuevas notificaciones',
      'Toca para verlas',
      details,
      payload: 'notificacion_summary:$type',
    );
  }

  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required int id,
    required String type,
    required DateTime scheduledDate,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'channel_id',
      'Notificaciones',
      icon: 'ic_notification',
      importance: Importance.max,
      priority: Priority.high,
      groupKey: 'notif_group_$type',
    );
    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);
    final details = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      details,
      payload: 'notificacion:$id',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelNotification(int id) async {
    if (!_isMobile()) {
      return;
    }

    final pending = await _notifications.pendingNotificationRequests();

    debugPrint('Pendientes: ${pending.length}');

    for (final p in pending) {
      debugPrint('${p.id} - ${p.title}');
    }
    debugPrint('Cancelando notificación $id');

    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    if (!_isMobile()) {
      return;
    }

    await _notifications.cancelAll();
  }

  static Future<NotificationAppLaunchDetails?> getLaunchDetails() async {
    if (!_isMobile()) {
      return null;
    }

    return await _notifications.getNotificationAppLaunchDetails();
  }

  static void handleNotificationTap(String payload) {
    if (payload.startsWith('notificacion:')) {
      final id = int.parse(payload.split(':')[1]);

      navigatorKey.currentState?.pushNamed(
        AppRoutes.notifDetalleRoute,
        arguments: id,
      );
    }
  }
}
