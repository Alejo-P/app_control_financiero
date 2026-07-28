import 'package:control_financiero/core/database/db_tables.dart';

class Presupuesto {
  final int? id;
  final int categoryId;
  final DateTime date;
  final double amount;
  final bool repeatBudget;

  Presupuesto({
    this.id,
    required this.categoryId,
    required this.date,
    required this.amount,
    this.repeatBudget = false,
  });

  Presupuesto copyWith({
    int? id,
    int? categoryId,
    DateTime? date,
    double? amount,
    bool? repeatBudget,
  }) {
    return Presupuesto(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      repeatBudget: repeatBudget ?? this.repeatBudget,
    );
  }

  factory Presupuesto.fromMap(Map<String, dynamic> map) {
    return Presupuesto(
      id: map[PresupuestosTable.id] != null
          ? map[PresupuestosTable.id] as int
          : null,
      categoryId: map[PresupuestosTable.categoryId] as int,
      date: DateTime.parse(map[PresupuestosTable.date] as String),
      amount: (map[PresupuestosTable.amount] as num).toDouble(),
      repeatBudget: map[PresupuestosTable.repeatBudget] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      PresupuestosTable.categoryId: categoryId,
      PresupuestosTable.date: date.toIso8601String(),
      PresupuestosTable.amount: amount,
      PresupuestosTable.repeatBudget: repeatBudget ? 1 : 0,
    };
  }

  @override
  String toString() {
    return 'Presupuesto{id: $id, categoryId: $categoryId, date: $date, amount: $amount, repeatBudget: $repeatBudget}';
  }
}
