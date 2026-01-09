import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/database/db_helper.dart';
import 'package:control_financiero/core/database/db_tables.dart';
import 'package:control_financiero/features/movimientos/models/movimiento.dart';
import 'package:sqflite/sqflite.dart';

class MovimientosLocalDataSource {
  final DBHelper _dbHelper = DBHelper.instance;

  // Obtener todos los movimientos
  Future<List<Movimiento>> fetchMovimientos() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      MovimientosTable.table,
      orderBy: '${MovimientosTable.date} DESC, ${MovimientosTable.time} DESC',
    );

    return maps.map(Movimiento.fromMap).toList();
  }

  // Obtener movimientos por categoría
  Future<List<Movimiento>> fetchMovimientosByCategory(String categoryId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      MovimientosTable.table,
      where: '${MovimientosTable.categoryId} = ?',
      whereArgs: [categoryId],
      orderBy: '${MovimientosTable.date} DESC, ${MovimientosTable.time} DESC',
    );

    return maps.map(Movimiento.fromMap).toList();
  }

  // Obtener movimientos por fecha
  Future<List<Movimiento>> fetchMovimientosByDate(DateTime date) async {
    final db = await _dbHelper.database;
    final String dateString = date.toIso8601String().split('T')[0];
    final List<Map<String, dynamic>> maps = await db.query(
      MovimientosTable.table,
      where: "date(${MovimientosTable.date}) = ?",
      whereArgs: [dateString],
      orderBy: '${MovimientosTable.date} DESC, ${MovimientosTable.time} DESC',
    );

    return maps.map(Movimiento.fromMap).toList();
  }
  
  // Obtener moviimeintos por fecha y tipo
  Future<List<Movimiento>> fetchMovimientosByDateAndType(
    DateTime date,
    TipoMovimiento type
  ) async {
    final db = await _dbHelper.database;
    final String dateString = date.toIso8601String().split('T')[0];
    final List<Map<String, dynamic>> maps = await db.query(
      MovimientosTable.table,
      where: "date(${MovimientosTable.date}) = ? AND ${MovimientosTable.type} = ?",
      whereArgs: [dateString, type.name],
      orderBy: '${MovimientosTable.date} DESC, ${MovimientosTable.time} DESC',
    );

    return maps.map(Movimiento.fromMap).toList();
  }

  // Agregar un nuevo movimiento
  Future<bool> addMovimiento(Movimiento movimiento) async {
    final db = await _dbHelper.database;
    final result = await db.insert(
      MovimientosTable.table,
      movimiento.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace
    );

    return result > 0;
  }

  // Actualizar un movimiento existente
  Future<bool> updateMovimiento(Movimiento movimiento) async {
    final db = await _dbHelper.database;
    final result = await db.update(
      MovimientosTable.table,
      movimiento.toMap(),
      where: '${MovimientosTable.id} = ?',
      whereArgs: [movimiento.id],
    );

    return result > 0;
  }

  // Eliminar un movimiento por ID
  Future<bool> deleteMovimiento(String id) async {
    final db = await _dbHelper.database;
    final result = await db.delete(
      MovimientosTable.table,
      where: '${MovimientosTable.id} = ?',
      whereArgs: [id],
    );
    
    return result > 0;
  }
}