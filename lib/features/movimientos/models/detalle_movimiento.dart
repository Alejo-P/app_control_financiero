import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/utils/icon_mapper.dart';
import 'package:flutter/material.dart';

/// Modelo que representa el detalle de un movimiento financiero.
class DetalleMovimiento {
  final int? id;
  final String title;
  final double amount;
  final TipoMovimiento movementType;
  final DateTime date;
  final String? categoryName;
  final IconData categoryIcon;
  final Color? categoryColor;
  final bool isEnabledRepeatMovement;
  final bool repeatMovement;
  final int? categoryId;
  final TimeOfDay? time;
  final String note;

  DetalleMovimiento({
    this.id,
    required this.title,
    required this.amount,
    required this.movementType,
    required this.date,
    required this.categoryIcon,
    required this.categoryColor,
    this.categoryName,
    this.isEnabledRepeatMovement = false,
    this.repeatMovement = false,
    this.categoryId,
    this.time,
    this.note = '',
  });

  // Factory constructor para crear un DetalleMovimiento desde un mapa (por ejemplo, desde una base de datos)
  factory DetalleMovimiento.fromMap(Map<String, dynamic> map) {
    return DetalleMovimiento(
      id: map['id'] != null ? map['id'] as int : null,
      title: map['titulo'],
      amount: map['monto'],
      movementType: map['tipoMovimiento'] == 'ingreso'
          ? TipoMovimiento.ingreso
          : TipoMovimiento.gasto,
      date: DateTime.parse(map['fecha']),
      note: map['nota'],
      categoryIcon: map['categoriaIcono'] != null ? IconMapper.fromName(map['categoriaIcono']) : Icons.category,
      categoryColor: map['categoriaColor'] != null ? Color(map['categoriaColor']) : null,
      categoryName: map['categoria'] != null ? map['categoria'] as String : null,
      isEnabledRepeatMovement: map['enabledRepeatMovement'] == 1,
      repeatMovement: map['repeatMovement'] == 1,
      time: map['hora'] != null ? TimeOfDay(
        hour: int.parse(map['time'].split(':')[0]),
        minute: int.parse(map['time'].split(':')[1]),
      ) : null,
      categoryId: map['categoriaId'] != null ? map['categoriaId'] as int : null,
    );
  }
}