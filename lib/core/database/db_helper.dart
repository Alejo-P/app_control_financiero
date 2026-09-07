import 'package:control_financiero/core/constants/app_strings.dart';
import 'package:control_financiero/core/database/db_init_data.dart';
import 'package:control_financiero/core/database/db_seeds.dart';
import 'package:control_financiero/core/database/db_tables.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DBHelper {
  static Database? _database;
  static final DBHelper instance = DBHelper._internal();

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB(appDBName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, filePath);

    return await openDatabase(
      path,
      version: appDBVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      //onUpgrade: _onUpdate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await createTables(db);

    for (var tipo in tipoCategoriasList) {
      await upsertTipoCategoria(db, tipo);
    }

    for (var categoria in categoriasList) {
      await upsertCategoria(db, categoria);
    }

    for (var notif in presupuestosNotif) {
      await upsertBudgetNotification(db, notif);
    }

    for (var config in movementNotificationConfigs) {
      await upsertMovementNotificationConfig(db, config);
    }

    for (var recordatorio in defaultReminders) {
      await upsertRecordatorios(db, recordatorio);
    }
  }
}
