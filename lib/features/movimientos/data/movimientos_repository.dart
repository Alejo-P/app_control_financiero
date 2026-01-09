import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/features/movimientos/data/movimentos_local_datasource.dart';
import 'package:control_financiero/features/movimientos/models/movimiento.dart';

abstract class _MovimientosRepository {
  ///Obtiene la lista de movimientos financieros.
  ///@return Una lista de objetos Movimiento.
  Future<List<Movimiento>> fetchMovimientos();

  /// Obtener movimientos por categoría
  /// @param categoryId El ID de la categoría.
  /// @return Una lista de objetos Movimiento.
  Future<List<Movimiento>> fetchMovimientosByCategory(String categoryId);

  /// Obtener movimientos por fecha
  /// @param date La fecha para filtrar los movimientos.
  /// @return Una lista de objetos Movimiento.
  Future<List<Movimiento>> fetchMovimientosByDate(DateTime date);

  /// Obtener movimientos por fecha y tipo
  /// @param date La fecha para filtrar los movimientos.
  /// @param type El tipo de movimiento (ingreso o gasto).
  /// @return Una lista de objetos Movimiento.
  Future<List<Movimiento>> fetchMovimientosByDateAndType(
    DateTime date,
    TipoMovimiento type
  );

  /// Agrega un nuevo movimiento financiero.
  /// @param movimiento El objeto Movimiento a agregar.
  /// @return Un valor booleano que indica si la operación fue exitosa.
  Future<bool> addMovimiento(Movimiento movimiento);
  
  /// Actualiza un movimiento financiero existente.
  /// @param movimiento El objeto Movimiento con los datos actualizados.
  /// @return Un valor booleano que indica si la operación fue exitosa.
  Future<bool> updateMovimiento(Movimiento movimiento);
 
  /// Elimina un movimiento financiero por su ID.
  /// @param id El ID del movimiento a eliminar.
  /// @return Un valor booleano que indica si la operación fue exitosa.
  Future<bool> deleteMovimiento(String id);
}

class MovimientosRepository implements _MovimientosRepository {
  final MovimientosLocalDataSource localDataSource;

  MovimientosRepository(this.localDataSource);

  @override
  Future<List<Movimiento>> fetchMovimientos() async {
    return localDataSource.fetchMovimientos();
  }

  @override
  Future<List<Movimiento>> fetchMovimientosByCategory(String categoryId) async {
    return localDataSource.fetchMovimientosByCategory(categoryId);
  }

  @override
  Future<List<Movimiento>> fetchMovimientosByDate(DateTime date) async {
    return localDataSource.fetchMovimientosByDate(date);
  }

  @override
  Future<List<Movimiento>> fetchMovimientosByDateAndType(
    DateTime date,
    TipoMovimiento type
  ) async {
    return localDataSource.fetchMovimientosByDateAndType(date, type);
  }

  @override
  Future<bool> addMovimiento(Movimiento movimiento) async {
    return localDataSource.addMovimiento(movimiento);
  }

  @override
  Future<bool> updateMovimiento(Movimiento movimiento) async {
    return localDataSource.updateMovimiento(movimiento);
  }

  @override
  Future<bool> deleteMovimiento(String id) async {
    return localDataSource.deleteMovimiento(id);
  }
}
