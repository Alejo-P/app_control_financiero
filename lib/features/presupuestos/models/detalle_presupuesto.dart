import 'package:control_financiero/features/movimientos/models/movimiento.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class DetallePresupuesto extends Equatable {
  final String categoria;
  final int categoriaId;
  final int idPresupuesto;
  final IconData icon;
  final Color iconColor;
  final DateTime fechaPresupuesto;
  final double montoPresupuestado;
  final double totalPresupuestado;
  final bool esRecurrente;
  final List<Movimiento> movimientos;

  const DetallePresupuesto({
    required this.categoria,
    required this.categoriaId,
    required this.idPresupuesto,
    required this.icon,
    required this.iconColor,
    required this.fechaPresupuesto,
    required this.montoPresupuestado,
    required this.totalPresupuestado,
    this.esRecurrente = false,
    this.movimientos = const [],
  });

  DetallePresupuesto copyWith({
    String? categoria,
    int? categoriaId,
    int? idPresupuesto,
    IconData? icon,
    Color? iconColor,
    DateTime? fechaPresupuesto,
    double? montoPresupuestado,
    double? totalPresupuestado,
    bool? esRecurrente,
    List<Movimiento>? movimientos,
  }) {
    return DetallePresupuesto(
      categoria: categoria ?? this.categoria,
      categoriaId: categoriaId ?? this.categoriaId,
      idPresupuesto: idPresupuesto ?? this.idPresupuesto,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      fechaPresupuesto: fechaPresupuesto ?? this.fechaPresupuesto,
      montoPresupuestado: montoPresupuestado ?? this.montoPresupuestado,
      totalPresupuestado: totalPresupuestado ?? this.totalPresupuestado,
      esRecurrente: esRecurrente ?? this.esRecurrente,
      movimientos: movimientos ?? this.movimientos,
    );
  }

  @override
  List<Object?> get props => [
    categoria,
    categoriaId,
    idPresupuesto,
    icon,
    iconColor,
    fechaPresupuesto,
    montoPresupuestado,
    totalPresupuestado,
    esRecurrente,
    movimientos,
  ];

  factory DetallePresupuesto.fromMap(Map<String, dynamic> map) {
    return DetallePresupuesto(
      categoria: map['categoria'],
      categoriaId: map['categoriaId'],
      idPresupuesto: map['idPresupuesto'],
      icon: IconData(map['iconCodePoint'], fontFamily: 'MaterialIcons'),
      iconColor: Color(map['iconColorValue']),
      fechaPresupuesto: DateTime.parse(map['fechaPresupuesto']),
      montoPresupuestado: map['montoPresupuestado'],
      totalPresupuestado: map['totalPresupuestado'],
      esRecurrente: map['esRecurrente'] ?? false,
      movimientos: (map['movimientos'] as List<dynamic>)
          .map((mov) => Movimiento.fromMap(mov))
          .toList(),
    );
  }
}
