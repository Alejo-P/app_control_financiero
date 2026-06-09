class MovementNotificationConfig {
  static const createMovementKey = 'movimiento_creacion';
  static const editMovementKey = 'movimiento_edicion';
  static const deleteMovementKey = 'movimiento_eliminacion';

  final int? id;
  final String typeKey;
  final bool isEnabled;
  final bool isDefault;
  final DateTime createdAt;

  MovementNotificationConfig({
    this.id,
    required this.typeKey,
    required this.isEnabled,
    this.isDefault = false,
    required this.createdAt,
  });

  MovementNotificationConfig copyWith({
    int? id,
    String? typeKey,
    bool? isEnabled,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return MovementNotificationConfig(
      id: id ?? this.id,
      typeKey: typeKey ?? this.typeKey,
      isEnabled: isEnabled ?? this.isEnabled,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory MovementNotificationConfig.fromMap(Map<String, dynamic> map) {
    return MovementNotificationConfig(
      id: map['id'],
      typeKey: map['type_key'] as String,
      isEnabled: map['is_enabled'] == 1,
      isDefault: map['is_default'] == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type_key': typeKey,
      'is_enabled': isEnabled ? 1 : 0,
      'is_default': isDefault ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
