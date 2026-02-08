import 'package:flutter/material.dart';

class DetallePresupuesto {
  final String categoria;
  final int categoriaId;
  final IconData icon;
  final Color iconColor;
  final DateTime fechaPresupuesto;
  final double montoPresupuestado;

  DetallePresupuesto({
    required this.categoria,
    required this.categoriaId,
    required this.icon,
    required this.iconColor,
    required this.fechaPresupuesto,
    required this.montoPresupuestado,
  });

  factory DetallePresupuesto.fromMap(Map<String, dynamic> map) {
    return DetallePresupuesto(
      categoria: map['categoria'],
      categoriaId: map['categoriaId'],
      icon: IconData(map['iconCodePoint'], fontFamily: 'MaterialIcons'),
      iconColor: Color(map['iconColorValue']),
      fechaPresupuesto: DateTime.parse(map['fechaPresupuesto']),
      montoPresupuestado: map['montoPresupuestado'],
    );
  }
}