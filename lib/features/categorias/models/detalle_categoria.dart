import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:flutter/material.dart';

class DetalleCategoria {
  final int id;
  final String name;
  final String description;
  final IconData? icon;
  final Color? color;
  final TipoMovimiento movementType;
  final String categoryTypeName;
  final int? totalMovements;
  final bool isDefault;

  DetalleCategoria({
    required this.id,
    required this.name,
    this.icon,
    this.color,
    required this.movementType,
    required this.categoryTypeName,
    this.description = '',
    this.totalMovements,
    this.isDefault = false,
  });

  factory DetalleCategoria.fromMap(Map<String, dynamic> map) {
    return DetalleCategoria(
      id: map['id'],
      name: map['name'],
      description: map['description'] ?? '',
      icon: map['icon'] != null ? IconData(map['icon'], fontFamily: 'MaterialIcons') : null,
      color: map['color'] != null ? Color(map['color']) : null,
      movementType: map['movementType'] == 'ingreso'
          ? TipoMovimiento.ingreso
          : TipoMovimiento.gasto,
      categoryTypeName: map['categoryTypeName'],
      totalMovements: map['totalMovements'],
      isDefault: map['isDefault'] ?? false,
    );
  }
}
