class MovimientoSearchFilters {
  String? texto;
  int? categoriaId;
  DateTime? fechaInicio;
  DateTime? fechaFin;
  List<String> etiquetas;
  AgrupacionBusqueda agrupacion;

  MovimientoSearchFilters({
    this.texto,
    this.categoriaId,
    this.fechaInicio,
    this.fechaFin,
    this.etiquetas = const [],
    this.agrupacion = AgrupacionBusqueda.ninguna,
  });
}

enum AgrupacionBusqueda { ninguna, concepto, categoria, mes, etiqueta }
