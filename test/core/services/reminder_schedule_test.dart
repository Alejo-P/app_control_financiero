import 'package:control_financiero/core/services/reminder_schedule.dart';
import 'package:control_financiero/features/recordatorios/models/recordatorio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 9, 21, 10);
  Recordatorio reminder({
    int id = 1,
    Recurrencia recurrence = Recurrencia.diario,
    DateTime? date,
    bool enabled = true,
    bool isDefault = false,
  }) => Recordatorio(
    id: id,
    title: 'Aviso',
    scheduledAt: date ?? DateTime(2026, 9, 21, 20),
    recurrencia: recurrence,
    enabled: enabled,
    isDefault: isDefault,
  );

  test(
    'cada recurrencia usa el calendario nativo y ninguna es de una sola vez',
    () {
      final expected = {
        Recurrencia.diario: DateTimeComponents.time,
        Recurrencia.semanal: DateTimeComponents.dayOfWeekAndTime,
        Recurrencia.mensual: DateTimeComponents.dayOfMonthAndTime,
        Recurrencia.anual: DateTimeComponents.dateAndTime,
      };
      for (final entry in expected.entries) {
        final plan = buildReminderSchedule([
          reminder(recurrence: entry.key),
        ], now);
        expect(plan, hasLength(1));
        expect(plan.single.components, entry.value);
      }
    },
  );

  test(
    'un aviso no recurrente solo se programa una vez y no revive al vencer',
    () {
      final once = reminder(recurrence: Recurrencia.ninguno);
      expect(buildReminderSchedule([once], now).single.components, isNull);
      expect(buildReminderSchedule([once], DateTime(2026, 9, 22)), isEmpty);
    },
  );

  test('desactivar un recordatorio elimina todas sus ocurrencias', () {
    expect(
      buildReminderSchedule([reminder(enabled: false, isDefault: true)], now),
      isEmpty,
    );
    expect(buildReminderSchedule([], now), isEmpty);
  });

  test(
    'registrar movimientos suprime hoy pero conserva próximos avisos diarios',
    () {
      final plan = buildReminderSchedule(
        [reminder(isDefault: true)],
        now,
        hasMovementsToday: true,
      );
      expect(plan, hasLength(60));
      expect(plan.first.date, DateTime(2026, 9, 22, 20));
      expect(plan.every((p) => p.components == null), isTrue);
      expect(plan.map((p) => p.notificationId).toSet(), hasLength(60));
      final regular = buildReminderSchedule(
        [reminder()],
        now,
        hasMovementsToday: true,
      );
      expect(regular.single.date.day, 21);
    },
  );

  test('fecha futura nunca dispara antes del inicio solicitado', () {
    final future = reminder(date: DateTime(2026, 10, 10, 20));
    final plan = buildReminderSchedule([future], now);
    expect(plan.first.date, future.scheduledAt);
    expect(plan.every((p) => p.components == null), isTrue);
    final resumed = buildReminderSchedule([future], DateTime(2026, 10, 10, 10));
    expect(resumed.single.components, DateTimeComponents.time);
  });

  test('respeta el límite global y reserva espacio para cada recordatorio', () {
    final plan = buildReminderSchedule(
      [
        reminder(date: DateTime(2026, 10, 1, 20)),
        reminder(id: 2, date: DateTime(2027, 1, 1, 20)),
      ],
      now,
      limit: 3,
    );
    expect(plan, hasLength(3));
    expect(plan.map((p) => p.reminder.id).toSet(), {1, 2});
    expect(buildReminderSchedule([reminder()], now, limit: 0), isEmpty);
  });

  test('recurrencia mensual mantiene el día 31 y omite meses sin ese día', () {
    final next = calculateNextOccurrence(
      DateTime(2026, 1, 31, 20),
      Recurrencia.mensual,
    );
    expect(next, DateTime(2026, 3, 31, 20));
  });

  test('recurrencia anual mantiene el 29 de febrero', () {
    expect(
      calculateNextOccurrence(DateTime(2024, 2, 29, 20), Recurrencia.anual),
      DateTime(2028, 2, 29, 20),
    );
  });

  test('un recordatorio vencido recupera la siguiente fecha futura', () {
    final plan = buildReminderSchedule([
      reminder(date: DateTime(2026, 9, 1, 20)),
    ], now);
    expect(plan.single.date, DateTime(2026, 9, 21, 20));
    expect(plan.single.components, DateTimeComponents.time);
  });
}
