class MovimientoSearchFilters {
  String? texto;
  int? categoriaId;
  DateTime? fechaInicio;
  DateTime? fechaFin;
  AgrupacionBusqueda agrupacion;

  MovimientoSearchFilters({
    this.texto,
    this.categoriaId,
    this.fechaInicio,
    this.fechaFin,
    this.agrupacion = AgrupacionBusqueda.ninguna,
  });
}

enum AgrupacionBusqueda { ninguna, concepto, categoria, mes }
