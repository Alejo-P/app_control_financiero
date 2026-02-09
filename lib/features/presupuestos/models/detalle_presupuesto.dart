import 'package:control_financiero/features/movimientos/models/movimiento.dart';
import 'package:flutter/material.dart';

class DetallePresupuesto {
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

  DetallePresupuesto({
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
