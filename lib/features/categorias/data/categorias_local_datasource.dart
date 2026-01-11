import 'package:control_financiero/core/database/db_helper.dart';
import 'package:control_financiero/core/database/db_tables.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';
import 'package:sqflite/sqflite.dart';

class CategoriasLocalDataSource {
  final DBHelper _dbHelper = DBHelper.instance;

  // Obtener todas las categorías
  Future<List<Categoria>> fetchCategorias() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      CategoriasTable.table,
      orderBy: '${CategoriasTable.name} ASC',
    );

    return maps.map(Categoria.fromMap).toList();
  }

  // Agregar una nueva categoría
  Future<Map<String, dynamic>> addCategoria(Categoria categoria) async {
    final db = await _dbHelper.database;
    final result = await db.insert(
      CategoriasTable.table,
      categoria.toMap()
    );

    return result > 0 
      ? {'success': true, 'message': 'Categoría agregada exitosamente.'} 
      : {'success': false, 'message': 'Error al agregar la categoría.'};
  }

  // Actualizar una categoría existente
  Future<Map<String, dynamic>> updateCategoria( Categoria categoria) async {
    final db = await _dbHelper.database;
    final result = await db.update(
      CategoriasTable.table,
      categoria.toMap(),
      where: '${CategoriasTable.id} = ?',
      whereArgs: [categoria.id],
    );

    //TODO: Devolver la id del objeto afectado

    return result > 0 
      ? {'success': true, 'message': 'Categoría actualizada exitosamente.'} 
      : {'success': false, 'message': 'Error al actualizar la categoría.'};
  }

  // Eliminar una categoría por su ID
  Future<Map<String, dynamic>> deleteCategoria(int id) async {
    final db = await _dbHelper.database;

    // Comprobar que la categoría no es predeterminada
    final List<Map<String, dynamic>> maps = await db.query(
      CategoriasTable.table,
      where: '${CategoriasTable.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty && maps.first[CategoriasTable.isDefault] == 1) {
      // No eliminar si es predeterminada
      return {'success': false, 'message': 'No se puede eliminar una categoría predeterminada.'};
    }

    // Si tiene movimientos asociados, no eliminar
    final movimientoCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM ${MovimientosTable.table} WHERE ${MovimientosTable.categoryId} = ?',
      [id],
    )) ?? 0;
    if (movimientoCount > 0) {
      return {'success': false, 'message': 'No se puede eliminar una categoría con movimientos asociados.'};
    }

    final result = await db.delete(
      CategoriasTable.table,
      where: '${CategoriasTable.id} = ?',
      whereArgs: [id],
    );
    
    return result > 0 
      ? {'success': true, 'message': 'Categoría eliminada exitosamente.'} 
      : {'success': false, 'message': 'Error al eliminar la categoría.'};
  }
}