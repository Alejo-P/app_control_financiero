import 'package:control_financiero/core/database/db_helper.dart';
import 'package:control_financiero/core/database/db_tables.dart';
import 'package:control_financiero/core/models/operation_result.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';
import 'package:control_financiero/features/movimientos/data/movimientos_local_datasource.dart';

class CategoriasLocalDataSource {
  final DBHelper _dbHelper = DBHelper.instance;
  final MovimientosLocalDataSource _movimientosLocalDataSource =
      MovimientosLocalDataSource();

  // Obtener todas las categorías
  Future<List<Categoria>> fetchCategorias() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
        SELECT 
          c.*, 
          (SELECT COUNT(*) FROM ${MovimientosTable.table} m WHERE m.${MovimientosTable.categoryId} = c.${CategoriasTable.id}) AS movements_count
        FROM ${CategoriasTable.table} c
        ORDER BY c.${CategoriasTable.name} ASC
      ''',
    );

    return maps.map(Categoria.fromMap).toList();
  }

  // Obtener una categoría por su ID
  Future<Categoria?> fetchCategoriaById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
        SELECT 
          c.*, 
          (SELECT COUNT(*) FROM ${MovimientosTable.table} m WHERE m.${MovimientosTable.categoryId} = c.${CategoriasTable.id}) AS movements_count
        FROM ${CategoriasTable.table} c
        WHERE c.${CategoriasTable.id} = ?
      ''',
      [id],
    );

    if (maps.isNotEmpty) {
      return Categoria.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Agregar una nueva categoría
  Future<OperationResult<int>> addCategoria(Categoria categoria) async {
    final db = await _dbHelper.database;
    final id = await db.insert(CategoriasTable.table, categoria.toMap());

    return OperationResult<int>(
      success: id > 0,
      message: id > 0
          ? 'Categoría agregada exitosamente.'
          : 'Error al agregar la categoría.',
      data: id > 0 ? id : null,
    );
  }

  // Actualizar una categoría existente
  Future<OperationResult<void>> updateCategoria(Categoria categoria) async {
    final db = await _dbHelper.database;

    // Comprobar que la categoría no es predeterminada
    final List<Map<String, dynamic>> maps = await db.query(
      CategoriasTable.table,
      where: '${CategoriasTable.id} = ?',
      whereArgs: [categoria.id],
    );

    if (maps.isNotEmpty && maps.first[CategoriasTable.isDefault] == 1) {
      // No actualizar si es predeterminada
      return OperationResult<void>(
        success: false,
        message: 'No se puede actualizar una categoría predeterminada.',
      );
    }

    final result = await db.update(
      CategoriasTable.table,
      categoria.toMap(),
      where: '${CategoriasTable.id} = ?',
      whereArgs: [categoria.id],
    );

    return OperationResult<void>(
      success: result > 0,
      message: result > 0
          ? 'Categoría actualizada exitosamente.'
          : 'Error al actualizar la categoría.',
    );
  }

  // Eliminar una categoría por su ID
  Future<OperationResult<void>> deleteCategoria(int id) async {
    final db = await _dbHelper.database;

    // Comprobar que la categoría no es predeterminada
    final List<Map<String, dynamic>> maps = await db.query(
      CategoriasTable.table,
      where: '${CategoriasTable.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty && maps.first[CategoriasTable.isDefault] == 1) {
      // No eliminar si es predeterminada
      return OperationResult<void>(
        success: false,
        message: 'No se puede eliminar una categoría predeterminada.',
      );
    }

    // Si tiene movimientos asociados, no eliminar
    final movimientoCount = await _movimientosLocalDataSource
        .fetchMovimientoCountByCategory(id);
    if (movimientoCount > 0) {
      return OperationResult<void>(
        success: false,
        message:
            'No se puede eliminar esta categoría. Tiene $movimientoCount${movimientoCount == 1 ? ' movimiento asociado.' : ' movimientos asociados.'}',
      );
    }

    final result = await db.delete(
      CategoriasTable.table,
      where: '${CategoriasTable.id} = ?',
      whereArgs: [id],
    );

    return OperationResult<void>(
      success: result > 0,
      message: result > 0
          ? 'Categoría eliminada exitosamente.'
          : 'Error al eliminar la categoría.',
    );
  }
}
