import 'package:control_financiero/core/database/db_tables.dart';

class TipoCategoria {
  final int? id;
  final String name;
  final String description;

  TipoCategoria({this.id, required this.name, required this.description});

  factory TipoCategoria.fromMap(Map<String, dynamic> map) {
    return TipoCategoria(
      id: map[TipoCategoriasTable.id] != null
          ? map[TipoCategoriasTable.id] as int
          : null,
      name: map[TipoCategoriasTable.name] as String,
      description: map[TipoCategoriasTable.description] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    TipoCategoriasTable.name: name,
    TipoCategoriasTable.description: description,
  };
}
