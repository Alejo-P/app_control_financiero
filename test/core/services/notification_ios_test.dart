import 'package:control_financiero/core/services/notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  final calls = <MethodCall>[];
  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    tz_data.initializeTimeZones();
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return call.method == 'initialize' ? true : null;
        });
  });
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('iOS inicializa sin excepción y solicita permisos Darwin', () async {
    await NotificationService.init();
    final init = calls.singleWhere((call) => call.method == 'initialize');
    expect(init.arguments['requestAlertPermission'], isTrue);
    expect(init.arguments['requestSoundPermission'], isTrue);
    expect(
      calls.any((call) => call.method == 'requestNotificationsPermission'),
      isFalse,
    );
  });

  test('iOS recibe detalles para presentar el recordatorio', () async {
    await NotificationService.init();
    await NotificationService.scheduleRecordatorioNotification(
      id: 1,
      title: 'Pago',
      body: 'Recordatorio',
      scheduledDate: DateTime.now().add(const Duration(days: 1)),
    );
    final schedule = calls.singleWhere(
      (call) => call.method == 'zonedSchedule',
    );
    expect(schedule.arguments['platformSpecifics'], isNotNull);
    expect(schedule.arguments['payload'], 'recordatorio:1');
  });
}
