import 'package:flutter/foundation.dart';
import 'package:control_financiero/core/services/reminder_schedule.dart';
import 'package:control_financiero/features/recordatorios/models/recordatorio.dart';
import 'package:flutter/services.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:control_financiero/app/app_routes.dart';
import 'package:control_financiero/core/services/navigation_service.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/features/notificaciones/data/notificacion_local_datasource.dart';
import 'package:control_financiero/features/notificaciones/data/notificacion_repository.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

int getSummaryId(String type) {
  return type.codeUnits.fold(0, (a, b) => a + b);
}

bool _isMobile() {
  return !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
}

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final _notificationRepository = NotificacionRepository(
    NotificacionLocalDataSource(),
  );

  static int getRecordatorioNotificationId(int id) {
    return 100000 + id;
  }

  static Future<void> init() async {
    if (!_isMobile()) return;
    const android = AndroidInitializationSettings('ic_notification');

    const settings = InitializationSettings(
      android: android,
      iOS: DarwinInitializationSettings(),
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;

        if (payload != null) {
          handleNotificationTap(payload);
        }
      },
    );
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    required int id,
    required String type,
  }) async {
    if (!_isMobile()) return;
    final androidDetails = AndroidNotificationDetails(
      'channel_id',
      'Notificaciones',
      icon: 'ic_notification',
      importance: Importance.max,
      priority: Priority.high,
      groupKey: 'notif_group_$type',
      channelDescription: 'Notificaciones de la app',
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );

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
    if (defaultTargetPlatform != TargetPlatform.android) return;
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
      channelDescription: 'Notificaciones de la app',
      setAsGroupSummary: true,
      styleInformation: InboxStyleInformation(
        [latest?.title ?? 'Notificaciones'],
        contentTitle: 'Notificaciones',
        summaryText: 'Tienes $unreadCount nuevas notificaciones',
      ),
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );

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
      channelDescription: 'Notificaciones de la app',
      groupKey: 'notif_group_$type',
    );
    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);
    final details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );

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

  static AndroidScheduleMode resolveScheduleMode(Object? exception) {
    if (exception is PlatformException &&
        exception.code == 'exact_alarms_not_permitted') {
      return AndroidScheduleMode.inexactAllowWhileIdle;
    }

    return AndroidScheduleMode.exactAllowWhileIdle;
  }

  static Future<void> scheduleRecordatorioNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    DateTimeComponents? matchDateTimeComponents,
    int? notificationIdOverride,
  }) async {
    if (!_isMobile()) {
      return;
    }

    final notificationId =
        notificationIdOverride ?? getRecordatorioNotificationId(id);
    await cancelNotification(notificationId);

    if (scheduledDate.isBefore(currentDateTime)) {
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      'recordatorio_channel',
      'Recordatorios',
      icon: 'ic_notification',
      importance: Importance.max,
      priority: Priority.high,
      channelDescription: 'Alertas de recordatorios programados',
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );
    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

    try {
      await _notifications.zonedSchedule(
        notificationId,
        title,
        body,
        tzDate,
        details,
        payload: 'recordatorio:$id',
        matchDateTimeComponents: matchDateTimeComponents,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } on PlatformException catch (exception) {
      if (exception.code != 'exact_alarms_not_permitted') rethrow;
      await _notifications.zonedSchedule(
        notificationId,
        title,
        body,
        tzDate,
        details,
        payload: 'recordatorio:$id',
        matchDateTimeComponents: matchDateTimeComponents,
        androidScheduleMode: resolveScheduleMode(exception),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  static Future<void> syncReminders(
    List<Recordatorio> reminders, {
    required DateTime now,
    bool hasMovementsToday = false,
  }) async {
    if (!_isMobile()) return;
    final pending = await _notifications.pendingNotificationRequests();
    final unrelated = pending
        .where((item) => !(item.payload?.startsWith('recordatorio:') ?? false))
        .length;
    final plan = buildReminderSchedule(
      reminders,
      now,
      hasMovementsToday: hasMovementsToday,
      limit: (64 - unrelated).clamp(0, 60),
    );
    for (final item in pending) {
      if (item.payload?.startsWith('recordatorio:') ?? false) {
        await _notifications.cancel(item.id);
      }
    }
    // Also remove delivered alerts for reminders that have been disabled.
    for (final reminder in reminders.where((r) => !r.enabled && r.id != null)) {
      await _notifications.cancel(getRecordatorioNotificationId(reminder.id!));
    }
    for (final item in plan) {
      await scheduleRecordatorioNotification(
        id: item.reminder.id!,
        title: item.reminder.title,
        body: item.reminder.description?.trim().isNotEmpty == true
            ? item.reminder.description!
            : 'Te recordamos: ${item.reminder.title}',
        scheduledDate: item.date,
        matchDateTimeComponents: item.components,
        notificationIdOverride: item.notificationId,
      );
    }
  }

  static Future<void> cancelNotification(int id) async {
    if (!_isMobile()) {
      return;
    }

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
