class TipoCategoria {
  final String id;
  final String name;
  final String description;

  TipoCategoria({
    required this.id,
    required this.name,
    required this.description,
  });

  factory TipoCategoria.fromMap(Map<String, dynamic> map) {
    return TipoCategoria(
      id: map['id'],
      name: map['name'],
      description: map['description']
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description
  };
}
