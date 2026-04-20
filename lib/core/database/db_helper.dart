import 'package:control_financiero/core/constants/app_strings.dart';
import 'package:control_financiero/core/database/db_init_data.dart';
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
      version: 13,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpdate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await runSeeds(db);
  }

  Future<void> _onUpdate(Database db, int oldVersion, int newVersion) async {
    await runSeeds(db);
  }
}
