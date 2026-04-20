class MovimientoFormArgs {
  final int id;
  final DateTime? fechaInicial;
  final bool viewOnly;

  MovimientoFormArgs({
    required this.id,
    this.fechaInicial,
    this.viewOnly = false,
  });
}