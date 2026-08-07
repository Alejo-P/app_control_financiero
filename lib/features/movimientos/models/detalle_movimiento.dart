import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/utils/icon_mapper.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Modelo que representa el detalle de un movimiento financiero.
class DetalleMovimiento extends Equatable {
  final int? id;
  final String title;
  final double amount;
  final TipoMovimiento movementType;
  final DateTime date;
  final String? categoryName;
  final IconData categoryIcon;
  final Color? categoryColor;
  final int? categoryId;
  final TimeOfDay? time;
  final String note;

  const DetalleMovimiento({
    this.id = 0,
    required this.title,
    required this.amount,
    required this.movementType,
    required this.date,
    required this.categoryIcon,
    required this.categoryColor,
    this.categoryName,
    this.categoryId,
    this.time,
    this.note = '',
  });

  DetalleMovimiento copyWith({
    int? id,
    String? title,
    double? amount,
    TipoMovimiento? movementType,
    DateTime? date,
    String? categoryName,
    IconData? categoryIcon,
    Color? categoryColor,
    int? categoryId,
    TimeOfDay? time,
    String? note,
  }) {
    return DetalleMovimiento(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      movementType: movementType ?? this.movementType,
      date: date ?? this.date,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
      categoryId: categoryId ?? this.categoryId,
      time: time ?? this.time,
      note: note ?? this.note,
    );
  }

  // Factory constructor para crear un DetalleMovimiento desde un mapa (por ejemplo, desde una base de datos)
  factory DetalleMovimiento.fromMap(Map<String, dynamic> map) {
    return DetalleMovimiento(
      id: map['id'] != null ? map['id'] as int : null,
      title: map['title'],
      amount: map['amount'],
      movementType: map['movement_type'] == 'ingreso'
          ? TipoMovimiento.ingreso
          : TipoMovimiento.gasto,
      date: DateTime.parse(map['date']),
      note: map['note'] ?? '',
      categoryIcon: map['category_icon'] != null
          ? IconMapper.fromName(map['category_icon'])
          : Icons.category,
      categoryColor: map['category_color'] != null
          ? Color(map['category_color'])
          : null,
      categoryName: map['category_name'] != null
          ? map['category_name'] as String
          : null,
      time: map['time'] != null
          ? TimeOfDay(
              hour: int.parse(map['time'].split(':')[0]),
              minute: int.parse(map['time'].split(':')[1]),
            )
          : null,
      categoryId: map['category_id'] != null
          ? map['category_id'] as int?
          : null,
    );
  }

  // Método para convertir un DetalleMovimiento a un mapa (por ejemplo, para guardar en una base de datos)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': title,
      'monto': amount,
      'tipoMovimiento': movementType == TipoMovimiento.ingreso
          ? 'ingreso'
          : 'gasto',
      'fecha': date.toIso8601String(),
      'nota': note,
      'categoriaIcono': IconMapper.toName(categoryIcon),
      'categoriaColor': categoryColor?.value,
      'categoria': categoryName,
      'time': time != null ? '${time!.hour}:${time!.minute}' : null,
      'categoriaId': categoryId,
    };
  }

  @override
  String toString() {
    return 'DetalleMovimiento(id: $id, title: $title, amount: $amount, movementType: $movementType, date: $date, categoryName: $categoryName, categoryIcon: $categoryIcon, categoryColor: $categoryColor, categoryId: $categoryId, time: $time, note: $note)';
  }

  @override
  List<Object?> get props {
    return [
      id,
      title,
      amount,
      movementType,
      date,
      categoryName,
      categoryIcon,
      categoryColor,
      categoryId,
      time,
      note,
    ];
  }
}
