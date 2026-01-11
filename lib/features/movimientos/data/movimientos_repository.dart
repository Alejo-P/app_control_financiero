import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/features/movimientos/data/movimentos_local_datasource.dart';
import 'package:control_financiero/features/movimientos/models/movimiento.dart';
import 'package:control_financiero/features/movimientos/models/totales_mensuales.dart';

abstract class _MovimientosRepository {
  ///Obtiene la lista de movimientos financieros.
  ///@return Una lista de objetos Movimiento.
  Future<List<Movimiento>> fetchMovimientos();

  /// Obtener movimientos por categoría
  /// @param categoryId El ID de la categoría.
  /// @return Una lista de objetos Movimiento.
  List<Movimiento> fetchMovimientosByCategory(String categoryId);

  /// Obtener movimientos por fecha
  /// @param date La fecha para filtrar los movimientos.
  /// @return Una lista de objetos Movimiento.
  List<Movimiento> fetchMovimientosByDate(DateTime date);

  /// Obtener movimientos por fecha y tipo
  /// @param date La fecha para filtrar los movimientos.
  /// @param type El tipo de movimiento (ingreso o gasto).
  /// @return Una lista de objetos Movimiento.
  List<Movimiento> fetchMovimientosByDateAndType(
    DateTime date,
    TipoMovimiento type
  );

  /// Obtener totales mensuales (ingresos y gastos) para una fecha dada
  /// @param date La fecha para la cual se desean los totales.
  /// @return Un objeto TotalesMensuales con los totales de ingresos y gastos.
  TotalesMensuales fetchTotalesMensuales(DateTime date);

  /// Agrega un nuevo movimiento financiero.
  /// @param movimiento El objeto Movimiento a agregar.
  /// @return Un valor booleano que indica si la operación fue exitosa.
  Future<Map<String, dynamic>> addMovimiento(Movimiento movimiento);
  
  /// Actualiza un movimiento financiero existente.
  /// @param movimiento El objeto Movimiento con los datos actualizados.
  /// @return Un valor booleano que indica si la operación fue exitosa.
  Future<Map<String, dynamic>> updateMovimiento(Movimiento movimiento);
 
  /// Elimina un movimiento financiero por su ID.
  /// @param id El ID del movimiento a eliminar.
  /// @return Un valor booleano que indica si la operación fue exitosa.
  Future<Map<String, dynamic>> deleteMovimiento(int id);
}

class MovimientosRepository implements _MovimientosRepository {
  final MovimientosLocalDataSource localDataSource;
  final List<Movimiento> movimientos = [];

  MovimientosRepository(this.localDataSource);

  @override
  Future<List<Movimiento>> fetchMovimientos() async {
    movimientos.clear();
    movimientos.addAll(await localDataSource.fetchMovimientos());
    return movimientos;
  }

  @override
  List<Movimiento> fetchMovimientosByCategory(String categoryId) {
    final filteredMovements = movimientos.where(
      (m) => m.categoryID.toString() == categoryId
    ).toList();
    return filteredMovements;
  }

  @override
  List<Movimiento> fetchMovimientosByDate(DateTime date) {
    return movimientos.where((m) =>
      m.date.year == date.year &&
      m.date.month == date.month &&
      m.date.day == date.day
    ).toList();
  }

  @override
  List<Movimiento> fetchMovimientosByDateAndType(
    DateTime date,
    TipoMovimiento type
  ) {
    return movimientos.where((m) =>
      m.date.year == date.year &&
      m.date.month == date.month &&
      m.date.day == date.day &&
      m.type == type
    ).toList();
  }

  @override
  TotalesMensuales fetchTotalesMensuales(DateTime date) {
    double totalIngresos = 0.0;
    double totalGastos = 0.0;

    for (var movimiento in movimientos) {
      if (movimiento.date.year == date.year &&
          movimiento.date.month == date.month) {
        if (movimiento.type == TipoMovimiento.ingreso) {
          totalIngresos += movimiento.ammount;
        } else if (movimiento.type == TipoMovimiento.gasto) {
          totalGastos += movimiento.ammount;
        }
      }
    }

    return TotalesMensuales(
      ingresos: totalIngresos,
      gastos: totalGastos,
    );
  }

  @override
  Future<Map<String, dynamic>> addMovimiento(Movimiento movimiento) async {
    final success = await localDataSource.addMovimiento(movimiento);
    if (success['success'] == true) {
      movimientos.add(movimiento);
    }
    return success;
  }

  @override
  Future<Map<String, dynamic>> updateMovimiento(Movimiento movimiento) async {
    final success = await localDataSource.updateMovimiento(movimiento);
    if (success['success'] == true) {
      final index = movimientos.indexWhere((m) => m.id == movimiento.id);
      if (index != -1) {
        movimientos[index] = movimiento;
      }
    }
    return success;
  }

  @override
  Future<Map<String, dynamic>> deleteMovimiento(int id) async {
    final success = await localDataSource.deleteMovimiento(id);
    if (success['success'] == true) {
      movimientos.removeWhere((m) => m.id == id);
    }
    return success;
  }
}