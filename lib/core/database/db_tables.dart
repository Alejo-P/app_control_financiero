import 'package:sqflite/sqflite.dart';

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
  static const enabledRepeatMovement = 'enabled_repeat_movement';
  static const isDefault = 'is_default';
}

class PresupuestosTable {
  static const table = 'presupuestos';

  static const id = 'id';
  static const categoryId = 'category_id';
  static const date = 'date';
  static const amount = 'amount';
}

class MovimientosTable {
  static const table = 'movimientos';

  static const id = 'id';
  static const title = 'title';
  static const categoryId = 'category_id';
  static const amount = 'amount';
  static const date = 'date';
  static const time = 'time';
  static const note = 'note';
  static const repeatMovement = 'repeat_movement';
}

class IngresoPresupuestadoTable {
  static const table = 'ingreso_presupuestado';

  static const id = 'id';
  static const amount = 'amount';
  static const date = 'date';
}

class MetaTable {
  static const table = 'meta';

  static const key = 'key';
  static const value = 'value';
}

Future<void> createTables(Database db) async {
  // Obtener lista de tablas existentes
  final existingTables = await db.rawQuery(
    "SELECT name FROM sqlite_master WHERE type='table';",
  );

  final existingTableNames = existingTables
      .map((table) => table['name'] as String)
      .toSet();

  // Crear tablas si no existen
  if (!existingTableNames.contains(MetaTable.table)) {
    await db.execute('''
      CREATE TABLE ${MetaTable.table} (
        ${MetaTable.key} TEXT PRIMARY KEY,
        ${MetaTable.value} TEXT NOT NULL
      );
    ''');
  }

  if (!existingTableNames.contains(TipoCategoriasTable.table)) {
    await db.execute('''
      CREATE TABLE ${TipoCategoriasTable.table} (
        ${TipoCategoriasTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${TipoCategoriasTable.name} TEXT NOT NULL,
        ${TipoCategoriasTable.description} TEXT
      );
    ''');
  }

  if (!existingTableNames.contains(IngresoPresupuestadoTable.table)) {
    await db.execute('''
      CREATE TABLE ${IngresoPresupuestadoTable.table} (
        ${IngresoPresupuestadoTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${IngresoPresupuestadoTable.amount} REAL NOT NULL,
        ${IngresoPresupuestadoTable.date} TEXT NOT NULL
      );
    ''');
  }

  if (!existingTableNames.contains(CategoriasTable.table)) {
    await db.execute('''
      CREATE TABLE ${CategoriasTable.table} (
        ${CategoriasTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${CategoriasTable.name} TEXT NOT NULL,
        ${CategoriasTable.description} TEXT,
        ${CategoriasTable.movementType} TEXT NOT NULL,
        ${CategoriasTable.categoryTypeId} INTEGER NOT NULL,
        ${CategoriasTable.iconName} TEXT NOT NULL,
        ${CategoriasTable.iconColorValue} INTEGER NOT NULL,
        ${CategoriasTable.enabledRepeatMovement} INTEGER DEFAULT 0,
        ${CategoriasTable.isDefault} INTEGER DEFAULT 0,
        FOREIGN KEY(${CategoriasTable.categoryTypeId}) REFERENCES ${TipoCategoriasTable.table}(${TipoCategoriasTable.id})
      );
    ''');
  }

  if (!existingTableNames.contains(MovimientosTable.table)) {
    await db.execute('''
      CREATE TABLE ${MovimientosTable.table} (
        ${MovimientosTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${MovimientosTable.title} TEXT NOT NULL,
        ${MovimientosTable.categoryId} INTEGER NOT NULL,
        ${MovimientosTable.amount} REAL NOT NULL,
        ${MovimientosTable.date} TEXT NOT NULL,
        ${MovimientosTable.time} TEXT NOT NULL,
        ${MovimientosTable.note} TEXT DEFAULT '',
        ${MovimientosTable.repeatMovement} INTEGER DEFAULT 0,
        FOREIGN KEY(${MovimientosTable.categoryId}) REFERENCES ${CategoriasTable.table}(${CategoriasTable.id})
      );
    ''');
  }

  if (!existingTableNames.contains(PresupuestosTable.table)) {
    await db.execute('''
      CREATE TABLE ${PresupuestosTable.table} (
        ${PresupuestosTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${PresupuestosTable.categoryId} INTEGER NOT NULL,
        ${PresupuestosTable.date} TEXT NOT NULL,
        ${PresupuestosTable.amount} REAL NOT NULL,
        FOREIGN KEY(${PresupuestosTable.categoryId}) REFERENCES ${CategoriasTable.table}(${CategoriasTable.id})
      );
    ''');
  }
}
