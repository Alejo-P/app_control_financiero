import 'package:control_financiero/core/models/operation_result.dart';
import 'package:control_financiero/features/categorias/data/categorias_local_datasource.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';

abstract class _CategoriasRepository {
  /// Obtiene la lista de categorías.
  /// @return Una lista de objetos Categoria.
  Future<List<Categoria>> fetchCategorias();

  /// Agrega una nueva categoría.
  /// @param categoria El objeto Categoria a agregar.
  /// @return Un valor booleano que indica si la operación fue exitosa.
  Future<OperationResult<int>> addCategoria(Categoria categoria);

  /// Actualiza una categoría existente.
  /// @param categoria El objeto Categoria con los datos actualizados.
  /// @return Un valor booleano que indica si la operación fue exitosa.
  Future<OperationResult<void>> updateCategoria(Categoria categoria);

  /// Elimina una categoría por su ID.
  /// @param id El ID de la categoría a eliminar.
  /// @return Un valor booleano que indica si la operación fue exitosa.
  Future<OperationResult<void>> deleteCategoria(int id);
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
  Future<OperationResult<int>> addCategoria(Categoria categoria) async {
    final result = await localDataSource.addCategoria(categoria);
    if (result.success == true) {
      categorias.add(categoria.copyWith(id: result.data!));
    }
    return result;
  }

  @override
  Future<OperationResult<void>> updateCategoria(Categoria categoria) async {
    final result = await localDataSource.updateCategoria(categoria);
    if (result.success == true) {
      final index = categorias.indexWhere((c) => c.id == categoria.id);
      if (index != -1) {
        categorias[index] = categoria;
      }
    }
    return result;
  }

  @override
  Future<OperationResult<void>> deleteCategoria(int id) async {
    final result = await localDataSource.deleteCategoria(id);
    if (result.success == true) {
      categorias.removeWhere((c) => c.id == id);
    }
    return result;
  }
}