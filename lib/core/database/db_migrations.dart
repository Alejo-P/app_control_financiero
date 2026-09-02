import 'package:control_financiero/core/database/db_tables.dart';
import 'package:control_financiero/core/utils/app_logger.dart';
import 'package:sqflite/sqflite.dart';

Future<void> migrateMovimientosAmount(Database db) async {
  // Renombrar la columna 'ammount' a 'amount' si es necesario
  final columns = await db.rawQuery(
    "PRAGMA table_info(${MovimientosTable.table});",
  );
  final oldAmountColumnName = 'ammount';

  final columnNames = columns.map((column) => column['name'] as String).toSet();

  if (columnNames.contains(oldAmountColumnName) &&
      !columnNames.contains(MovimientosTable.amount)) {
    // Iniciar la migración
    await db.transaction((txn) async {
      await txn.execute('''
        ALTER TABLE ${MovimientosTable.table}
        RENAME TO temp_${MovimientosTable.table};
      ''');

      await txn.execute('''
        CREATE TABLE ${MovimientosTable.table} (
          ${MovimientosTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${MovimientosTable.title} TEXT NOT NULL,
          ${MovimientosTable.categoryId} INTEGER NOT NULL,
          ${MovimientosTable.amount} REAL NOT NULL,
          ${MovimientosTable.date} TEXT NOT NULL,
          ${MovimientosTable.time} TEXT NOT NULL,
          ${MovimientosTable.note} TEXT DEFAULT '',
          FOREIGN KEY(${MovimientosTable.categoryId}) REFERENCES ${CategoriasTable.table}(${CategoriasTable.id})
        )
      ''');

      await txn.execute('''
        INSERT INTO ${MovimientosTable.table} (
          ${MovimientosTable.id},
          ${MovimientosTable.title},
          ${MovimientosTable.categoryId},
          ${MovimientosTable.amount},
          ${MovimientosTable.date},
          ${MovimientosTable.time},
          ${MovimientosTable.note}
        )
        SELECT
          ${MovimientosTable.id},
          ${MovimientosTable.title},
          ${MovimientosTable.categoryId},
          $oldAmountColumnName,
          ${MovimientosTable.date},
          ${MovimientosTable.time},
          ${MovimientosTable.note}
        FROM temp_${MovimientosTable.table};
      ''');

      await txn.execute('''
        DROP TABLE temp_${MovimientosTable.table};
      ''');
    });
  }
}

Future<void> migrateRemoveObsoleteColumns(Database db) async {
  final categoryColumns = await db.rawQuery(
    'PRAGMA table_info(${CategoriasTable.table})',
  );
  final movementColumns = await db.rawQuery(
    'PRAGMA table_info(${MovimientosTable.table})',
  );
  final categoryColumnNames = categoryColumns
      .map((column) => column['name'] as String)
      .toSet();
  final movementColumnNames = movementColumns
      .map((column) => column['name'] as String)
      .toSet();

  if (!categoryColumnNames.contains('enabled_repeat_movement') &&
      !movementColumnNames.contains('repeat_movement')) {
    return;
  }

  await db.execute('PRAGMA foreign_keys = OFF');
  try {
    await db.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE categorias_new (
          ${CategoriasTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${CategoriasTable.name} TEXT NOT NULL,
          ${CategoriasTable.description} TEXT,
          ${CategoriasTable.movementType} TEXT NOT NULL,
          ${CategoriasTable.categoryTypeId} INTEGER NOT NULL,
          ${CategoriasTable.iconName} TEXT NOT NULL,
          ${CategoriasTable.iconColorValue} INTEGER NOT NULL,
          ${CategoriasTable.isDefault} INTEGER DEFAULT 0,
          FOREIGN KEY(${CategoriasTable.categoryTypeId}) REFERENCES ${TipoCategoriasTable.table}(${TipoCategoriasTable.id})
        )
      ''');
      await txn.execute('''
        INSERT INTO categorias_new
        SELECT
          ${CategoriasTable.id}, ${CategoriasTable.name}, ${CategoriasTable.description},
          ${CategoriasTable.movementType}, ${CategoriasTable.categoryTypeId},
          ${CategoriasTable.iconName}, ${CategoriasTable.iconColorValue},
          ${CategoriasTable.isDefault}
        FROM ${CategoriasTable.table}
      ''');
      await txn.execute('DROP TABLE ${CategoriasTable.table}');
      await txn.execute(
        'ALTER TABLE categorias_new RENAME TO ${CategoriasTable.table}',
      );

      await txn.execute('''
        CREATE TABLE movimientos_new (
          ${MovimientosTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${MovimientosTable.title} TEXT NOT NULL,
          ${MovimientosTable.categoryId} INTEGER NOT NULL,
          ${MovimientosTable.amount} REAL NOT NULL,
          ${MovimientosTable.date} TEXT NOT NULL,
          ${MovimientosTable.time} TEXT NOT NULL,
          ${MovimientosTable.note} TEXT DEFAULT '',
          FOREIGN KEY(${MovimientosTable.categoryId}) REFERENCES ${CategoriasTable.table}(${CategoriasTable.id})
        )
      ''');
      await txn.execute('''
        INSERT INTO movimientos_new
        SELECT
          ${MovimientosTable.id}, ${MovimientosTable.title},
          ${MovimientosTable.categoryId}, ${MovimientosTable.amount},
          ${MovimientosTable.date}, ${MovimientosTable.time}, ${MovimientosTable.note}
        FROM ${MovimientosTable.table}
      ''');
      await txn.execute('DROP TABLE ${MovimientosTable.table}');
      await txn.execute(
        'ALTER TABLE movimientos_new RENAME TO ${MovimientosTable.table}',
      );
    });

    final result = await db.rawQuery('PRAGMA foreign_key_check');
    if (result.isNotEmpty) {
      throw Exception('Foreign key check failed: $result');
    }
  } finally {
    await db.execute('PRAGMA foreign_keys = ON');
  }
}

Future<void> migratePresupuestosRepeatBudget(Database db) async {
  // Agregar la columna 'repeat_budget' si no existe
  final columns = await db.rawQuery(
    "PRAGMA table_info(${PresupuestosTable.table});",
  );

  final columnNames = columns.map((column) => column['name'] as String).toSet();

  if (!columnNames.contains(PresupuestosTable.repeatBudget)) {
    await db.execute('''
      ALTER TABLE ${PresupuestosTable.table}
      ADD COLUMN ${PresupuestosTable.repeatBudget}
      INTEGER DEFAULT 0;
    ''');

    // Verificar integridad
    final result = await db.rawQuery('PRAGMA foreign_key_check');
    if (result.isNotEmpty) {
      await AppLogger.log(
        'Foreign key check failed after migration: $result',
        level: LogLevel.error,
        tag: 'DBMigration',
      );
      throw Exception('Foreign key check failed: $result');
    }
  }
}

Future<void> migrateNotificationsCreatedAt(Database db) async {
  // Agregar la columna 'created_at' si no existe
  final columns = await db.rawQuery(
    "PRAGMA table_info(${NotificacionTable.table});",
  );

  final columnNames = columns.map((column) => column['name'] as String).toSet();

  if (!columnNames.contains(NotificacionTable.createdAt)) {
    await db.execute('''
      ALTER TABLE ${NotificacionTable.table}
      ADD COLUMN ${NotificacionTable.createdAt}
      TEXT;
    ''');
  }
}

Future<void> migrateNotificationsType(Database db) async {
  // Agregar la columna 'type' si no existe
  final columns = await db.rawQuery(
    "PRAGMA table_info(${NotificacionTable.table});",
  );

  final columnNames = columns.map((column) => column['name'] as String).toSet();

  if (!columnNames.contains(NotificacionTable.type)) {
    await db.execute('''
      ALTER TABLE ${NotificacionTable.table}
      ADD COLUMN ${NotificacionTable.type}
      TEXT NOT NULL DEFAULT 'general';
    ''');
  }
}

Future<void> migrateNotificationsObjectId(Database db) async {
  // Agregar la columna 'object_id' si no existe
  final columns = await db.rawQuery(
    "PRAGMA table_info(${NotificacionTable.table});",
  );

  final columnNames = columns.map((column) => column['name'] as String).toSet();

  if (!columnNames.contains(NotificacionTable.objectId)) {
    await db.execute('''
      ALTER TABLE ${NotificacionTable.table}
      ADD COLUMN ${NotificacionTable.objectId}
      INTEGER;
    ''');
  }
}
