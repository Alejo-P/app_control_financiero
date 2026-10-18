import 'dart:io';

import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/features/recordatorios/presentation/recordatorios_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../../support/app_state_fakes.dart';

class _State extends TestAppState {
  int syncs = 0;

  @override
  Future<void> loadRecordatoriosData({bool notify = true}) async {}

  @override
  Future<void> syncRecordatorioNotifications() async => syncs++;
}

void main() {
  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  late Directory directory;
  late _State state;
  late List<String> calls;
  var granted = false;
  var requestResult = true;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('reminder_permission_');
    Hive.init(directory.path);
    await Hive.openBox<dynamic>('settings');
    state = _State()..loadingInitialData = false;
    calls = [];
    granted = false;
    requestResult = true;
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
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

  tearDown(() async {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    state.dispose();
    await Hive.close();
    await directory.delete(recursive: true);
  });

  Future<void> open(WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: state,
          child: const MaterialApp(home: RecordatoriosPage()),
        ),
      );
      await tester.pump();
      // Let the real Hive write finish outside the fake async zone.
      await Hive.box<dynamic>('settings').flush();
    });
    await tester.pumpAndSettle();
  }

  for (final accept in [false, true]) {
    testWidgets('primera visita solicita permiso una sola vez: $accept', (
      tester,
    ) async {
      await open(tester);
      expect(find.text('Permiso de alarmas exactas'), findsOneWidget);
      await tester.tap(
        find.text(accept ? 'Ir a configuración' : 'Continuar sin permiso'),
      );
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      expect(state.syncs, accept ? 1 : 0);
      expect(calls.contains('requestExactAlarmsPermission'), accept);

      await tester.pumpWidget(const SizedBox.shrink());
      // Reopen persisted preferences as on a subsequent app session.
      await tester.runAsync(() async {
        await Hive.close();
        await Hive.openBox<dynamic>('settings');
      });
      calls.clear();
      await open(tester);
      expect(find.text('Permiso de alarmas exactas'), findsNothing);
      expect(calls, isEmpty);
      await tester.pumpWidget(const SizedBox.shrink());
      debugDefaultTargetPlatformOverride = null;
    });
  }

  testWidgets('permiso existente omite diálogo y resincroniza', (tester) async {
    granted = true;
    await open(tester);
    expect(find.text('Permiso de alarmas exactas'), findsNothing);
    expect(state.syncs, 1);
    expect(calls, ['canScheduleExactNotifications']);
    await tester.pumpWidget(const SizedBox.shrink());
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('volver sin conceder permiso no resincroniza', (tester) async {
    requestResult = false;
    await open(tester);
    await tester.tap(find.text('Ir a configuración'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    expect(state.syncs, 0);
    expect(calls, contains('requestExactAlarmsPermission'));
    await tester.pumpWidget(const SizedBox.shrink());
    debugDefaultTargetPlatformOverride = null;
  });
}
