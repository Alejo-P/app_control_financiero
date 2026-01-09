import 'package:control_financiero/core/database/db_helper.dart';
import 'package:control_financiero/core/database/db_tables.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';

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
  Future<bool> addCategoria(Categoria categoria) async {
    final db = await _dbHelper.database;
    final result = await db.insert(
      CategoriasTable.table,
      categoria.toMap()
    );

    return result > 0;
  }

  // Actualizar una categoría existente
  Future<bool> updateCategoria( Categoria categoria) async {
    final db = await _dbHelper.database;
    final result = await db.update(
      CategoriasTable.table,
      categoria.toMap(),
      where: '${CategoriasTable.id} = ?',
      whereArgs: [categoria.id],
    );

    return result > 0;
  }

  // Eliminar una categoría por su ID
  Future<bool> deleteCategoria(String id) async {
    final db = await _dbHelper.database;
    final result = await db.delete(
      CategoriasTable.table,
      where: '${CategoriasTable.id} = ?',
      whereArgs: [id],
    );
    
    return result > 0;
  }
}