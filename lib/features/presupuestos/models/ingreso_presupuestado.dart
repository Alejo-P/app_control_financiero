import 'package:control_financiero/core/database/db_tables.dart';

class IngresoPresupuestado {
  final int? id;
  final double monto;
  final DateTime fecha;

  IngresoPresupuestado({this.id, required this.monto, required this.fecha});

  IngresoPresupuestado copyWith({int? id, double? monto, DateTime? fecha}) {
    return IngresoPresupuestado(
      id: id ?? this.id,
      monto: monto ?? this.monto,
      fecha: fecha ?? this.fecha,
    );
  }

  factory IngresoPresupuestado.fromMap(Map<String, dynamic> map) {
    return IngresoPresupuestado(
      id: map[IngresoPresupuestadoTable.id] != null
          ? map[IngresoPresupuestadoTable.id] as int
          : null,
      monto: (map[IngresoPresupuestadoTable.amount] as num).toDouble(),
      fecha: DateTime.parse(map[IngresoPresupuestadoTable.date] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      IngresoPresupuestadoTable.amount: monto,
      IngresoPresupuestadoTable.date: fecha.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'IngresoPresupuestado(id: $id, monto: $monto, fecha: $fecha)';
  }
}
