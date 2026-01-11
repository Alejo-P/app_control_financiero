import 'package:control_financiero/core/database/db_helper.dart';
import 'package:control_financiero/core/database/db_tables.dart';
import 'package:control_financiero/features/tipo_categorias/models/tipo_categoria.dart';

class TipoCategoriaLocalDataSource {
  final DBHelper _dbHelper = DBHelper.instance;

  // Obtener todos los tipos de categorías
  Future<List<TipoCategoria>> fetchTipoCategorias() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      TipoCategoriasTable.table,
      orderBy: '${TipoCategoriasTable.name} ASC',
    );

    return maps.map(TipoCategoria.fromMap).toList();
  }

  // Agregar un nuevo tipo de categoría
  Future<Map<String, dynamic>> addTipoCategoria(TipoCategoria tipoCategoria) async {
    final db = await _dbHelper.database;
    final result = await db.insert(
      TipoCategoriasTable.table,
      tipoCategoria.toMap()
    );

    return result > 0 
      ? {'success': true, 'message': 'Tipo de categoría agregada exitosamente.'} 
      : {'success': false, 'message': 'Error al agregar el tipo de categoría.'};
  }

  // Actualizar un tipo de categoría existente
  Future<Map<String, dynamic>> updateTipoCategoria(TipoCategoria tipoCategoria) async {
    final db = await _dbHelper.database;
    final result = await db.update(
      TipoCategoriasTable.table,
      tipoCategoria.toMap(),
      where: '${TipoCategoriasTable.id} = ?',
      whereArgs: [tipoCategoria.id],
    );

    return result > 0
      ? {'success': true, 'message': 'Tipo de categoría actualizada exitosamente.'} 
      : {'success': false, 'message': 'Error al actualizar el tipo de categoría.'};
  }

  // Eliminar un tipo de categoría por su ID
  Future<Map<String, dynamic>> deleteTipoCategoria(int id) async {
    final db = await _dbHelper.database;
    final result = await db.delete(
      TipoCategoriasTable.table,
      where: '${TipoCategoriasTable.id} = ?',
      whereArgs: [id],
    );
    
    return result > 0 
      ? {'success': true, 'message': 'Tipo de categoría eliminada exitosamente.'} 
      : {'success': false, 'message': 'Error al eliminar el tipo de categoría.'};
  }
}