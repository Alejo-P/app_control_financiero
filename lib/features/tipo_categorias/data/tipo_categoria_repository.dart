import 'package:control_financiero/features/tipo_categorias/data/tipo_categoria_local_datasource.dart';
import 'package:control_financiero/features/tipo_categorias/models/tipo_categoria.dart';

abstract class _TipoCategoriaRepository {
  /// Obtiene la lista de tipos de categorías.
  /// @return Una lista de objetos TipoCategoria.
  Future<List<TipoCategoria>> fetchTipoCategorias();

  /// Agrega un nuevo tipo de categoría.
  /// @param tipoCategoria El objeto TipoCategoria a agregar.
  /// @return Un valor booleano que indica si la operación fue exitosa.
  Future<bool> addTipoCategoria(TipoCategoria tipoCategoria);

  /// Actualiza un tipo de categoría existente.
  /// @param tipoCategoria El objeto TipoCategoria con los datos actualizados.
  /// @return Un valor booleano que indica si la operación fue exitosa.
  Future<bool> updateTipoCategoria(TipoCategoria tipoCategoria);

  /// Elimina un tipo de categoría por su ID.
  /// @param id El ID del tipo de categoría a eliminar.
  /// @return Un valor booleano que indica si la operación fue exitosa.
  Future<bool> deleteTipoCategoria(String id);
}

class TipoCategoriaRepository implements _TipoCategoriaRepository {
  final TipoCategoriaLocalDataSource localDataSource;

  TipoCategoriaRepository(this.localDataSource);

  @override
  Future<List<TipoCategoria>> fetchTipoCategorias() async {
    return localDataSource.fetchTipoCategorias();
  }

  @override
  Future<bool> addTipoCategoria(TipoCategoria tipoCategoria) async {
    return localDataSource.addTipoCategoria(tipoCategoria);
  }

  @override
  Future<bool> updateTipoCategoria(TipoCategoria tipoCategoria) async {
    return localDataSource.updateTipoCategoria(tipoCategoria);
  }

  @override
  Future<bool> deleteTipoCategoria(String id) async {
    return localDataSource.deleteTipoCategoria(id);
  }
}