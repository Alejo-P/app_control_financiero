import 'package:control_financiero/core/database/db_tables.dart';
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
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Crear tablas
    await db.execute('''
      CREATE TABLE ${MetaTable.table} (
        ${MetaTable.key} TEXT PRIMARY KEY,
        ${MetaTable.value} TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE ${TipoCategoriasTable.table} (
        ${TipoCategoriasTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${TipoCategoriasTable.name} TEXT NOT NULL,
        ${TipoCategoriasTable.description} TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE ${CategoriasTable.table} (
        ${CategoriasTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${CategoriasTable.name} TEXT NOT NULL,
        ${CategoriasTable.description} TEXT,
        ${CategoriasTable.movementType} TEXT NOT NULL,
        ${CategoriasTable.categoryTypeId} INTEGER NOT NULL,
        ${CategoriasTable.iconName} TEXT NOT NULL,
        ${CategoriasTable.iconColorValue} INTEGER NOT NULL,
        ${CategoriasTable.isDefault} INTEGER DEFAULT 0,
        FOREIGN KEY(${CategoriasTable.categoryTypeId}) REFERENCES ${TipoCategoriasTable.table}(${TipoCategoriasTable.id})
      );
    ''');

    await db.execute('''
      CREATE TABLE ${MovimientosTable.table} (
        ${MovimientosTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${MovimientosTable.title} TEXT NOT NULL,
        ${MovimientosTable.categoryId} INTEGER NOT NULL,
        ${MovimientosTable.type} TEXT NOT NULL,
        ${MovimientosTable.ammount} REAL NOT NULL,
        ${MovimientosTable.date} TEXT NOT NULL,
        ${MovimientosTable.time} TEXT NOT NULL,
        ${MovimientosTable.note} TEXT DEFAULT '',
        FOREIGN KEY(${MovimientosTable.categoryId}) REFERENCES ${CategoriasTable.table}(${CategoriasTable.id})
      )
    ''');

    // Insertar valores iniciales
    for (var tipoCategoria in tipoCategoriasList) {
      await db.insert(TipoCategoriasTable.table, tipoCategoria.toMap());
    }

    for (var categoria in categoriasList) {
      await db.insert(CategoriasTable.table, categoria.toMap());
    }
  }
}
