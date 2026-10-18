import 'package:control_financiero/core/database/db_tables.dart';

enum Recurrencia { diario, semanal, mensual, anual, ninguno }

/// Returns the first future occurrence, or null for an expired one-off reminder.
DateTime? resolveReminderDate(
  DateTime date,
  Recurrencia recurrence,
  DateTime now,
) {
  if (date.isAfter(now)) return date;
  if (recurrence == Recurrencia.ninguno) return null;
  var next = date;
  while (!next.isAfter(now)) {
    next = calculateNextOccurrence(next, recurrence);
  }
  return next;
}

extension RecurrenciaExtension on Recurrencia {
  String get name {
    switch (this) {
      case Recurrencia.diario:
        return 'Diario';
      case Recurrencia.semanal:
        return 'Semanal';
      case Recurrencia.mensual:
        return 'Mensual';
      case Recurrencia.anual:
        return 'Anual';
      case Recurrencia.ninguno:
        return 'Ninguno';
    }
  }
}

DateTime calculateNextOccurrence(DateTime current, Recurrencia recurrencia) {
  switch (recurrencia) {
    case Recurrencia.diario:
      return DateTime(
        current.year,
        current.month,
        current.day + 1,
        current.hour,
        current.minute,
        current.second,
      );
    case Recurrencia.semanal:
      return DateTime(
        current.year,
        current.month,
        current.day + 7,
        current.hour,
        current.minute,
        current.second,
      );
    case Recurrencia.mensual:
      var month = current.month + 1;
      while (DateTime(current.year, month + 1, 0).day < current.day) {
        month++;
      }
      return DateTime(
        current.year,
        month,
        current.day,
        current.hour,
        current.minute,
        current.second,
      );
    case Recurrencia.anual:
      var year = current.year + 1;
      while (DateTime(year, current.month + 1, 0).day < current.day) {
        year++;
      }
      return DateTime(
        year,
        current.month,
        current.day,
        current.hour,
        current.minute,
        current.second,
      );
    default:
      return current;
  }
}

class Recordatorio {
  final int? id;
  final String title;
  final String? description;
  final int? categoryId;
  final DateTime scheduledAt;
  final bool completed;
  final bool enabled;
  final bool isDefault;
  final Recurrencia recurrencia;

  Recordatorio({
    this.id,
    required this.title,
    this.description,
    this.categoryId,
    required this.scheduledAt,
    this.completed = false,
    this.enabled = true,
    this.isDefault = false,
    required this.recurrencia,
  });

  Recordatorio copyWith({
    int? id,
    String? title,
    String? description,
    int? categoryId,
    double? amount,
    DateTime? scheduledAt,
    bool? completed,
    bool? enabled,
    bool? isDefault,
    Recurrencia? recurrencia,
  }) {
    return Recordatorio(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      completed: completed ?? this.completed,
      enabled: enabled ?? this.enabled,
      isDefault: isDefault ?? this.isDefault,
      recurrencia: recurrencia ?? this.recurrencia,
    );
  }

  factory Recordatorio.fromMap(Map<String, dynamic> map) {
    return Recordatorio(
      id: map[RecordatorioTable.id] != null
          ? map[RecordatorioTable.id] as int
          : null,
      title: map[RecordatorioTable.title],
      description: map[RecordatorioTable.description],
      categoryId: map[RecordatorioTable.categoryId],
      scheduledAt: DateTime.parse(map[RecordatorioTable.scheduledAt]),
      completed: map[RecordatorioTable.completed] == 1,
      enabled: map[RecordatorioTable.enabled] == 1,
      isDefault: map[RecordatorioTable.isDefault] == 1,
      recurrencia: Recurrencia.values.firstWhere(
        (r) => r.name == map[RecordatorioTable.recurrencia],
        orElse: () => Recurrencia.ninguno,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      RecordatorioTable.id: id,
      RecordatorioTable.title: title,
      RecordatorioTable.description: description ?? '',
      RecordatorioTable.categoryId: categoryId,
      RecordatorioTable.scheduledAt: scheduledAt.toIso8601String(),
      RecordatorioTable.completed: completed ? 1 : 0,
      RecordatorioTable.enabled: enabled ? 1 : 0,
      RecordatorioTable.isDefault: isDefault ? 1 : 0,
      RecordatorioTable.recurrencia: recurrencia.name,
    };
  }
}
