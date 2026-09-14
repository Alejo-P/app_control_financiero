import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:control_financiero/core/services/notification_service.dart';

void main() {
  group('NotificationService.resolveScheduleMode', () {
    test(
      'usa alarmas inexactas cuando falta el permiso de alarmas exactas',
      () {
        final exception = PlatformException(code: 'exact_alarms_not_permitted');

        final mode = NotificationService.resolveScheduleMode(exception);

        expect(mode, AndroidScheduleMode.inexactAllowWhileIdle);
      },
    );

    test('usa alarmas exactas cuando no hay error', () {
      final mode = NotificationService.resolveScheduleMode(null);

      expect(mode, AndroidScheduleMode.exactAllowWhileIdle);
    });

    test('conserva el modo exacto para otros errores de plataforma', () {
      expect(
        NotificationService.resolveScheduleMode(
          PlatformException(code: 'other_error'),
        ),
        AndroidScheduleMode.exactAllowWhileIdle,
      );
    });

    test('no confunde un error genérico con la falta de permiso', () {
      expect(
        NotificationService.resolveScheduleMode(
          Exception('exact_alarms_not_permitted'),
        ),
        AndroidScheduleMode.exactAllowWhileIdle,
      );
    });
  });

  group('identificadores de notificación', () {
    test('reserva el desplazamiento 100000 para recordatorios', () {
      expect(NotificationService.getRecordatorioNotificationId(0), 100000);
      expect(NotificationService.getRecordatorioNotificationId(42), 100042);
    });

    test('genera un identificador estable por tipo de resumen', () {
      expect(getSummaryId('gasto'), 542);
      expect(getSummaryId('ingreso'), 759);
      expect(getSummaryId(''), 0);
    });
  });
}
