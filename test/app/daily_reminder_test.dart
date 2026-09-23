import 'package:control_financiero/features/recordatorios/models/recordatorio.dart';
import 'package:control_financiero/features/recordatorios/models/detalle_recordatorio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/app_state_fakes.dart';

class _Reminders extends FakeRecordatorios {
  List<Recordatorio> items = [];
  DetalleRecordatorio? detail;
  @override
  Future<DetalleRecordatorio?> fetchDetalleRecordatorioById(int id) async =>
      detail;
  @override
  Future<List<Recordatorio>> fetchAllRecordatorios() async => items.toList();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  final calls = <MethodCall>[];
  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'pendingNotificationRequests') return [];
          return null;
        });
  });
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
    'sincronizar movimientos nunca reactiva el recordatorio diario deshabilitado',
    () async {
      final repo = _Reminders();
      repo.items = [
        Recordatorio(
          id: 1,
          title: 'Diario',
          scheduledAt: DateTime(2026, 9, 21, 20),
          recurrencia: Recurrencia.diario,
          enabled: false,
          isDefault: true,
        ),
      ];
      final state = TestAppState(reminders: repo);
      // The fake movement repository throws for any query: disabled reminders
      // must be ignored even before consulting today's movements.
      await state.syncDailyMovementReminder(
        referenceDateTime: DateTime(2026, 9, 21, 10),
      );
      await state.syncDailyMovementReminder(
        referenceDateTime: DateTime(2026, 9, 22, 10),
      );
      expect(calls.where((c) => c.method == 'cancel'), hasLength(2));
      expect(
        calls.any((c) => c.method == 'zonedSchedule' || c.method == 'show'),
        isFalse,
      );
      state.dispose();
    },
  );

  test('no requiere que exista un recordatorio predeterminado', () async {
    final state = TestAppState(reminders: _Reminders());
    await state.syncDailyMovementReminder();
    expect(calls.any((c) => c.method == 'zonedSchedule'), isFalse);
    state.dispose();
  });

  test(
    'editar una recurrencia vencida propone la próxima fecha sin escribir en SQLite',
    () async {
      final repo = _Reminders();
      repo.detail = DetalleRecordatorio(
        id: 1,
        title: 'Pago',
        description: '',
        isEnabled: true,
        isDefault: false,
        scheduledAt: DateTime(2020, 1, 1, 20),
        recurrency: Recurrencia.diario.name,
        categoryId: 1,
        categoryName: 'Otros',
        categoryIcon: Icons.home,
        categoryColor: Colors.blue,
      );
      final state = TestAppState(reminders: repo);
      final now = DateTime.now();
      final detail = await state.getRecordatorioById(1);
      expect(detail!.scheduledAt.isAfter(now), isTrue);
      expect(
        detail.scheduledAt.difference(now),
        lessThan(const Duration(days: 2)),
      );
      expect(repo.detail!.scheduledAt.year, 2020);
      state.dispose();
    },
  );
}
