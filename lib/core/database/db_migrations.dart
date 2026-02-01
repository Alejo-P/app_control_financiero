import 'package:control_financiero/core/database/db_tables.dart';
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

Future<void> migrateMovimientosTable(Database db) async {
  // Eliminar la columna 'type' si existe
  final columns = await db.rawQuery(
    "PRAGMA table_info(${MovimientosTable.table});",
  );

  final columnNames = columns.map((column) => column['name'] as String).toSet();

  if (columnNames.contains('type')) {
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
          ${MovimientosTable.amount},
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
