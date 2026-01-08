import 'package:control_financiero/features/movimientos/data/movimentos_local_datasource.dart';
import 'package:control_financiero/features/movimientos/models/movimiento.dart';

abstract class MovimientosRepository {
  ///Obtiene la lista de movimientos financieros.
  ///@return Una lista de objetos Movimiento.
  Future<List<Movimiento>> fetchMovimientos();

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

class MovimientosLocalRepository implements MovimientosRepository {
  final MovimientosLocalDataSource _dataSource;

  MovimientosLocalRepository(this._dataSource);

  @override
  Future<List<Movimiento>> fetchMovimientos() async {
    // Simula una llamada a una base de datos local o almacenamiento.
    return _dataSource.fetchMovimientos();
  }

  @override
  Future<bool> addMovimiento(Movimiento movimiento) async {
    return _dataSource.addMovimiento(movimiento);
  }

  @override
  Future<bool> updateMovimiento(Movimiento movimiento) async {
    return _dataSource.updateMovimiento(movimiento);
  }

  @override
  Future<bool> deleteMovimiento(String id) async {
    return _dataSource.deleteMovimiento(id);
  }
}
