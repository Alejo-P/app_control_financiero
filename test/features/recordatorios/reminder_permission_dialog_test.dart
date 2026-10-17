import 'package:control_financiero/features/recordatorios/presentation/reminder_permission_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  final calls = <String>[];
  var granted = false;
  var requestResult = true;
  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    calls.clear();
    granted = false;
    requestResult = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call.method);
          if (call.method == 'canScheduleExactNotifications') return granted;
          if (call.method == 'requestExactAlarmsPermission') {
            return requestResult;
          }
          return null;
        });
  });
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  for (final confirm in [true, false]) {
    testWidgets('solicita permiso solo al confirmar: $confirm', (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await confirmReminderExactAlarmAccess(context);
                },
                child: const Text('Activar'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Activar'));
      await tester.pumpAndSettle();
      expect(find.text('Permiso de alarmas exactas'), findsOneWidget);
      expect(calls, ['canScheduleExactNotifications']);
      await tester.tap(
        find.text(confirm ? 'Ir a configuración' : 'Continuar sin permiso'),
      );
      await tester.pumpAndSettle();
      expect(result, confirm);
      expect(calls.contains('requestExactAlarmsPermission'), confirm);
      debugDefaultTargetPlatformOverride = null;
    });
  }

  testWidgets('permiso concedido omite el diálogo', (tester) async {
    granted = true;
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                result = await confirmReminderExactAlarmAccess(context);
              },
              child: const Text('Activar'),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('Activar'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
    expect(find.text('Permiso de alarmas exactas'), findsNothing);
    expect(calls, ['canScheduleExactNotifications']);
    debugDefaultTargetPlatformOverride = null;
  });
}
