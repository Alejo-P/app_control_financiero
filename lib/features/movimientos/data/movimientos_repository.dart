import 'package:control_financiero/core/models/operation_result.dart';
import 'package:control_financiero/core/utils/excel_exporter.dart';
import 'package:control_financiero/features/movimientos/data/movimientos_local_datasource.dart';
import 'package:control_financiero/features/movimientos/models/detalle_movimiento.dart';
import 'package:control_financiero/features/movimientos/models/movimiento.dart';
import 'package:control_financiero/features/movimientos/models/totales_mensuales.dart';

class MovimientosRepository {
  final MovimientosLocalDataSource localDataSource;

  MovimientosRepository(this.localDataSource);

  ///Obtiene la lista de todos los movimientos.
  ///@return Una lista de objetos Movimiento.
  Future<List<Movimiento>> fetchAllMovimientos() async {
    return await localDataSource.fetchAllMovimientos();
  }

  ///Obtiene la lista de todos los movimientos.
  ///@return Una lista de objetos Movimiento.
  Future<List<DetalleMovimiento>> fetchAllDetalleMovimiento() async {
    return await localDataSource.fetchAllDetalleMovimiento();
  }

  ///Obtiene la lista de movimientos por mes.
  ///@return Una lista de objetos Movimiento.
  Future<List<DetalleMovimiento>> fetchMovimientosByMonthAndYear(
    DateTime date,
  ) async {
    return await localDataSource.fetchMovimientosByMonthAndYear(date);
  }

  ///Obtiene un movimiento por su id.
  ///@return El objeto Movimiento.
  Future<Movimiento?> fetchMovimientoById(int id) async {
    return await localDataSource.fetchMovimientoById(id);
  }

  /// Obtener cantidad de movimientos por una categoría especifica
  /// @param categoryId El ID de la categoría.
  /// @return La cantidad de movimientos asociados a la categoría.
  Future<int> fetchMovimientoCountByCategory(int categoryId) async {
    final cantidadMovimientos = await localDataSource
        .fetchMovimientoCountByCategory(categoryId);
    return cantidadMovimientos;
  }

  /// Obtener movimientos por fecha
  /// @param date La fecha para filtrar los movimientos.
  /// @return Una lista de objetos Movimiento.
  Future<List<Movimiento>> fetchMovimientosByDate(DateTime date) async {
    return await localDataSource.fetchMovimientosByDate(date);
  }

  ///Obtiene un movimiento por su id.
  ///@return Objeto DetalleMovimiento con informacion del movimiento obtenido.
  Future<DetalleMovimiento?> fetchDetalleMovimientoById(int id) async {
    return await localDataSource.fetchDetalleMovimientoById(id);
  }

  /// Obtener totales mensuales (ingresos y gastos) para una fecha dada
  /// @param date La fecha para la cual se desean los totales.
  /// @return Un objeto TotalesMensuales con los totales de ingresos y gastos.
  Future<TotalesMensuales> fetchTotalesMensuales(DateTime date) async {
    final totalesMensuales = await localDataSource.fetchTotalesMensuales(date);

    return totalesMensuales;
  }

  /// Obtener el conteo de movimientos por cada categoría existente
  /// @return Un mapa con el ID de la categoría como clave y la cantidad de movimientos como valor.
  Future<Map<int, int>> getMovementsCountByCategory() async {
    return await localDataSource.getMovementsCountByCategory();
  }

  /// Obtener todos los movimientos asociados a una categoria
  /// @parram categoryID El ID de la categoria a obtener los movimientos
  /// @return Una lista de objetos Movimiento.
  Future<List<DetalleMovimiento>> getMovementsByCategoryID(
    int categoryID,
  ) async {
    return await localDataSource.getMovementsByCategoryID(categoryID);
  }

  /// Agrega un nuevo movimiento financiero.
  /// @param movimiento El objeto Movimiento a agregar.
  /// @return Un valor booleano que indica si la operación fue exitosa.
  Future<OperationResult<int>> addMovimiento(Movimiento movimiento) async {
    final result = await localDataSource.addMovimiento(movimiento);
    return result;
  }

  /// Actualiza un movimiento financiero existente.
  /// @param movimiento El objeto Movimiento con los datos actualizados.
  /// @return Un valor booleano que indica si la operación fue exitosa.
  Future<OperationResult<DetalleMovimiento?>> updateMovimiento(
    Movimiento movimiento,
  ) async {
    final result = await localDataSource.updateMovimiento(movimiento);

    return OperationResult<DetalleMovimiento?>(
      message: result.message,
      success: result.success,
      data: result.success
          ? await localDataSource.fetchDetalleMovimientoById(movimiento.id!)
          : null,
    );
  }

  /// Elimina un movimiento financiero por su ID.
  /// @param id El ID del movimiento a eliminar.
  /// @return Un objeto OperationResult que contiene el id del movimiento eliminado si la operación fue exitosa, de lo contrario null.
  Future<OperationResult<int>> deleteMovimiento(int id) async {
    final result = await localDataSource.deleteMovimiento(id);
    return OperationResult<int>(
      message: result.message,
      success: result.success,
      data: result.success ? id : -1,
    );
  }

  /// Obtiene la informacion necesaria sobre los movimeintos
  /// para incluirlos en el archivo final
  Future<OperationResult> exportarMovimientosExcel() async {
    final data = await localDataSource.getMovimientosForExcel();
    return await ExcelExporter.exportarExcel(data);
  }
}
