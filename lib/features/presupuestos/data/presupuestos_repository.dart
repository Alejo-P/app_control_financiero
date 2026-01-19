import 'package:control_financiero/core/models/operation_result.dart';
import 'package:control_financiero/features/presupuestos/data/presupuestos_local_datasource.dart';
import 'package:control_financiero/features/presupuestos/models/presupuesto.dart';

abstract class _PresupuestosRepository {
  ///Obtiene la lista de presupuestos.
  ///@return Una lista de objetos Presupuesto.
  Future<List<Presupuesto>> fetchPresupuestosByMonthAndYear(DateTime date);

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
  final List<Presupuesto> presupuestos = [];

  PresupuestosRepository(this.localDatasource);

  @override
  Future<List<Presupuesto>> fetchPresupuestosByMonthAndYear(DateTime date) async {
    // Aquí podrías agregar lógica adicional si es necesario
    return await localDatasource.fetchPresupuestosByMonthAndYear(
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
