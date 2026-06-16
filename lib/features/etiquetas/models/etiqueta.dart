import 'package:control_financiero/core/database/db_tables.dart';
import 'package:flutter/material.dart';

class Etiqueta {
  final int id;
  final String name;
  final int colorValue;

  Etiqueta({
    required this.id,
    required this.name,
    required this.colorValue,
  });

  Etiqueta copyWith({
    int? id,
    String? name,
    int? colorValue,
  }) {
    return Etiqueta(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  factory Etiqueta.fromMap(Map<String, dynamic> map) {
    return Etiqueta(
      id: map[EtiquetasTable.id],
      name: map[EtiquetasTable.name],
      colorValue: map[EtiquetasTable.colorValue],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      EtiquetasTable.id: id,
      EtiquetasTable.name: name,
      EtiquetasTable.colorValue: colorValue,
    };
  }

  Color get color => Color(colorValue);
}