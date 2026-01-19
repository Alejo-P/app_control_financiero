import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/database/db_helper.dart';
import 'package:control_financiero/core/database/db_tables.dart';
import 'package:control_financiero/core/models/operation_result.dart';
import 'package:control_financiero/features/movimientos/models/movimiento.dart';
import 'package:control_financiero/features/movimientos/models/totales_mensuales.dart';
import 'package:sqflite/sqflite.dart';

class MovimientosLocalDataSource {
  final DBHelper _dbHelper = DBHelper.instance;

  // Obtener todos los movimientos
  Future<List<Movimiento>> fetchMovimientosByMonthAndYear(DateTime date) async {
    final db = await _dbHelper.database;
    final String month = date.month.toString().padLeft(2, '0');
    final int year = date.year;

    final List<Map<String, dynamic>> maps = await db.query(
      MovimientosTable.table,
      where: "strftime('%Y-%m', ${MovimientosTable.date}) = ?",
      whereArgs: ['$year-$month'],
      orderBy: '${MovimientosTable.date} DESC, ${MovimientosTable.time} DESC',
    );

    return maps.map(Movimiento.fromMap).toList();
  }

  // Obtener cantidad de movimientos por categoría
  Future<int> fetchMovimientoCountByCategory(int categoryId) async {
    final db = await _dbHelper.database;
    final int count = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM ${MovimientosTable.table} WHERE ${MovimientosTable.categoryId} = ?',
        [categoryId],
      ),
    ) ?? 0;

    return count;
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

  // Obtener movimientos por fecha y tipo
  Future<List<Movimiento>> fetchMovimientosByDateAndType(
    DateTime date,
    TipoMovimiento type,
  ) async {
    final db = await _dbHelper.database;
    final String dateString = date.toIso8601String().split('T')[0];
    final List<Map<String, dynamic>> maps = await db.query(
      MovimientosTable.table,
      where:
          "date(${MovimientosTable.date}) = ? AND ${MovimientosTable.type} = ?",
      whereArgs: [dateString, type.name],
      orderBy: '${MovimientosTable.date} DESC, ${MovimientosTable.time} DESC',
    );

    return maps.map(Movimiento.fromMap).toList();
  }

  // Obtener ingresos y gastos totales para una fecha dada
  Future<TotalesMensuales> fetchTotalesMensuales(DateTime date) async {
    double ingresos = 0.0;
    double gastos = 0.0;

    final db = await _dbHelper.database;
    final String dateString = date.toIso8601String().split('T')[0];
    final List<Map<String, dynamic>> maps = await db.query(
      MovimientosTable.table,
      where: "strftime('%Y-%m', ${MovimientosTable.date}) = ?",
      whereArgs: [dateString.substring(0, 7)],
    );

    for (final map in maps) {
      final movimiento = Movimiento.fromMap(map);
      if (movimiento.type == TipoMovimiento.ingreso) {
        ingresos += movimiento.amount;
      } else {
        gastos += movimiento.amount;
      }
    }

    return TotalesMensuales(ingresos: ingresos, gastos: gastos);
  }

  // Agregar un nuevo movimiento
  Future<OperationResult<int>> addMovimiento(Movimiento movimiento) async {
    final db = await _dbHelper.database;
    final int id = await db.insert(
      MovimientosTable.table,
      movimiento.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return OperationResult<int>(
      success: id > 0,
      data: id > 0 ? id : null,
      message: id > 0
          ? 'Movimiento agregado exitosamente.'
          : 'Error al agregar el movimiento.',
    );
  }

  // Actualizar un movimiento existente
  Future<OperationResult<void>> updateMovimiento(Movimiento movimiento) async {
    final db = await _dbHelper.database;
    final result = await db.update(
      MovimientosTable.table,
      movimiento.toMap(),
      where: '${MovimientosTable.id} = ?',
      whereArgs: [movimiento.id],
    );

    return OperationResult<void>(
      success: result > 0,
      message: result > 0
          ? 'Movimiento actualizado exitosamente.'
          : 'Error al actualizar el movimiento.',
    );
  }

  // Eliminar un movimiento por ID
  Future<OperationResult<void>> deleteMovimiento(int id) async {
    final db = await _dbHelper.database;
    final result = await db.delete(
      MovimientosTable.table,
      where: '${MovimientosTable.id} = ?',
      whereArgs: [id],
    );

    return OperationResult<void>(
      success: result > 0,
      message: result > 0
          ? 'Movimiento eliminado exitosamente.'
          : 'Error al eliminar el movimiento.',
    );
  }
}
