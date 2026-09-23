import 'package:control_financiero/features/recordatorios/models/recordatorio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ReminderSchedule {
  final Recordatorio reminder;
  final DateTime date;
  final DateTimeComponents? components;
  final int occurrence;

  const ReminderSchedule(
    this.reminder,
    this.date,
    this.components,
    this.occurrence,
  );

  int get notificationId => occurrence == 0
      ? 100000 + reminder.id!
      : -(reminder.id! * 64 + occurrence);
}

DateTimeComponents? recurrenceComponents(Recurrencia recurrence) =>
    switch (recurrence) {
      Recurrencia.diario => DateTimeComponents.time,
      Recurrencia.semanal => DateTimeComponents.dayOfWeekAndTime,
      Recurrencia.mensual => DateTimeComponents.dayOfMonthAndTime,
      Recurrencia.anual => DateTimeComponents.dateAndTime,
      Recurrencia.ninguno => null,
    };

/// The native calendar trigger ignores the start date and matches from today.
DateTime _nextNativeMatch(Recordatorio reminder, DateTime now) {
  final time = reminder.scheduledAt;
  var candidate = DateTime(
    now.year,
    now.month,
    now.day,
    time.hour,
    time.minute,
    time.second,
  );
  while (!candidate.isAfter(now) ||
      switch (reminder.recurrencia) {
        Recurrencia.semanal => candidate.weekday != time.weekday,
        Recurrencia.mensual => candidate.day != time.day,
        Recurrencia.anual =>
          candidate.month != time.month || candidate.day != time.day,
        _ => false,
      }) {
    candidate = DateTime(
      candidate.year,
      candidate.month,
      candidate.day + 1,
      time.hour,
      time.minute,
      time.second,
    );
  }
  return candidate;
}

/// Reserves one slot per reminder, then fills remaining slots with the nearest
/// deferred occurrences. iOS permits only 64 pending notification requests.
/// Reopening/syncing replenishes deferred dates and switches to native repeat
/// as soon as the calendar trigger can respect the requested start date.
List<ReminderSchedule> buildReminderSchedule(
  List<Recordatorio> reminders,
  DateTime now, {
  bool hasMovementsToday = false,
  int limit = 60,
}) {
  if (limit <= 0) return [];
  final first = <ReminderSchedule>[];
  final deferred = <ReminderSchedule>[];
  for (final reminder in reminders) {
    if (!reminder.enabled || reminder.id == null) continue;
    var next = reminder.scheduledAt;
    final recurring = reminder.recurrencia != Recurrencia.ninguno;
    while (!next.isAfter(now)) {
      if (!recurring) break;
      next = calculateNextOccurrence(next, reminder.recurrencia);
    }
    if (!next.isAfter(now)) continue;
    if (reminder.isDefault &&
        hasMovementsToday &&
        next.year == now.year &&
        next.month == now.month &&
        next.day == now.day) {
      if (!recurring) continue;
      next = calculateNextOccurrence(next, reminder.recurrencia);
    }
    final components =
        recurring && next.isAtSameMomentAs(_nextNativeMatch(reminder, now))
        ? recurrenceComponents(reminder.recurrencia)
        : null;
    first.add(ReminderSchedule(reminder, next, components, 0));
    if (recurring && components == null) {
      for (var i = 1; i < limit; i++) {
        next = calculateNextOccurrence(next, reminder.recurrencia);
        deferred.add(ReminderSchedule(reminder, next, null, i));
      }
    }
  }
  int byDate(ReminderSchedule a, ReminderSchedule b) =>
      a.date.compareTo(b.date);
  first.sort(byDate);
  deferred.sort(byDate);
  return [...first, ...deferred].take(limit).toList();
}
