class BudgetNotificationEvent {
  final int? id;
  final int categoryId;
  final int year;
  final int month;
  final double threshold;
  final DateTime createdAt;

  BudgetNotificationEvent({
    this.id,
    required this.categoryId,
    required this.year,
    required this.month,
    required this.threshold,
    required this.createdAt,
  });

  BudgetNotificationEvent copyWith({
    int? id,
    int? categoryId,
    int? year,
    int? month,
    double? threshold,
    DateTime? createdAt,
  }) {
    return BudgetNotificationEvent(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      year: year ?? this.year,
      month: month ?? this.month,
      threshold: threshold ?? this.threshold,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory BudgetNotificationEvent.fromMap(Map<String, dynamic> map) {
    return BudgetNotificationEvent(
      id: map['id'],
      categoryId: map['category_id'],
      year: map['year'],
      month: map['month'],
      threshold: map['threshold'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'year': year,
      'month': month,
      'threshold': threshold,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
