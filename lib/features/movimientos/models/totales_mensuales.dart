class TotalesMensuales {
  final double ingresos;
  final double gastos;

  const TotalesMensuales({
    required this.ingresos,
    required this.gastos,
  });

  @override
  String toString() {
    return 'TotalesMensuales(ingresos: $ingresos, gastos: $gastos)';
  }

  double get ahorro => ingresos - gastos;
}
