import 'package:control_financiero/core/database/db_tables.dart';

enum Recurrencia { diario, semanal, mensual, anual, ninguno }

class Recordatorio {
  final int? id;
  final String title;
  final String? description;
  final int? categoryId;
  final double? amount;
  final DateTime scheduledAt;
  final bool completed;
  final bool enabled;
  final Recurrencia recurrencia;

  Recordatorio({
    this.id,
    required this.title,
    this.description,
    this.categoryId,
    this.amount,
    required this.scheduledAt,
    this.completed = false,
    this.enabled = true,
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
    Recurrencia? recurrencia,
  }) {
    return Recordatorio(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      completed: completed ?? this.completed,
      enabled: enabled ?? this.enabled,
      recurrencia: recurrencia ?? this.recurrencia,
    );
  }

  factory Recordatorio.fromMap(Map<String, dynamic> map) {
    return Recordatorio(
      id: map[RecordatorioTable.id] != null ? map[RecordatorioTable.id] as int : null,
      title: map[RecordatorioTable.title],
      description: map[RecordatorioTable.description],
      categoryId: map[RecordatorioTable.categoryId],
      amount: map[RecordatorioTable.amount],
      scheduledAt: DateTime.parse(map[RecordatorioTable.scheduledAt]),
      completed: map[RecordatorioTable.completed] == 1,
      enabled: map[RecordatorioTable.enabled] == 1,
      recurrencia: Recurrencia.values.firstWhere(
        (r) => r.name == map[RecordatorioTable.recurrencia],
        orElse: () => Recurrencia.ninguno,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      RecordatorioTable.title: title,
      RecordatorioTable.description: description,
      RecordatorioTable.categoryId: categoryId,
      RecordatorioTable.amount: amount,
      RecordatorioTable.scheduledAt: scheduledAt.toIso8601String(),
      RecordatorioTable.completed: completed ? 1 : 0,
      RecordatorioTable.enabled: enabled ? 1 : 0,
      RecordatorioTable.recurrencia: recurrencia.name,
    };
  }
}