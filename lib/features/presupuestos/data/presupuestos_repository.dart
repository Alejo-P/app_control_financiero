import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/models/operation_result.dart';
import 'package:control_financiero/features/movimientos/data/movimientos_local_datasource.dart';
import 'package:control_financiero/features/movimientos/models/detalle_movimiento.dart';
import 'package:control_financiero/features/presupuestos/data/presupuestos_local_datasource.dart';
import 'package:control_financiero/features/presupuestos/models/category_card_info.dart';
import 'package:control_financiero/features/presupuestos/models/detalle_presupuesto.dart';
import 'package:control_financiero/features/presupuestos/models/ingreso_presupuestado.dart';
import 'package:control_financiero/features/presupuestos/models/presupuesto.dart';

class PresupuestosRepository {
  Future<Presupuesto?> fetchPresupuestoByCategoryAndMonth(
    int categoryId,
    DateTime date,
  ) => localDataSource.fetchPresupuestoByCategoryAndMonth(categoryId, date);

  Future<OperationResult<int>> transferPresupuesto(
    int id,
    DateTime date, {
    required bool move,
    Presupuesto? replacement,
  }) => localDataSource.transferPresupuesto(
    id,
    date,
    move: move,
    replacement: replacement,
  );

  final PresupuestosLocalDataSource localDataSource;
  final MovimientosLocalDataSource movimientosLocalDataSource =
      MovimientosLocalDataSource();

  PresupuestosRepository(this.localDataSource);

  /// Obtiene el ingreso presupuestado para un mes y año específicos.
  /// @param date La fecha que contiene el mes y año deseados.
  /// @return El objeto IngresoPresupuestado correspondiente.
  Future<IngresoPresupuestado> fetchIngresosPresupuestadosByMonthAndYear(
    DateTime date,
  ) async {
    return await localDataSource.fetchIngresosPresupuestadosByMonthAndYear(
      date,
    );
  }

  Future<List<Presupuesto>> fetchAllPresupuestos() async {
    return await localDataSource.fetchAllPresupuestos();
  }

  Future<Presupuesto?> fetchPresupuestoById(int id) async {
    return await localDataSource.fetchPresupuestoById(id);
  }

  Future<DetallePresupuesto?> fetchDetallePresupuestoById(int id) async {
    return await localDataSource.fetchDetallePresupuestoById(id);
  }

  Future<List<CategoryCardInfo>> fetchCategoryCardInfoByMonthAndYear(
    DateTime date,
  ) async {
    return await localDataSource.fetchCategoryCardInfoByMonthAndYear(date);
  }

  Future<double> fetchPresupuestosAmountSumByMonthAndYear(DateTime date) async {
    return await localDataSource.fetchPresupuestosAmountSumByMonthAndYear(date);
  }

  Future<List<IngresoPresupuestado>> fetchAllIngresosPresupuestados() async {
    return await localDataSource.fetchAllIngresosPresupuestados();
  }

  /// Agrega o actualiza un ingreso presupuestado.
  /// @param ingreso El objeto IngresoPresupuestado a agregar o actualizar.
  /// @return Un OperationResult que indica el resultado de la operación y el ID del ingreso presupuestado si fue exitoso.
  Future<OperationResult<int>> upsertIngresoPresupuestado(
    IngresoPresupuestado ingreso,
  ) async {
    return await localDataSource.upsertIngresoPresupuestado(ingreso);
  }

  ///Obtiene la lista de presupuestos.
  ///@return Una lista de objetos Presupuesto.
  Future<List<Presupuesto>> fetchPresupuestosByMonthAndYear(
    DateTime date,
  ) async {
    // Obtener presupuestos del mes seleccionado
    return await localDataSource.fetchPresupuestosByMonthAndYear(date);
  }

  Future<List<DetalleMovimiento>> fetchGastosByMonthAndYear(
    DateTime date,
  ) async {
    final listaMovimeintos = await movimientosLocalDataSource
        .fetchMovimientosByMonthAndYear(date);

    return listaMovimeintos
        .where((m) => m.movementType == TipoMovimiento.gasto)
        .toList();
  }

  Future<double> fetchPresupuestoUtilizadoPercentageByCategoryAndMonth(
    int categoryId,
    DateTime date,
  ) async {
    return await localDataSource
        .fetchPresupuestoUtilizadoPercentageByCategoryAndMonth(
          categoryId,
          date,
        );
  }

  /// Agrega un nuevo presupuesto.
  /// @param presupuesto El objeto Presupuesto a agregar.
  /// @return Un OperationResult que indica el resultado de la operación.
  Future<OperationResult<CategoryCardInfo?>> addPresupuesto(
    Presupuesto presupuesto,
  ) async {
    final result = await localDataSource.addPresupuesto(presupuesto);

    return OperationResult<CategoryCardInfo?>(
      message: result.message,
      success: result.success,
      data: result.success
          ? await localDataSource.getCategoryCardInfoByBudgetId(
              result.data as int,
            )
          : null,
    );
  }

  /// Actualiza un presupuesto existente.
  /// @param presupuesto El objeto Presupuesto con los datos actualizados.
  /// @return Un OperationResult que indica el resultado de la operación.
  Future<OperationResult<CategoryCardInfo?>> updatePresupuesto(
    Presupuesto presupuesto,
  ) async {
    final result = await localDataSource.updatePresupuesto(presupuesto);
    return OperationResult<CategoryCardInfo?>(
      message: result.message,
      success: result.success,
      data: result.success && presupuesto.id != null
          ? await localDataSource.getCategoryCardInfoByBudgetId(
              presupuesto.id!
            )
          : null,
    );
  }

  /// Elimina un presupuesto por su ID.
  /// @param id El ID del presupuesto a eliminar.
  /// @return Un OperationResult que indica el resultado de la operación.
  Future<OperationResult<int?>> deletePresupuesto(int id) async {
    final result = await localDataSource.deletePresupuesto(id);
    return OperationResult<int?>(
      message: result.message,
      success: result.success,
      data: result.success ? id : null,
    );
  }
}
