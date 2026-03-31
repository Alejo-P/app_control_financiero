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
    final String month = date.month.toString().padLeft(2, '0');
    final int year = date.year;

    final List<Map<String, dynamic>> maps = await db.query(
      IngresoPresupuestadoTable.table,
      where: "strftime('%Y-%m', ${IngresoPresupuestadoTable.date}) = ?",
      whereArgs: ['$year-$month'],
    );

    if (maps.isEmpty) {
      return IngresoPresupuestado(monto: 0.0, fecha: date);
    }

    if (maps.length > 1) {
      // Si hay más de un registro, tomar el primero y eliminar los demás
      final first = maps.first;
      final idsToDelete = maps.skip(1).map((map) => map['id'] as int).toList();
      await db.delete(
        IngresoPresupuestadoTable.table,
        where: 'id IN (${idsToDelete.join(',')})',
      );
      return IngresoPresupuestado.fromMap(first);
    }

    return IngresoPresupuestado.fromMap(maps.first);
  }

  // Obtener todos los presupuestos del mes y año dados
  Future<List<Presupuesto>> fetchPresupuestosByMonthAndYear(
    DateTime date,
  ) async {
    final db = await _dbHelper.database;
    final String month = date.month.toString().padLeft(2, '0');
    final int year = date.year;

    final List<Map<String, dynamic>> maps = await db.query(
      PresupuestosTable.table,
      where: "strftime('%Y-%m', ${PresupuestosTable.date}) = ?",
      whereArgs: ['$year-$month'],
      orderBy: '${PresupuestosTable.date} ASC',
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

  // Obtener porcentaje de presupuesto utilizado por categoría y mes
  Future<double> fetchPresupuestoUtilizadoPercentageByCategoryAndMonth(
    int categoryId,
    DateTime date,
  ) async {
    final db = await _dbHelper.database;
    final String month = date.month.toString().padLeft(2, '0');
    final int year = date.year;

    // Obtener el presupuesto para la categoría y mes dados
    final List<Map<String, dynamic>> presupuestoMaps = await db.query(
      PresupuestosTable.table,
      where:
          "${PresupuestosTable.categoryId} = ? AND strftime('%Y-%m', ${PresupuestosTable.date}) = ?",
      whereArgs: [categoryId, '$year-$month'],
    );

    if (presupuestoMaps.isEmpty) {
      return 0.0; // No hay presupuesto definido, por lo tanto 0% utilizado
    }

    final double presupuestoMonto =
        (presupuestoMaps.first[PresupuestosTable.amount] as num).toDouble();

    // Obtener el total gastado para la categoría y mes dados
    final List<Map<String, dynamic>> gastoMaps = await db.rawQuery(
      '''
      SELECT SUM(${MovimientosTable.amount}) AS total_gastado
      FROM ${MovimientosTable.table}
      WHERE ${MovimientosTable.categoryId} = ? AND strftime('%Y-%m', ${MovimientosTable.date}) = ?
      ''',
      [categoryId, '$year-$month'],
    );

    final double totalGastado =
        (gastoMaps.first['total_gastado'] as num?)?.toDouble() ?? 0.0;

    if (presupuestoMonto == 0) {
      return 0.0; // Evitar división por cero
    }

    return (totalGastado / presupuestoMonto) * 100;
  }

  // Agregar o actualizar ingreso presupuestado
  Future<OperationResult<int>> upsertIngresoPresupuestado(
    IngresoPresupuestado ingreso,
  ) async {
    final db = await _dbHelper.database;
    final String month = ingreso.fecha.month.toString().padLeft(2, '0');
    final int year = ingreso.fecha.year;

    // Verificar si ya existe un ingreso presupuestado para la fecha dada
    final List<Map<String, dynamic>> existing = await db.query(
      IngresoPresupuestadoTable.table,
      where: "strftime('%Y-%m', ${IngresoPresupuestadoTable.date}) = ?",
      whereArgs: ['$year-$month'],
    );

    if (existing.isNotEmpty) {
      // Actualizar el ingreso presupuestado existente
      final int count = await db.update(
        IngresoPresupuestadoTable.table,
        ingreso.toMap(),
        where: "strftime('%Y-%m', ${IngresoPresupuestadoTable.date}) = ?",
        whereArgs: ['$year-$month'],
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

  // Obtener conteo de presupuestos para una categoria
  Future<int> fetchPresupuestoCountByCategory(int categoryId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS count
      FROM ${PresupuestosTable.table}
      WHERE ${PresupuestosTable.categoryId} = ?
    ''',
      [categoryId],
    );

    return result.first['count'] as int;
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
    AppLogger.log('Actualizando presupuesto: $presupuesto');

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
