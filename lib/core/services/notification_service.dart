import 'package:control_financiero/core/constants/app_routes.dart';
import 'package:control_financiero/core/services/navigation_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

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
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'Notificaciones',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      0,
      title,
      body,
      details,
      payload: 'notificacion:$id',
    );
  }

  static Future<NotificationAppLaunchDetails?> getLaunchDetails() async {
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
