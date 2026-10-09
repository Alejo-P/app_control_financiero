import 'package:control_financiero/core/utils/icon_mapper.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class DetallePresupuesto extends Equatable {
  final int? id;
  final String categoria;
  final int categoriaId;
  final IconData icon;
  final Color iconColor;
  final DateTime fechaPresupuesto;
  final double montoPresupuestado;

  const DetallePresupuesto({
    this.id,
    required this.categoria,
    required this.categoriaId,
    required this.icon,
    required this.iconColor,
    required this.fechaPresupuesto,
    required this.montoPresupuestado,
  });

  DetallePresupuesto copyWith({
    int? id,
    String? categoria,
    int? categoriaId,
    int? idPresupuesto,
    IconData? icon,
    Color? iconColor,
    DateTime? fechaPresupuesto,
    double? montoPresupuestado,
    double? totalPresupuestado,
  }) {
    return DetallePresupuesto(
      id: id ?? this.id,
      categoria: categoria ?? this.categoria,
      categoriaId: categoriaId ?? this.categoriaId,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      fechaPresupuesto: fechaPresupuesto ?? this.fechaPresupuesto,
      montoPresupuestado: montoPresupuestado ?? this.montoPresupuestado,
    );
  }

  @override
  List<Object?> get props => [
    id,
    categoria,
    categoriaId,
    icon,
    iconColor,
    fechaPresupuesto,
    montoPresupuestado,
  ];

  factory DetallePresupuesto.fromMap(Map<String, dynamic> map) {
    return DetallePresupuesto(
      id: map['id'],
      categoria: map['categoria'],
      categoriaId: map['categoriaId'],
      icon: map['categoriaIcono'] != null
          ? IconMapper.fromName(map['categoriaIcono'])
          : Icons.category,
      iconColor: Color(map['categoriaColor'] ?? 0xFF000000),
      fechaPresupuesto: DateTime.parse(map['fechaPresupuesto']),
      montoPresupuestado: map['montoPresupuestado'],
    );
  }

  @override
  String toString() {
    return 'DetallePresupuesto{id: $id, categoria: $categoria, categoriaId: $categoriaId, icon: $icon, iconColor: $iconColor, fechaPresupuesto: $fechaPresupuesto, montoPresupuestado: $montoPresupuestado}';
  }
}
