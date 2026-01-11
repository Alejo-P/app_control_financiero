import 'package:control_financiero/features/tipo_categorias/data/tipo_categoria_local_datasource.dart';
import 'package:control_financiero/features/tipo_categorias/models/tipo_categoria.dart';

abstract class _TipoCategoriaRepository {
  /// Obtiene la lista de tipos de categorías.
  /// @return Una lista de objetos TipoCategoria.
  Future<List<TipoCategoria>> fetchTipoCategorias();

  /// Obtiene un tipo de categoría por su ID.
  /// @param id El ID del tipo de categoría.
  /// @return Un objeto TipoCategoria o null si no se encuentra.
  TipoCategoria? getTipoCategoriaById(int id);

  /// Agrega un nuevo tipo de categoría.
  /// @param tipoCategoria El objeto TipoCategoria a agregar.
  /// @return Un valor booleano que indica si la operación fue exitosa.
  Future<Map<String, dynamic>> addTipoCategoria(TipoCategoria tipoCategoria);

  /// Actualiza un tipo de categoría existente.
  /// @param tipoCategoria El objeto TipoCategoria con los datos actualizados.
  /// @return Un valor booleano que indica si la operación fue exitosa.
  Future<Map<String, dynamic>> updateTipoCategoria(TipoCategoria tipoCategoria);

  /// Elimina un tipo de categoría por su ID.
  /// @param id El ID del tipo de categoría a eliminar.
  /// @return Un valor booleano que indica si la operación fue exitosa.
  Future<Map<String, dynamic>> deleteTipoCategoria(int id);
}

class TipoCategoriaRepository implements _TipoCategoriaRepository {
  final TipoCategoriaLocalDataSource localDataSource;
  final List<TipoCategoria> tipoCategorias = [];

  TipoCategoriaRepository(this.localDataSource);

  @override
  Future<List<TipoCategoria>> fetchTipoCategorias() async {
    tipoCategorias.clear();
    tipoCategorias.addAll(await localDataSource.fetchTipoCategorias());
    return tipoCategorias;
  }

  @override
  TipoCategoria? getTipoCategoriaById(int id) {
    try {
      return tipoCategorias.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>> addTipoCategoria(TipoCategoria tipoCategoria) async {
    final success = await localDataSource.addTipoCategoria(tipoCategoria);
    if (success['success'] == true) {
      tipoCategorias.add(tipoCategoria);
    }
    return success;
  }

  @override
  Future<Map<String, dynamic>> updateTipoCategoria(TipoCategoria tipoCategoria) async {
    final success = await localDataSource.updateTipoCategoria(tipoCategoria);
    if (success['success'] == true) {
      final index = tipoCategorias.indexWhere((t) => t.id == tipoCategoria.id);
      if (index != -1) {
        tipoCategorias[index] = tipoCategoria;
      }
    }
    return success;
  }

  @override
  Future<Map<String, dynamic>> deleteTipoCategoria(int id) async {
    final success = await localDataSource.deleteTipoCategoria(id);
    if (success['success'] == true) {
      tipoCategorias.removeWhere((t) => t.id == id);
    }
    return success;
  }
}