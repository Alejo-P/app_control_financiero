import 'package:control_financiero/core/database/db_helper.dart';
import 'package:control_financiero/core/database/db_tables.dart';
import 'package:control_financiero/features/etiquetas/models/etiqueta.dart';
import 'package:sqflite/sqflite.dart';

class EtiquetasLocalDataSource {
  final DBHelper _dbHelper = DBHelper.instance;

  Future<List<Etiqueta>> getAllEtiquetas() async {
    final db = await _dbHelper.database;

    final etiquetas = await db.query(
      EtiquetasTable.table,
      orderBy: '${EtiquetasTable.name} ASC',
    );

    return etiquetas.map((e) => Etiqueta.fromMap(e)).toList();
  }

  Future<int> insertEtiqueta(Etiqueta etiqueta) async {
    final db = await _dbHelper.database;

    return await db.insert(
      EtiquetasTable.table,
      etiqueta.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateEtiqueta(Etiqueta etiqueta) async {
    final db = await _dbHelper.database;

    return await db.update(
      EtiquetasTable.table,
      etiqueta.toMap(),
      where: '${EtiquetasTable.id} = ?',
      whereArgs: [etiqueta.id],
    );
  }

  Future<int> deleteEtiqueta(int id) async {
    final db = await _dbHelper.database;

    return await db.delete(
      EtiquetasTable.table,
      where: '${EtiquetasTable.id} = ?',
      whereArgs: [id],
    );
  }

  // Asignar una etiqueta a un movimiento
  Future<int> assignEtiquetaToMovimiento(
    int movimientoId,
    int etiquetaId,
  ) async {
    final db = await _dbHelper.database;

    return await db.insert(MovimientoEtiquetaTable.table, {
      MovimientoEtiquetaTable.movimientoId: movimientoId,
      MovimientoEtiquetaTable.etiquetaId: etiquetaId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Eliminar una etiqueta de un movimiento
  Future<int> removeEtiquetaFromMovimiento(
    int movimientoId,
    int etiquetaId,
  ) async {
    final db = await _dbHelper.database;

    return await db.delete(
      MovimientoEtiquetaTable.table,
      where:
          '${MovimientoEtiquetaTable.movimientoId} = ? AND ${MovimientoEtiquetaTable.etiquetaId} = ?',
      whereArgs: [movimientoId, etiquetaId],
    );
  }

  // Obtener etiquetas asignadas a un movimiento
  Future<List<Etiqueta>> getEtiquetasForMovimiento(int movimientoId) async {
    final db = await _dbHelper.database;

    final maps = await db.rawQuery(
      '''
      SELECT e.*
      FROM ${EtiquetasTable.table} e
      INNER JOIN ${MovimientoEtiquetaTable.table} me ON e.${EtiquetasTable.id} = me.${MovimientoEtiquetaTable.etiquetaId}
      WHERE me.${MovimientoEtiquetaTable.movimientoId} = ?
    ''',
      [movimientoId],
    );

    return maps.map((e) => Etiqueta.fromMap(e)).toList();
  }
}
