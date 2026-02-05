import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/utils/icon_mapper.dart';
import 'package:flutter/material.dart';

class Categoria {
  final int? id;
  final String name;
  final String description;
  final TipoMovimiento movementType;
  final int categoryTypeID;
  final String iconName;
  final int iconColorValue;
  final int? movementsCount;
  final bool isDefault;

  Categoria({
    this.id,
    required this.name,
    required this.description,
    required this.movementType,
    required this.categoryTypeID,
    required this.iconName,
    required this.iconColorValue,
    this.movementsCount = 0,
    this.isDefault = false,
  });

  Categoria copyWith({
    int? id,
    String? name,
    String? description,
    TipoMovimiento? movementType,
    int? categoryTypeID,
    String? iconName,
    int? iconColorValue,
    int? movementsCount,
    bool? isDefault,
  }) {
    return Categoria(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      movementType: movementType ?? this.movementType,
      categoryTypeID: categoryTypeID ?? this.categoryTypeID,
      iconName: iconName ?? this.iconName,
      iconColorValue: iconColorValue ?? this.iconColorValue,
      movementsCount: movementsCount ?? this.movementsCount,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  String toString() {
    return 'Categoria{id: $id, name: $name, description: $description, movementType: $movementType, categoryTypeID: $categoryTypeID, iconName: $iconName, iconColorValue: $iconColorValue, movementsCount: $movementsCount, isDefault: $isDefault}';
  }

  // Factory constructor to create a Categoria from JSON
  factory Categoria.fromMap(Map<String, dynamic> map) {
    return Categoria(
      id: map['id'] != null ? map['id'] as int : null,
      name: map['name'],
      description: map['description'],
      movementType: map['movement_type'] == 'ingreso'
          ? TipoMovimiento.ingreso
          : TipoMovimiento.gasto,
      categoryTypeID: map['category_type_id'],
      iconName: map['icon_name'],
      iconColorValue: map['icon_color_value'],
      movementsCount: map['movements_count'] ?? 0,
      isDefault: map['is_default'] == 1,
    );
  }

  // Method to convert a Categoria to JSON
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'movement_type': movementType.name,
      'category_type_id': categoryTypeID,
      'icon_name': iconName,
      'icon_color_value': iconColorValue,
      'is_default': isDefault ? 1 : 0,
    };
  }

  // Method to get IconData from iconName
  IconData get iconData => IconMapper.fromName(iconName);

  // Method to get Color from iconColorValue
  Color get iconColor => Color(iconColorValue);
}
