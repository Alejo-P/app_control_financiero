import 'package:control_financiero/core/database/db_helper.dart';
import 'package:control_financiero/core/database/db_tables.dart';
import 'package:control_financiero/core/models/operation_result.dart';
import 'package:control_financiero/core/utils/app_logger.dart';
import 'package:control_financiero/features/presupuestos/models/ingreso_presupuestado.dart';
import 'package:control_financiero/features/presupuestos/models/presupuesto.dart';

class PresupuestosLocalDataSource {
  final DBHelper _dbHelper = DBHelper.instance;

  // Obtener el ingreso presupuestado del mes y año dados
  Future<IngresoPresupuestado> fetchIngresosPresupuestadosByMonthAndYear(
    DateTime date,
  ) async {
    final db = await _dbHelper.database;
    final String dateString = date.toIso8601String().split('T')[0];

    final List<Map<String, dynamic>> maps = await db.query(
      IngresoPresupuestadoTable.table,
      where: "date(${IngresoPresupuestadoTable.date}) = ?",
      whereArgs: [dateString],
    );

    if (maps.isEmpty) {
      return IngresoPresupuestado(monto: 0.0, fecha: date);
    }

    return IngresoPresupuestado.fromMap(maps.first);
  }

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

  // Agregar o actualizar ingreso presupuestado
  Future<OperationResult<int>> upsertIngresoPresupuestado(
    IngresoPresupuestado ingreso,
  ) async {
    final db = await _dbHelper.database;

    // Verificar si ya existe un ingreso presupuestado para la fecha dada
    final List<Map<String, dynamic>> existing = await db.query(
      IngresoPresupuestadoTable.table,
      where: "date(${IngresoPresupuestadoTable.date}) = ?",
      whereArgs: [ingreso.fecha.toIso8601String().split('T')[0]],
    );

    if (existing.isNotEmpty) {
      // Actualizar el ingreso presupuestado existente
      final int count = await db.update(
        IngresoPresupuestadoTable.table,
        ingreso.toMap(),
        where: "date(${IngresoPresupuestadoTable.date}) = ?",
        whereArgs: [ingreso.fecha.toIso8601String().split('T')[0]],
      );

      return OperationResult<int>(
        success: count > 0,
        data: existing.first['id'] as int,
        message: count > 0
            ? 'Ingreso presupuestado actualizado exitosamente.'
            : 'Error al actualizar el ingreso presupuestado.',
      );
    } else {
      // Insertar un nuevo ingreso presupuestado
      final int id = await db.insert(
        IngresoPresupuestadoTable.table,
        ingreso.toMap(),
      );

      return OperationResult<int>(
        success: id > 0,
        data: id,
        message: id > 0
            ? 'Ingreso presupuestado agregado exitosamente.'
            : 'Error al agregar el ingreso presupuestado.',
      );
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
  Future<OperationResult<void>> updatePresupuesto(
    Presupuesto presupuesto,
  ) async {
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
