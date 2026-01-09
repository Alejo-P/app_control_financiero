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
  Future<bool> addTipoCategoria(TipoCategoria tipoCategoria) async {
    final db = await _dbHelper.database;
    final result = await db.insert(
      TipoCategoriasTable.table,
      tipoCategoria.toMap()
    );

    return result > 0;
  }

  // Actualizar un tipo de categoría existente
  Future<bool> updateTipoCategoria(TipoCategoria tipoCategoria) async {
    final db = await _dbHelper.database;
    final result = await db.update(
      TipoCategoriasTable.table,
      tipoCategoria.toMap(),
      where: '${TipoCategoriasTable.id} = ?',
      whereArgs: [tipoCategoria.id],
    );

    return result > 0;
  }

  // Eliminar un tipo de categoría por su ID
  Future<bool> deleteTipoCategoria(String id) async {
    final db = await _dbHelper.database;
    final result = await db.delete(
      TipoCategoriasTable.table,
      where: '${TipoCategoriasTable.id} = ?',
      whereArgs: [id],
    );
    
    return result > 0;
  }
}