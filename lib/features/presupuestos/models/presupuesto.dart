import 'package:control_financiero/core/database/db_tables.dart';

class Presupuesto {
  final int? id;
  final int categoryId;
  final DateTime date;
  final double amount;

  Presupuesto({
    this.id,
    required this.categoryId,
    required this.date,
    required this.amount,
  });

  Presupuesto copyWith({
    int? id,
    int? categoryId,
    DateTime? date,
    double? amount,
  }) {
    return Presupuesto(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      PresupuestosTable.categoryId: categoryId,
      PresupuestosTable.date: date.toIso8601String(),
      PresupuestosTable.amount: amount,
    };
  }

  @override
  String toString() {
    return 'Presupuesto{id: $id, categoryId: $categoryId, date: $date, amount: $amount}';
  }
}
