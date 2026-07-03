import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/database/db_helper.dart';
import 'package:control_financiero/core/database/db_tables.dart';
import 'package:control_financiero/core/models/operation_result.dart';
import 'package:control_financiero/core/utils/app_logger.dart';
import 'package:control_financiero/features/etiquetas/models/etiqueta.dart';
import 'package:control_financiero/features/movimientos/models/detalle_movimiento.dart';
import 'package:control_financiero/features/movimientos/models/movimiento.dart';
import 'package:control_financiero/features/movimientos/models/totales_mensuales.dart';
import 'package:sqflite/sqflite.dart';

class MovimientosLocalDataSource {
  final DBHelper _dbHelper = DBHelper.instance;

  Future<List<Movimiento>> fetchAllMovimientos() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      MovimientosTable.table,
      orderBy: '${MovimientosTable.date} DESC, ${MovimientosTable.time} DESC',
    );

    return maps.map(Movimiento.fromMap).toList();
  }

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

  Future<Movimiento?> fetchMovimientoById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      MovimientosTable.table,
      where: '${MovimientosTable.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Movimiento.fromMap(maps.first);
    } else {
      AppLogger.log(
        'Movimiento con ID $id no encontrado',
        level: LogLevel.warning,
      );
    }
    return null;
  }

  Future<DetalleMovimiento?> fetchDetalleMovimientoById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
        SELECT
          m.${MovimientosTable.id} AS id,
          m.${MovimientosTable.title} AS titulo,
          m.${MovimientosTable.amount} AS monto,
          m.${MovimientosTable.date} as fecha,
          m.${MovimientosTable.time} as hora,
          m.${MovimientosTable.note} AS nota,
          c.${CategoriasTable.name} AS categoria,
          c.${CategoriasTable.iconName} AS categoriaIcono,
          c.${CategoriasTable.iconColorValue} AS categoriaColor,
          c.${CategoriasTable.movementType} AS tipoMovimiento,
          c.${CategoriasTable.enabledRepeatMovement} as enabledRepeatMovement,
          m.${MovimientosTable.repeatMovement} as repeatMovement,
          c.${CategoriasTable.id} AS categoriaId
        FROM ${MovimientosTable.table} m
        JOIN ${CategoriasTable.table} c ON m.${MovimientosTable.categoryId} = c.${CategoriasTable.id}
        WHERE m.${MovimientosTable.id} = ?
      ''',
      [id],
    );

    if (maps.isNotEmpty) {
      final List<Map<String, dynamic>> etiquetaMaps = await db.rawQuery(
        '''
          SELECT e.${EtiquetasTable.id} AS id, e.${EtiquetasTable.name} AS nombre, e.${EtiquetasTable.colorValue} AS color
          FROM ${EtiquetasTable.table} e
          JOIN ${MovimientoEtiquetaTable.table} me ON e.${EtiquetasTable.id} = me.${MovimientoEtiquetaTable.etiquetaId}
          WHERE me.${MovimientoEtiquetaTable.movimientoId} = ?
        ''',
        [id],
      );

      final List<Etiqueta> etiquetas = etiquetaMaps.map((map) {
        return Etiqueta(
          id: map['id'] as int,
          name: map['nombre'] as String,
          colorValue: map['color'] as int,
        );
      }).toList();

      final DetalleMovimiento detalleMovimiento = DetalleMovimiento.fromMap(
        maps.first,
      ).copyWith(tags: etiquetas);
      return detalleMovimiento;
    } else {
      AppLogger.log(
        'Detalle del movimiento con ID $id no encontrado',
        level: LogLevel.warning,
      );
    }
    return null;
  }

  // Obtener cantidad de movimientos por categoría
  Future<int> fetchMovimientoCountByCategory(int categoryId) async {
    final db = await _dbHelper.database;
    final int count =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM ${MovimientosTable.table} WHERE ${MovimientosTable.categoryId} = ?',
            [categoryId],
          ),
        ) ??
        0;

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

  // Obtener ingresos y gastos totales para una fecha dada
  Future<TotalesMensuales> fetchTotalesMensuales(DateTime date) async {
    double ingresos = 0.0;
    double gastos = 0.0;

    try {
      final db = await _dbHelper.database;
      final String yearMonth = date.toIso8601String().substring(0, 7);
      final List<Map<String, dynamic>> result = await db.rawQuery(
        '''
          SELECT
            m.amount as monto,
            c.movement_type AS 'tipo movimiento'
          FROM movimientos m
          JOIN categorias c ON m.category_id = c.id
          WHERE strftime('%Y-%m', m.date) = ?
        ''',
        [yearMonth],
      );

      for (final map in result) {
        final monto = (map['monto'] as num?)?.toDouble() ?? 0;
        final tipoStr = map['tipo movimiento'] as String;
        final tipoMovimiento = TipoMovimientoMapper.fromString(tipoStr);

        if (tipoMovimiento == TipoMovimiento.ingreso) {
          ingresos += monto;
        } else {
          gastos += monto;
        }
      }
    } on Exception catch (e) {
      AppLogger.log(
        'Error al calcular totales mensuales: $e',
        level: LogLevel.error,
      );
    }

    return TotalesMensuales(ingresos: ingresos, gastos: gastos);
  }

  Future<Map<int, int>> getMovementsCountByCategory() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT c.${CategoriasTable.id} AS categoryId, 
      (SELECT COUNT(*) FROM ${MovimientosTable.table} m 
      WHERE m.${MovimientosTable.categoryId} = c.${CategoriasTable.id}) AS count
      FROM ${CategoriasTable.table} c
      GROUP BY c.${CategoriasTable.id};
    ''');

    return {
      for (var row in result) row['categoryId'] as int: row['count'] as int,
    };
  }

  Future<List<Movimiento>> getMovementsByCategoryID(int categoryID) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      MovimientosTable.table,
      where: "${MovimientosTable.categoryId} = ?",
      whereArgs: [categoryID],
      orderBy: '${MovimientosTable.date} DESC, ${MovimientosTable.time} DESC',
    );

    return maps.map(Movimiento.fromMap).toList();
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

  Future<OperationResult<int>> deleteAllMovimientos() async {
    final db = await _dbHelper.database;
    final result = await db.delete(MovimientosTable.table);

    return OperationResult<int>(
      success: result > 0,
      data: result,
      message: result > 0
          ? 'Todos los movimientos eliminados exitosamente.'
          : 'Error al eliminar los movimientos.',
    );
  }

  Future<List<Movimiento>> getMovimientosByEtiqueta(int etiquetaId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
        SELECT m.*
        FROM ${MovimientosTable.table} m
        JOIN ${MovimientoEtiquetaTable.table} me ON m.${MovimientosTable.id} = me.${MovimientoEtiquetaTable.movimientoId}
        WHERE me.${MovimientoEtiquetaTable.etiquetaId} = ?
        ORDER BY m.${MovimientosTable.date} DESC, m.${MovimientosTable.time} DESC
      ''',
      [etiquetaId],
    );

    return maps.map(Movimiento.fromMap).toList();
  }

  Future<List<Map<String, dynamic>>> getMovimientosForExcel() async {
    final db = await _dbHelper.database;

    final result = db.rawQuery('''
      SELECT
        m.${MovimientosTable.title} AS 'Concepto',
        m.${MovimientosTable.amount} AS 'Cantidad',
        m.${MovimientosTable.date} AS 'Fecha transaccion',
        c.${CategoriasTable.name} AS 'Categoria',
        c.${CategoriasTable.movementType} AS 'Tipo movimiento',
        m.${MovimientosTable.note} AS 'Descripcion'
      FROM ${MovimientosTable.table} m
      JOIN ${CategoriasTable.table} c ON m.${MovimientosTable.categoryId} = c.${CategoriasTable.id};
    ''');

    return result;
  }
}
