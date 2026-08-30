import 'package:control_financiero/core/models/operation_result.dart';
import 'package:control_financiero/features/categorias/data/categorias_local_datasource.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';
import 'package:control_financiero/features/categorias/models/detalle_categoria.dart';

class CategoriasRepository {
  final CategoriasLocalDataSource localDataSource;

  CategoriasRepository(this.localDataSource);

  /// Obtiene la lista de categorías.
  /// @return Una lista de objetos Categoria.
  Future<List<Categoria>> fetchAllCategorias() async {
    return await localDataSource.fetchAllCategorias();
  }

  /// Obtiene la lista de categorías no predeterminadas.
  /// @return Una lista de objetos Categoria.
  Future<List<Categoria>> fetchAllNoDefaultCategorias() async {
    final categorias = await localDataSource.fetchAllNoDefaultCategorias();
    return categorias;
  }

  /// Obtiene una categoría por su id.
  /// @return Un objeto DetalleCategoria con informacion de la categoria obtenida.
  Future<DetalleCategoria?> fetchDetalleCategoriaById(int id) async {
    return await localDataSource.fetchDetalleCategoriaById(id);
  }

  /// Agrega una nueva categoría.
  /// @param categoria El objeto Categoria a agregar.
  /// @return Un valor booleano que indica si la operación fue exitosa.
  Future<OperationResult<int>> addCategoria(Categoria categoria) async {
    final result = await localDataSource.addCategoria(categoria);
    return result;
  }

  /// Actualiza una categoría existente.
  /// @param categoria El objeto Categoria con los datos actualizados.
  /// @return Un valor booleano que indica si la operación fue exitosa.
  Future<OperationResult<Categoria?>> updateCategoria(
    Categoria categoria,
  ) async {
    final result = await localDataSource.updateCategoria(categoria);
    return OperationResult<Categoria?>(
      message: result.message,
      success: result.success,
      data: result.success && categoria.id != null
          ? await localDataSource.fetchCategoriaById(categoria.id!)
          : null,
    );
  }

  /// Elimina una categoría por su ID.
  /// @param id El ID de la categoría a eliminar.
  /// @return Un valor booleano que indica si la operación fue exitosa.
  Future<OperationResult<int?>> deleteCategoria(int id) async {
    final result = await localDataSource.deleteCategoria(id);
    return OperationResult<int?>(
      message: result.message,
      success: result.success,
      data: result.success ? id : null,
    );
  }
}
