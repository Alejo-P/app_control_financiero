import 'package:control_financiero/features/categorias/data/categorias_local_datasource.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';

abstract class _CategoriasRepository {
  /// Obtiene la lista de categorías.
  /// @return Una lista de objetos Categoria.
  Future<List<Categoria>> fetchCategorias();

  /// Agrega una nueva categoría.
  /// @param categoria El objeto Categoria a agregar.
  /// @return Un valor booleano que indica si la operación fue exitosa.
  Future<Map<String, dynamic>> addCategoria(Categoria categoria);

  /// Actualiza una categoría existente.
  /// @param categoria El objeto Categoria con los datos actualizados.
  /// @return Un valor booleano que indica si la operación fue exitosa.
  Future<Map<String, dynamic>> updateCategoria(Categoria categoria);

  /// Elimina una categoría por su ID.
  /// @param id El ID de la categoría a eliminar.
  /// @return Un valor booleano que indica si la operación fue exitosa.
  Future<Map<String, dynamic>> deleteCategoria(int id);
}

class CategoriasRepository implements _CategoriasRepository {
  final CategoriasLocalDataSource localDataSource;
  final List<Categoria> categorias = [];

  CategoriasRepository(this.localDataSource);

  @override
  Future<List<Categoria>> fetchCategorias() async {
    categorias.clear();
    categorias.addAll(await localDataSource.fetchCategorias());
    return categorias;
  }

  @override
  Future<Map<String, dynamic>> addCategoria(Categoria categoria) async {
    final success = await localDataSource.addCategoria(categoria);
    if (success['success'] == true) {
      categorias.add(categoria);
    }
    return success;
  }

  @override
  Future<Map<String, dynamic>> updateCategoria(Categoria categoria) async {
    final success = await localDataSource.updateCategoria(categoria);
    if (success['success'] == true) {
      final index = categorias.indexWhere((c) => c.id == categoria.id);
      if (index != -1) {
        categorias[index] = categoria;
      }
    }
    return success;
  }

  @override
  Future<Map<String, dynamic>> deleteCategoria(int id) async {
    final success = await localDataSource.deleteCategoria(id);
    if (success['success'] == true) {
      categorias.removeWhere((c) => c.id == id);
    }
    return success;
  }
}