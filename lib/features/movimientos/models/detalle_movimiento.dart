import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/utils/icon_mapper.dart';
import 'package:control_financiero/features/etiquetas/models/etiqueta.dart';
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
  final bool isEnabledRepeatMovement;
  final bool repeatMovement;
  final int? categoryId;
  final TimeOfDay? time;
  final String note;
  final List<Etiqueta> tags;

  const DetalleMovimiento({
    this.id = 0,
    required this.title,
    required this.amount,
    required this.movementType,
    required this.date,
    required this.categoryIcon,
    required this.categoryColor,
    this.categoryName,
    this.tags = const [],
    this.isEnabledRepeatMovement = false,
    this.repeatMovement = false,
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
    bool? isEnabledRepeatMovement,
    bool? repeatMovement,
    int? categoryId,
    TimeOfDay? time,
    String? note,
    List<Etiqueta>? tags,
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
      isEnabledRepeatMovement:
          isEnabledRepeatMovement ?? this.isEnabledRepeatMovement,
      repeatMovement: repeatMovement ?? this.repeatMovement,
      categoryId: categoryId ?? this.categoryId,
      time: time ?? this.time,
      note: note ?? this.note,
      tags: tags ?? this.tags,
    );
  }

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
      categoryIcon: map['categoriaIcono'] != null
          ? IconMapper.fromName(map['categoriaIcono'])
          : Icons.category,
      categoryColor: map['categoriaColor'] != null
          ? Color(map['categoriaColor'])
          : null,
      categoryName: map['categoria'] != null
          ? map['categoria'] as String
          : null,
      isEnabledRepeatMovement: map['enabledRepeatMovement'] == 1,
      repeatMovement: map['repeatMovement'] == 1,
      time: map['hora'] != null
          ? TimeOfDay(
              hour: int.parse(map['hora'].split(':')[0]),
              minute: int.parse(map['hora'].split(':')[1]),
            )
          : null,
      categoryId: map['categoriaId'] != null ? map['categoriaId'] as int : null,
      tags: map['etiquetas'] != null ? map['tags'] : [],
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
      'enabledRepeatMovement': isEnabledRepeatMovement ? 1 : 0,
      'repeatMovement': repeatMovement ? 1 : 0,
      'time': time != null ? '${time!.hour}:${time!.minute}' : null,
      'categoriaId': categoryId,
      'tags': tags
    };
  }

  @override
  String toString() {
    return 'DetalleMovimiento(id: $id, title: $title, amount: $amount, movementType: $movementType, date: $date, categoryName: $categoryName, categoryIcon: $categoryIcon, categoryColor: $categoryColor, isEnabledRepeatMovement: $isEnabledRepeatMovement, repeatMovement: $repeatMovement, categoryId: $categoryId, time: $time, note: $note, tags: $tags)';
  }

  // Getter para comparar 2 objetos DetalleMovimiento por su contenido, no por su referencia
  @override
  List<Object?> get props => [
    id,
    title,
    amount,
    movementType,
    date,
    categoryName,
    categoryIcon,
    categoryColor,
    isEnabledRepeatMovement,
    repeatMovement,
    categoryId,
    time,
    note,
    tags,
  ];
}
