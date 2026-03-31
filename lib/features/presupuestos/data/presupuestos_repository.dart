import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/models/operation_result.dart';
import 'package:control_financiero/features/categorias/data/categorias_local_datasource.dart';
import 'package:control_financiero/features/movimientos/data/movimientos_local_datasource.dart';
import 'package:control_financiero/features/movimientos/models/movimiento.dart';
import 'package:control_financiero/features/presupuestos/data/presupuestos_local_datasource.dart';
import 'package:control_financiero/features/presupuestos/models/ingreso_presupuestado.dart';
import 'package:control_financiero/features/presupuestos/models/presupuesto.dart';

abstract class _PresupuestosRepository {
  /// Obtiene el ingreso presupuestado para un mes y año específicos.
  /// @param date La fecha que contiene el mes y año deseados.
  /// @return El objeto IngresoPresupuestado correspondiente.
  Future<IngresoPresupuestado> fetchIngresosPresupuestadosByMonthAndYear(
    DateTime date,
  );

  /// Agrega o actualiza un ingreso presupuestado.
  /// @param ingreso El objeto IngresoPresupuestado a agregar o actualizar.
  /// @return Un OperationResult que indica el resultado de la operación y el ID del ingreso presupuestado si fue exitoso.
  Future<OperationResult<int>> upsertIngresoPresupuestado(
    IngresoPresupuestado ingreso,
  );

  ///Obtiene la lista de presupuestos.
  ///@return Una lista de objetos Presupuesto.
  Future<List<Presupuesto>> fetchPresupuestosByMonthAndYear(DateTime date);

  /// Obtiene el total de gastos en el mes
  /// @param date La fecha para filtrar los movimientos.
  /// @return El total de gastos del mes.
  double getTotalGastosByMonthAndYear(DateTime date);

  /// Agrega un nuevo presupuesto.
  /// @param presupuesto El objeto Presupuesto a agregar.
  /// @return Un OperationResult que indica el resultado de la operación y el ID del nuevo presupuesto si fue exitoso.
  Future<OperationResult<int>> addPresupuesto(Presupuesto presupuesto);

  /// Actualiza un presupuesto existente.
  /// @param presupuesto El objeto Presupuesto con los datos actualizados.
  /// @return Un OperationResult que indica el resultado de la operación.
  Future<OperationResult<void>> updatePresupuesto(Presupuesto presupuesto);

  /// Elimina un presupuesto por su ID.
  /// @param id El ID del presupuesto a eliminar.
  /// @return Un OperationResult que indica el resultado de la operación.
  Future<OperationResult<void>> deletePresupuesto(int id);
}

class PresupuestosRepository implements _PresupuestosRepository {
  final PresupuestosLocalDataSource localDatasource;
  final MovimientosLocalDataSource movimientosLocalDataSource =
      MovimientosLocalDataSource();
  final CategoriasLocalDataSource categoriasLocalDataSource =
      CategoriasLocalDataSource();
  final List<Presupuesto> presupuestos = [];

  // Lista para almacenar los moovimientos segun el mes del presupuesto
  final List<Movimiento> movimientos = [];

  PresupuestosRepository(this.localDatasource);

  @override
  Future<IngresoPresupuestado> fetchIngresosPresupuestadosByMonthAndYear(
    DateTime date,
  ) async {
    return await localDatasource.fetchIngresosPresupuestadosByMonthAndYear(
      date,
    );
  }

  @override
  Future<OperationResult<int>> upsertIngresoPresupuestado(
    IngresoPresupuestado ingreso,
  ) async {
    return await localDatasource.upsertIngresoPresupuestado(ingreso);
  }

  @override
  Future<List<Presupuesto>> fetchPresupuestosByMonthAndYear(
    DateTime date,
  ) async {
    presupuestos.clear();
    movimientos.clear();
    final listaMovimeintos = await movimientosLocalDataSource
        .fetchMovimientosByMonthAndYear(date);

    // Filtar solo los movimientos de tipo gasto
    for (var movimiento in listaMovimeintos) {
      final categoria = await categoriasLocalDataSource.fetchCategoriaById(
        movimiento.categoryID,
      );
      if (categoria != null && categoria.movementType == TipoMovimiento.gasto) {
        movimientos.add(movimiento);
      }
    }

    // Obtener presupuestos del mes seleccionado
    presupuestos.addAll(
      await localDatasource.fetchPresupuestosByMonthAndYear(date),
    );

    return presupuestos;
  }

  @override
  double getTotalGastosByMonthAndYear(DateTime date) {
    final resultado = movimientos.fold<double>(
      0.0,
      (sum, movimiento) => sum + movimiento.amount,
    );
    return resultado;
  }

  Future<double> fetchPresupuestoUtilizadoPercentageByCategoryAndMonth(int categoryId, DateTime date) async {
    return await localDatasource.fetchPresupuestoUtilizadoPercentageByCategoryAndMonth(
      categoryId,
      date,
    );
  }

  @override
  Future<OperationResult<int>> addPresupuesto(Presupuesto presupuesto) async {
    final result = await localDatasource.addPresupuesto(presupuesto);
    if (result.success && result.data != null) {
      presupuestos.add(presupuesto.copyWith(id: result.data!));
    }
    return result;
  }

  @override
  Future<OperationResult<void>> updatePresupuesto(
    Presupuesto presupuesto,
  ) async {
    final result = await localDatasource.updatePresupuesto(presupuesto);
    if (result.success) {
      final index = presupuestos.indexWhere((p) => p.id == presupuesto.id);
      if (index != -1) {
        presupuestos[index] = presupuesto;
      }
    }
    return result;
  }

  @override
  Future<OperationResult<void>> deletePresupuesto(int id) async {
    final result = await localDatasource.deletePresupuesto(id);
    if (result.success) {
      presupuestos.removeWhere((p) => p.id == id);
    }
    return result;
  }
}
