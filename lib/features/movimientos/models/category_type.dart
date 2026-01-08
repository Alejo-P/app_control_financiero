class CategoryType {
  final String id;
  final String name;
  final String description;

  CategoryType({
    required this.id,
    required this.name,
    required this.description,
  });

  factory CategoryType.fromJson(Map<String, dynamic> json) {
    return CategoryType(
      id: json['id'],
      name: json['name'],
      description: json['description']
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description
  };
}
