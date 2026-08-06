import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:control_financiero/core/services/notification_service.dart';

void main() {
  group('NotificationService.resolveScheduleMode', () {
    test('uses inexact mode when exact alarms are not permitted', () {
      final exception = PlatformException(code: 'exact_alarms_not_permitted');

      final mode = NotificationService.resolveScheduleMode(exception);

      expect(mode, AndroidScheduleMode.inexactAllowWhileIdle);
    });

    test('keeps exact mode for other cases', () {
      final mode = NotificationService.resolveScheduleMode(null);

      expect(mode, AndroidScheduleMode.exactAllowWhileIdle);
    });
  });
}
