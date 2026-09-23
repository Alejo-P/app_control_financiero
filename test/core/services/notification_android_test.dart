import 'package:control_financiero/core/services/notification_service.dart';
import 'package:control_financiero/features/recordatorios/models/recordatorio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  final calls = <MethodCall>[];
  var denied = false;
  var exactDenied = false;
  var pending = <Map<String, Object?>>[];
  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    tz_data.initializeTimeZones();
    calls.clear();
    denied = false;
    exactDenied = false;
    pending = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'initialize') return true;
          if (call.method == 'requestNotificationsPermission') return !denied;
          if (call.method == 'pendingNotificationRequests') return pending;
          if (call.method == 'zonedSchedule' && exactDenied) {
            exactDenied = false;
            throw PlatformException(code: 'exact_alarms_not_permitted');
          }
          return null;
        });
  });
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
    'solicita permisos después de inicializar y tolera la denegación',
    () async {
      denied = true;
      await NotificationService.init();
      expect(calls.map((c) => c.method), [
        'initialize',
        'requestNotificationsPermission',
      ]);
    },
  );

  test('la alternativa inexacta conserva la recurrencia', () async {
    exactDenied = true;
    await NotificationService.scheduleRecordatorioNotification(
      id: 1,
      title: 'Pago',
      body: 'Aviso',
      scheduledDate: DateTime.now().add(const Duration(days: 1)),
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
    final schedules = calls.where((c) => c.method == 'zonedSchedule').toList();
    expect(schedules, hasLength(2));
    expect(
      schedules.last.arguments['matchDateTimeComponents'],
      DateTimeComponents.dayOfWeekAndTime.index,
    );
    expect(
      schedules.last.arguments['platformSpecifics']['scheduleMode'],
      'inexactAllowWhileIdle',
    );
  });

  test(
    'desactivar cancela toda la cola del recordatorio sin tocar otras alertas',
    () async {
      pending = [
        {
          'id': 100001,
          'title': 'Aviso',
          'body': '',
          'payload': 'recordatorio:1',
        },
        {'id': -65, 'title': 'Aviso', 'body': '', 'payload': 'recordatorio:1'},
        {'id': 5, 'title': 'Otra', 'body': '', 'payload': 'notificacion:5'},
      ];
      await NotificationService.syncReminders([
        Recordatorio(
          id: 1,
          title: 'Aviso',
          scheduledAt: DateTime(2099),
          recurrencia: Recurrencia.diario,
          enabled: false,
          isDefault: true,
        ),
      ], now: DateTime.now());
      expect(
        calls.where((c) => c.method == 'cancel').map((c) => c.arguments['id']),
        containsAll([100001, -65]),
      );
      expect(
        calls.where((c) => c.method == 'cancel').map((c) => c.arguments['id']),
        isNot(contains(5)),
      );
      expect(calls.any((c) => c.method == 'zonedSchedule'), isFalse);
    },
  );

  test('programa toda la cola diferida con identificadores únicos', () async {
    await NotificationService.syncReminders([
      Recordatorio(
        id: 1,
        title: 'Futuro',
        scheduledAt: DateTime(2099, 1, 1, 20),
        recurrencia: Recurrencia.diario,
      ),
    ], now: DateTime.now());
    final schedules = calls.where((c) => c.method == 'zonedSchedule').toList();
    expect(schedules, hasLength(60));
    expect(schedules.map((c) => c.arguments['id']).toSet(), hasLength(60));
    expect(
      schedules.every((c) => c.arguments['matchDateTimeComponents'] == null),
      isTrue,
    );
  });

  test(
    'borrar el último recordatorio elimina las ejecuciones pendientes',
    () async {
      pending = [
        {
          'id': 100001,
          'title': 'Aviso',
          'body': '',
          'payload': 'recordatorio:1',
        },
      ];
      await NotificationService.syncReminders([], now: DateTime.now());
      expect(
        calls.any((c) => c.method == 'cancel' && c.arguments['id'] == 100001),
        isTrue,
      );
      expect(calls.any((c) => c.method == 'zonedSchedule'), isFalse);
    },
  );
}
