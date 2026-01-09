class TipoCategoriasTable {
  static const table = 'tipo_categorias';

  static const id = 'id';
  static const name = 'name';
  static const description = 'description';
}

class CategoriasTable {
  static const table = 'categorias';

  static const id = 'id';
  static const name = 'name';
  static const description = 'description';
  static const categoryTypeId = 'category_type_id';
  static const iconName = 'icon_name';
  static const iconColorValue = 'icon_color_value';
}

class MovimientosTable {
  static const table = 'movimientos';

  static const id = 'id';
  static const title = 'title';
  static const categoryId = 'category_id';
  static const type = 'type';
  static const ammount = 'ammount';
  static const date = 'date';
  static const time = 'time';
  static const note = 'note';
}