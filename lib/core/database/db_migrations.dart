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
          ${MovimientosTable.repeatMovement} INTEGER DEFAULT 0,
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
          ${MovimientosTable.note},
          ${MovimientosTable.repeatMovement}
        )
        SELECT
          ${MovimientosTable.id},
          ${MovimientosTable.title},
          ${MovimientosTable.categoryId},
          $oldAmountColumnName,
          ${MovimientosTable.date},
          ${MovimientosTable.time},
          ${MovimientosTable.note},
          0 -- Valor predeterminado para repeat_movement
        FROM temp_${MovimientosTable.table};
      ''');

      await txn.execute('''
        DROP TABLE temp_${MovimientosTable.table};
      ''');
    });
  }
}

Future<void> migrateMovimientosTable(Database db) async {
  // Agregar la columna 'repeat_movement' si no existe
  final columns = await db.rawQuery(
    "PRAGMA table_info(${MovimientosTable.table});",
  );

  final columnNames = columns.map((column) => column['name'] as String).toSet();

  if (!columnNames.contains(MovimientosTable.repeatMovement)) {
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
          ${MovimientosTable.repeatMovement} INTEGER DEFAULT 0,
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
          ${MovimientosTable.note},
          ${MovimientosTable.repeatMovement}
        )
        SELECT
          ${MovimientosTable.id},
          ${MovimientosTable.title},
          ${MovimientosTable.categoryId},
          ${MovimientosTable.amount},
          ${MovimientosTable.date},
          ${MovimientosTable.time},
          ${MovimientosTable.note},
          0 -- Valor predeterminado para repeat_movement
        FROM temp_${MovimientosTable.table};
      ''');

      await txn.execute('''
        DROP TABLE temp_${MovimientosTable.table};
      ''');
    });
  }
}

Future<void> migrateCategoriasEnabledRepeatMovement(Database db) async {
  // Agregar la columna 'enabled_repeat_movement' si no existe
  final columns = await db.rawQuery(
    "PRAGMA table_info(${CategoriasTable.table});",
  );

  final columnNames = columns.map((column) => column['name'] as String).toSet();

  if (!columnNames.contains(CategoriasTable.enabledRepeatMovement)) {
    await db.execute('''
      ALTER TABLE ${CategoriasTable.table}
      ADD COLUMN ${CategoriasTable.enabledRepeatMovement}
      INTEGER DEFAULT 0;
    ''');

    // Verificar integridad
    final result = await db.rawQuery('PRAGMA foreign_key_check');
    if (result.isNotEmpty) {
      AppLogger.log(
        'Foreign key check failed after migration: $result',
        level: LogLevel.error,
        tag: 'DBMigration',
      );
      throw Exception('Foreign key check failed: $result');
    }
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
      AppLogger.log(
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