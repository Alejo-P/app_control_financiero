import 'package:control_financiero/core/constants/movimiento_constants.dart';

/// Modelo que representa el detalle de un movimiento financiero.
class DetalleMovimiento {
  final int? id;
  final String titulo;
  final double monto;
  final TipoMovimiento tipoMovimiento;
  final DateTime fecha;
  final String nota;

  DetalleMovimiento({
    this.id,
    required this.titulo,
    required this.monto,
    required this.tipoMovimiento,
    required this.fecha,
    this.nota = '',
  });

  // Factory constructor para crear un DetalleMovimiento desde un mapa (por ejemplo, desde una base de datos)
  factory DetalleMovimiento.fromMap(Map<String, dynamic> map) {
    return DetalleMovimiento(
      id: map['id'] != null ? map['id'] as int : null,
      titulo: map['titulo'],
      monto: map['monto'],
      tipoMovimiento: map['tipoMovimiento'] == 'ingreso'
          ? TipoMovimiento.ingreso
          : TipoMovimiento.gasto,
      fecha: DateTime.parse(map['fecha']),
      nota: map['nota'],
    );
  }
}