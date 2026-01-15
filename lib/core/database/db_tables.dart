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
  static const movementType = 'movement_type';
  static const categoryTypeId = 'category_type_id';
  static const iconName = 'icon_name';
  static const iconColorValue = 'icon_color_value';
  static const isDefault = 'is_default';
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

class MetaTable {
  static const table = 'meta';

  static const key = 'key';
  static const value = 'value';
}