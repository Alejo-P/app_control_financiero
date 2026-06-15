import 'package:control_financiero/core/database/db_tables.dart';

class MovimientoEtiqueta {
  final int? id;
  final int movimientoId;
  final int etiquetaId;

  MovimientoEtiqueta({
    this.id,
    required this.movimientoId,
    required this.etiquetaId,
  });

  MovimientoEtiqueta copyWith({
    int? id,
    int? movimientoId,
    int? etiquetaId,
  }) {
    return MovimientoEtiqueta(
      id: id ?? this.id,
      movimientoId: movimientoId ?? this.movimientoId,
      etiquetaId: etiquetaId ?? this.etiquetaId,
    );
  }

  factory MovimientoEtiqueta.fromMap(Map<String, dynamic> map) {
    return MovimientoEtiqueta(
      id: map[MovimientoEtiquetaTable.id] != null ? map[MovimientoEtiquetaTable.id] as int : null,
      movimientoId: map[MovimientoEtiquetaTable.movimientoId],
      etiquetaId: map[MovimientoEtiquetaTable.etiquetaId],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      MovimientoEtiquetaTable.id: id,
      MovimientoEtiquetaTable.movimientoId: movimientoId,
      MovimientoEtiquetaTable.etiquetaId: etiquetaId,
    };
  }
}