class BudgetNotification {
  final int? id;
  final double threshold;
  final int? categoryId;
  final bool isEnabledNotification;
  final bool isDefault;
  final DateTime createdAt;

  BudgetNotification({
    this.id,
    required this.threshold,
    this.categoryId,
    required this.isEnabledNotification,
    this.isDefault = false,
    required this.createdAt,
  });

  BudgetNotification copyWith({
    int? id,
    double? threshold,
    int? categoryId,
    bool? isEnabledNotification,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return BudgetNotification(
      id: id ?? this.id,
      threshold: threshold ?? this.threshold,
      categoryId: categoryId ?? this.categoryId,
      isEnabledNotification:
          isEnabledNotification ?? this.isEnabledNotification,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory BudgetNotification.fromMap(Map<String, dynamic> map) {
    return BudgetNotification(
      id: map['id'],
      threshold: map['threshold'],
      categoryId: map['category_id'] != null ? map['category_id'] as int : null,
      isEnabledNotification: map['is_enabled'] == 1,
      isDefault: map['is_default'] == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'threshold': threshold,
      'category_id': categoryId,
      'is_enabled': isEnabledNotification ? 1 : 0,
      'is_default': isDefault ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
