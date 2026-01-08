class TotalesMensuales {
  final double ingresos;
  final double gastos;

  const TotalesMensuales({
    required this.ingresos,
    required this.gastos,
  });

  double get ahorro => ingresos - gastos;
}
