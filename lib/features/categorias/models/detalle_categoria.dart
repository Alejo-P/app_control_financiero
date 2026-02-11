import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class DetalleCategoria extends Equatable {
  final int id;
  final String name;
  final String description;
  final IconData? icon;
  final Color? color;
  final TipoMovimiento movementType;
  final String categoryTypeName;
  final int categoryTypeID;
  final bool enabledRepeatMovement;
  final int? totalMovements;
  final bool isDefault;

  const DetalleCategoria({
    required this.id,
    required this.name,
    this.icon,
    this.color,
    required this.movementType,
    required this.categoryTypeName,
    required this.categoryTypeID,
    this.description = '',
    this.totalMovements,
    this.enabledRepeatMovement = false,
    this.isDefault = false,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    icon,
    color,
    movementType,
    categoryTypeName,
    categoryTypeID,
    description,
    totalMovements,
    enabledRepeatMovement,
    isDefault
  ];

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
      categoryTypeID: map['categoryTypeID'],
      totalMovements: map['totalMovements'],
      enabledRepeatMovement: map['enabledRepeatMovement'] == 1,
      isDefault: map['isDefault'] ?? false,
    );
  }
}
