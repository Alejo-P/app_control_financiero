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
  static const repeatBudget = 'repeat_budget';
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

class NotificacionTable {
  static const table = 'notificaciones';

  static const id = 'id';
  static const title = 'title';
  static const description = 'description';
  static const type = 'type';
  static const isRead = 'is_read';
  static const icon = 'icon';
  static const iconColor = 'icon_color';
  static const extraData = 'extra_data';
  static const objectId = 'object_id';
  static const createdAt = 'created_at';
}

class BudgetNotificationConfigTable {
  static const table = 'budget_notification_config';

  static const id = 'id';
  static const categoryId = 'category_id';
  static const threshold = 'threshold'; // 0.5, 0.85, 1.0
  static const isEnabled = 'is_enabled';
  static const isDefault = 'is_default';
  static const createdAt = 'created_at';
}

class MovementNotificationConfigTable {
  static const table = 'movement_notification_config';

  static const id = 'id';
  static const typeKey = 'type_key';
  static const isEnabled = 'is_enabled';
  static const isDefault = 'is_default';
  static const createdAt = 'created_at';
}

class BudgetNotificationEventsTable {
  static const table = 'budget_notification_events';

  static const id = 'id';
  static const categoryId = 'category_id';
  static const year = 'year';
  static const month = 'month';
  static const threshold = 'threshold';
  static const createdAt = 'created_at';
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

  if (!existingTableNames.contains(NotificacionTable.table)) {
    await db.execute('''
      CREATE TABLE ${NotificacionTable.table} (
        ${NotificacionTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${NotificacionTable.title} TEXT NOT NULL,
        ${NotificacionTable.description} TEXT,
        ${NotificacionTable.type} TEXT NOT NULL,
        ${NotificacionTable.icon} TEXT NOT NULL,
        ${NotificacionTable.iconColor} INTEGER NOT NULL,
        ${NotificacionTable.isRead} INTEGER NOT NULL DEFAULT 0,
        ${NotificacionTable.extraData} TEXT,
        ${NotificacionTable.objectId} INTEGER,
        ${NotificacionTable.createdAt} TEXT NOT NULL
      );
    ''');
  }

  if (!existingTableNames.contains(BudgetNotificationConfigTable.table)) {
    await db.execute('''
      CREATE TABLE ${BudgetNotificationConfigTable.table} (
        ${BudgetNotificationConfigTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${BudgetNotificationConfigTable.categoryId} INTEGER DEFAULT NULL,
        ${BudgetNotificationConfigTable.threshold} REAL UNIQUE NOT NULL,
        ${BudgetNotificationConfigTable.isEnabled} INTEGER NOT NULL DEFAULT 0,
        ${BudgetNotificationConfigTable.isDefault} INTEGER NOT NULL DEFAULT 0,
        ${BudgetNotificationConfigTable.createdAt} TEXT NOT NULL
      );
    ''');
  }

  if (!existingTableNames.contains(MovementNotificationConfigTable.table)) {
    await db.execute('''
      CREATE TABLE ${MovementNotificationConfigTable.table} (
        ${MovementNotificationConfigTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${MovementNotificationConfigTable.typeKey} TEXT NOT NULL UNIQUE,
        ${MovementNotificationConfigTable.isEnabled} INTEGER NOT NULL DEFAULT 0,
        ${MovementNotificationConfigTable.isDefault} INTEGER NOT NULL DEFAULT 0,
        ${MovementNotificationConfigTable.createdAt} TEXT NOT NULL
      );
    ''');
  }

  if (!existingTableNames.contains(BudgetNotificationEventsTable.table)) {
    await db.execute('''
      CREATE TABLE ${BudgetNotificationEventsTable.table} (
        ${BudgetNotificationEventsTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${BudgetNotificationEventsTable.categoryId} INTEGER NOT NULL,
        ${BudgetNotificationEventsTable.year} INTEGER NOT NULL,
        ${BudgetNotificationEventsTable.month} INTEGER NOT NULL,
        ${BudgetNotificationEventsTable.threshold} REAL NOT NULL,
        ${BudgetNotificationEventsTable.createdAt} TEXT NOT NULL,
        UNIQUE(${BudgetNotificationEventsTable.categoryId}, ${BudgetNotificationEventsTable.year}, ${BudgetNotificationEventsTable.month}, ${BudgetNotificationEventsTable.threshold}),

        FOREIGN KEY(${BudgetNotificationEventsTable.categoryId}) REFERENCES ${CategoriasTable.table}(${CategoriasTable.id})
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
        ${PresupuestosTable.repeatBudget} INTEGER DEFAULT 0,
        FOREIGN KEY(${PresupuestosTable.categoryId}) REFERENCES ${CategoriasTable.table}(${CategoriasTable.id})
      );
    ''');
  }
}
