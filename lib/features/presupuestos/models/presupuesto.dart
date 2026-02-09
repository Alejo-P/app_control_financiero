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
      id: map['id'] != null ? map['id'] as int : null,
      categoryId: map['category_id'],
      date: DateTime.parse(map['date']),
      amount: map['amount'],
      repeatBudget: map['repeat_budget'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category_id': categoryId,
      'date': date.toIso8601String(),
      'amount': amount,
      'repeat_budget': repeatBudget ? 1 : 0,
    };
  }

  @override
  String toString() {
    return 'Presupuesto{id: $id, categoryId: $categoryId, date: $date, amount: $amount, repeatBudget: $repeatBudget}';
  }
}