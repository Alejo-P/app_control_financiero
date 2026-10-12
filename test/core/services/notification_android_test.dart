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
  var exactAccess = false;
  String? scheduleError;
  var pending = <Map<String, Object?>>[];
  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    tz_data.initializeTimeZones();
    calls.clear();
    denied = false;
    exactDenied = false;
    exactAccess = false;
    scheduleError = null;
    pending = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'initialize') return true;
          if (call.method == 'canScheduleExactNotifications') {
            return exactAccess;
          }
          if (call.method == 'requestExactAlarmsPermission') return !denied;
          if (call.method == 'requestNotificationsPermission') return !denied;
          if (call.method == 'pendingNotificationRequests') return pending;
          if (call.method == 'zonedSchedule' && scheduleError != null) {
            throw PlatformException(code: scheduleError!);
          }
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

  test('no solicita acceso exacto cuando ya está concedido', () async {
    exactAccess = true;
    expect(await NotificationService.requestExactAlarmAccess(), isTrue);
    expect(calls.map((c) => c.method), ['canScheduleExactNotifications']);
  });

  test('solicita acceso exacto y respeta concesión o denegación', () async {
    expect(await NotificationService.requestExactAlarmAccess(), isTrue);
    denied = true;
    expect(await NotificationService.requestExactAlarmAccess(), isFalse);
    expect(calls.map((c) => c.method), [
      'canScheduleExactNotifications',
      'requestExactAlarmsPermission',
      'canScheduleExactNotifications',
      'requestExactAlarmsPermission',
    ]);
  });

  test('no solicita acceso Android en iOS', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    expect(await NotificationService.requestExactAlarmAccess(), isTrue);
    expect(calls, isEmpty);
  });

  test('notificación general conserva la solicitud al reintentar', () async {
    exactDenied = true;
    await NotificationService.scheduleNotification(
      id: 42,
      title: 'Pago',
      body: 'Aviso',
      type: 'gasto',
      scheduledDate: DateTime(2099, 3, 4, 12, 30),
    );
    final schedules = calls.where((c) => c.method == 'zonedSchedule').toList();
    expect(schedules, hasLength(2));
    expect(schedules.first.arguments['payload'], 'notificacion:42');
    final first = Map<dynamic, dynamic>.from(schedules.first.arguments as Map);
    final last = Map<dynamic, dynamic>.from(schedules.last.arguments as Map);
    final firstDetails = Map<dynamic, dynamic>.from(
      first.remove('platformSpecifics') as Map,
    );
    final lastDetails = Map<dynamic, dynamic>.from(
      last.remove('platformSpecifics') as Map,
    );
    expect(firstDetails.remove('scheduleMode'), 'exactAllowWhileIdle');
    expect(lastDetails.remove('scheduleMode'), 'inexactAllowWhileIdle');
    expect(last, first);
    expect(lastDetails, firstDetails);
  });

  for (final reminder in [false, true]) {
    test(
      'propaga errores sin reintentos ilimitados: reminder=$reminder',
      () async {
        Future<void> schedule() => reminder
            ? NotificationService.scheduleRecordatorioNotification(
                id: 1,
                title: 'Pago',
                body: 'Aviso',
                scheduledDate: DateTime(2099),
              )
            : NotificationService.scheduleNotification(
                id: 1,
                title: 'Pago',
                body: 'Aviso',
                type: 'gasto',
                scheduledDate: DateTime(2099),
              );
        scheduleError = 'other_error';
        await expectLater(schedule(), throwsA(isA<PlatformException>()));
        expect(calls.where((c) => c.method == 'zonedSchedule'), hasLength(1));
        calls.clear();
        scheduleError = 'exact_alarms_not_permitted';
        await expectLater(schedule(), throwsA(isA<PlatformException>()));
        expect(calls.where((c) => c.method == 'zonedSchedule'), hasLength(2));
      },
    );
  }

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
    expect(schedules.last.arguments['payload'], 'recordatorio:1');
    expect(
      schedules.last.arguments['scheduledDateTime'],
      schedules.first.arguments['scheduledDateTime'],
    );
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
