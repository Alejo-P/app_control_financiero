import 'package:control_financiero/features/categorias/data/categorias_local_datasource.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';

abstract class _CategoriasRepository {
  /// Obtiene la lista de categorías.
  /// @return Una lista de objetos Categoria.
  Future<List<Categoria>> fetchCategorias();

  /// Agrega una nueva categoría.
  /// @param categoria El objeto Categoria a agregar.
  /// @return Un valor booleano que indica si la operación fue exitosa.
  Future<bool> addCategoria(Categoria categoria);

  /// Actualiza una categoría existente.
  /// @param categoria El objeto Categoria con los datos actualizados.
  /// @return Un valor booleano que indica si la operación fue exitosa.
  Future<bool> updateCategoria(Categoria categoria);

  /// Elimina una categoría por su ID.
  /// @param id El ID de la categoría a eliminar.
  /// @return Un valor booleano que indica si la operación fue exitosa.
  Future<bool> deleteCategoria(String id);
}

class CategoriasRepository implements _CategoriasRepository {
  final CategoriasLocalDataSource localDataSource;

  CategoriasRepository(this.localDataSource);

  @override
  Future<List<Categoria>> fetchCategorias() async {
    return localDataSource.fetchCategorias();
  }

  @override
  Future<bool> addCategoria(Categoria categoria) async {
    return localDataSource.addCategoria(categoria);
  }

  @override
  Future<bool> updateCategoria(Categoria categoria) async {
    return localDataSource.updateCategoria(categoria);
  }

  @override
  Future<bool> deleteCategoria(String id) async {
    return localDataSource.deleteCategoria(id);
  }
}