import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/database/db_tables.dart';
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

  factory Categoria.fromMap(Map<String, dynamic> map) {
    return Categoria(
      id: map[CategoriasTable.id] != null
          ? map[CategoriasTable.id] as int
          : null,
      name: map[CategoriasTable.name] as String,
      description: map[CategoriasTable.description] as String? ?? '',
      movementType: map[CategoriasTable.movementType] == 'ingreso'
          ? TipoMovimiento.ingreso
          : TipoMovimiento.gasto,
      categoryTypeID: map[CategoriasTable.categoryTypeId] as int,
      iconName: map[CategoriasTable.iconName] as String,
      iconColorValue: map[CategoriasTable.iconColorValue] as int,
      movementsCount: map['movements_count'] ?? 0,
      isDefault: map[CategoriasTable.isDefault] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      CategoriasTable.id: id,
      CategoriasTable.name: name,
      CategoriasTable.description: description,
      CategoriasTable.movementType: movementType.name,
      CategoriasTable.categoryTypeId: categoryTypeID,
      CategoriasTable.iconName: iconName,
      CategoriasTable.iconColorValue: iconColorValue,
      CategoriasTable.isDefault: isDefault ? 1 : 0,
    };
  }

  IconData get iconData => IconMapper.fromName(iconName);

  Color get iconColor => Color(iconColorValue);
}
