class IngresoPresupuestado {
  final int? id;
  final double monto;
  final DateTime fecha;

  IngresoPresupuestado({
    this.id,
    required this.monto,
    required this.fecha,
  });

  IngresoPresupuestado copyWith({
    int? id,
    double? monto,
    DateTime? fecha,
  }) {
    return IngresoPresupuestado(
      id: id ?? this.id,
      monto: monto ?? this.monto,
      fecha: fecha ?? this.fecha,
    );
  }

  factory IngresoPresupuestado.fromMap(Map<String, dynamic> map) {
    return IngresoPresupuestado(
      id: map['id'] != null ? map['id'] as int : null,
      monto: map['amount'] as double,
      fecha: DateTime.parse(map['date']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': monto,
      'date': fecha.toIso8601String(),
    };
  }
}