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
      id: map['id'] != null ? map['id'] as int : null,
      categoryId: map['category_id'],
      date: DateTime.parse(map['date']),
      amount: map['amount'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category_id': categoryId,
      'date': date.toIso8601String(),
      'amount': amount,
    };
  }
}