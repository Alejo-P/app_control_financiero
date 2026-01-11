class TipoCategoria {
  final int? id;
  final String name;
  final String description;

  TipoCategoria({
    this.id,
    required this.name,
    required this.description,
  });

  factory TipoCategoria.fromMap(Map<String, dynamic> map) {
    return TipoCategoria(
      id: map['id'] != null ? map['id'] as int : null,
      name: map['name'],
      description: map['description']
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'description': description
  };
}
