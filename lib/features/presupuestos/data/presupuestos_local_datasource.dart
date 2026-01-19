import 'package:control_financiero/core/database/db_helper.dart';
import 'package:control_financiero/core/database/db_tables.dart';
import 'package:control_financiero/core/models/operation_result.dart';
import 'package:control_financiero/features/presupuestos/models/presupuesto.dart';

class PresupuestosLocalDataSource {
  final DBHelper _dbHelper = DBHelper.instance;

  // Obtener todos los presupuestos del mes y año dados
  Future<List<Presupuesto>> fetchPresupuestosByMonthAndYear(
    DateTime date,
  ) async {
    final db = await _dbHelper.database;
    final String dateString = date.toIso8601String().split('T')[0];

    final List<Map<String, dynamic>> maps = await db.query(
      PresupuestosTable.table,
      where: "date(${PresupuestosTable.date}) = ?",
      whereArgs: [dateString],
    );

    return maps.map((map) => Presupuesto.fromMap(map)).toList();
  }

  // Obtener presupuesto por categoría y mes
  Future<Presupuesto?> fetchPresupuestoByCategoryAndMonth(
    int categoryId,
    DateTime date,
  ) async {
    final db = await _dbHelper.database;
    final String month = date.month.toString().padLeft(2, '0');
    final int year = date.year;

    final List<Map<String, dynamic>> maps = await db.query(
      PresupuestosTable.table,
      where:
          "${PresupuestosTable.categoryId} = ? AND strftime('%Y-%m', ${PresupuestosTable.date}) = ?",
      whereArgs: [categoryId, '$year-$month'],
    );

    if (maps.isNotEmpty) {
      return Presupuesto.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Agregar un nuevo presupuesto
  Future<OperationResult<int>> addPresupuesto(Presupuesto presupuesto) async {
    final db = await _dbHelper.database;
    final int id = await db.insert(
      PresupuestosTable.table,
      presupuesto.toMap(),
    );

    return OperationResult<int>(
      success: id > 0,
      data: id > 0 ? id : null,
      message: id > 0
          ? 'Presupuesto agregado exitosamente.'
          : 'Error al agregar el presupuesto.',
    );
  }

  // Actualizar un presupuesto existente
  Future<OperationResult<void>> updatePresupuesto(Presupuesto presupuesto) async {
    final db = await _dbHelper.database;
    final int count = await db.update(
      PresupuestosTable.table,
      presupuesto.toMap(),
      where: '${PresupuestosTable.id} = ?',
      whereArgs: [presupuesto.id],
    );

    return OperationResult<void>(
      success: count > 0,
      message: count > 0
          ? 'Presupuesto actualizado exitosamente.'
          : 'Error al actualizar el presupuesto.',
    );
  }

  // Eliminar un presupuesto por ID
  Future<OperationResult<void>> deletePresupuesto(int id) async {
    final db = await _dbHelper.database;
    final int count = await db.delete(
      PresupuestosTable.table,
      where: '${PresupuestosTable.id} = ?',
      whereArgs: [id],
    );

    return OperationResult<void>(
      success: count > 0,
      message: count > 0
          ? 'Presupuesto eliminado exitosamente.'
          : 'Error al eliminar el presupuesto.',
    );
  }
}
