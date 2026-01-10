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

    _database = await _initDB('control_financiero.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate
    );
  }

  Future _onCreate(Database db, int version) async {
    // Aquí puedes crear las tablas necesarias
    await db.execute('''
      CREATE TABLE ${TipoCategoriasTable.table} (
        ${TipoCategoriasTable.id} TEXT PRIMARY KEY,
        ${TipoCategoriasTable.name} TEXT NOT NULL,
        ${TipoCategoriasTable.description} TEXT
      );
    ''');
    
    await db.execute('''
      CREATE TABLE ${CategoriasTable.table} (
        ${CategoriasTable.id} TEXT PRIMARY KEY,
        ${CategoriasTable.name} TEXT NOT NULL,
        ${CategoriasTable.description} TEXT,
        ${CategoriasTable.movementType} TEXT NOT NULL,
        ${CategoriasTable.categoryTypeId} TEXT NOT NULL,
        ${CategoriasTable.iconName} TEXT NOT NULL,
        ${CategoriasTable.iconColorValue} INTEGER NOT NULL,
        FOREIGN KEY(${CategoriasTable.categoryTypeId}) REFERENCES ${TipoCategoriasTable.table}(${TipoCategoriasTable.id})
      );
    ''');

    await db.execute('''
      CREATE TABLE ${MovimientosTable.table} (
        ${MovimientosTable.id} TEXT PRIMARY KEY,
        ${MovimientosTable.title} TEXT NOT NULL,
        ${MovimientosTable.categoryId} TEXT NOT NULL,
        ${MovimientosTable.type} TEXT NOT NULL,
        ${MovimientosTable.ammount} REAL NOT NULL,
        ${MovimientosTable.date} TEXT NOT NULL,
        ${MovimientosTable.time} TEXT NOT NULL,
        ${MovimientosTable.note} TEXT DEFAULT '',
        FOREIGN KEY(${MovimientosTable.categoryId}) REFERENCES ${CategoriasTable.table}(${CategoriasTable.id})
      )
    ''');
  }
}
