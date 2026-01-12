import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/models/operation_result.dart';
import 'package:control_financiero/features/movimientos/data/movimentos_local_datasource.dart';
import 'package:control_financiero/features/movimientos/models/movimiento.dart';
import 'package:control_financiero/features/movimientos/models/totales_mensuales.dart';

abstract class _MovimientosRepository {
  ///Obtiene la lista de movimientos financieros.
  ///@return Una lista de objetos Movimiento.
  Future<List<Movimiento>> fetchMovimientosByMonthAndYear(DateTime date);

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

  /// Obtener totales mensuales (ingresos y gastos) para el mes pasado de una fecha dada
  /// @param date La fecha para la cual se desean los totales del mes pasado.
  /// @return Un objeto TotalesMensuales con los totales de ingresos y gastos del mes pasado.
  TotalesMensuales fetchTotalesMensualesMesPasado(DateTime date);

  /// Agrega un nuevo movimiento financiero.
  /// @param movimiento El objeto Movimiento a agregar.
  /// @return Un valor booleano que indica si la operación fue exitosa.
  Future<OperationResult<int>> addMovimiento(Movimiento movimiento);
  
  /// Actualiza un movimiento financiero existente.
  /// @param movimiento El objeto Movimiento con los datos actualizados.
  /// @return Un valor booleano que indica si la operación fue exitosa.
  Future<OperationResult<void>> updateMovimiento(Movimiento movimiento);
 
  /// Elimina un movimiento financiero por su ID.
  /// @param id El ID del movimiento a eliminar.
  /// @return Un valor booleano que indica si la operación fue exitosa.
  Future<OperationResult<void>> deleteMovimiento(int id);
}

class MovimientosRepository implements _MovimientosRepository {
  final MovimientosLocalDataSource localDataSource;
  final List<Movimiento> movimientos = [];

  // Para calculos de totales mensuales se conservara una lista de los movimientos del mes pasado
  final List<Movimiento> movimientosMesPasado = [];


  MovimientosRepository(this.localDataSource);

  @override
  Future<List<Movimiento>> fetchMovimientosByMonthAndYear(DateTime date) async {
    movimientos.clear();
    movimientosMesPasado.clear();

    // Obtener movimientos del mes actual
    movimientos.addAll(
      await localDataSource.fetchMovimientosByMonthAndYear(date)
    );

    // Obtener movimientos del mes pasado
    final mesPasado = DateTime(date.year, date.month - 1);
    movimientosMesPasado.addAll(
      await localDataSource.fetchMovimientosByMonthAndYear(mesPasado)
    );

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
      if (_isSameMonth(movimiento.date, date)) {
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
  TotalesMensuales fetchTotalesMensualesMesPasado(DateTime date) {
    double totalIngresos = 0.0;
    double totalGastos = 0.0;
    DateTime mesPasado = DateTime(date.year, date.month - 1);

    for (var movimiento in movimientosMesPasado) {
      if (_isSameMonth(movimiento.date, mesPasado)) {
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
  Future<OperationResult<int>> addMovimiento(Movimiento movimiento) async {
    final result = await localDataSource.addMovimiento(movimiento);
    if (result.success == true) {
      movimientos.add(movimiento.copyWith(id: result.data!));
    }
    return result;
  }

  @override
  Future<OperationResult<void>> updateMovimiento(Movimiento movimiento) async {
    final result = await localDataSource.updateMovimiento(movimiento);
    if (result.success == true) {
      final index = movimientos.indexWhere((m) => m.id == movimiento.id);
      if (index != -1) {
        movimientos[index] = movimiento;
      }
    }
    return result;
  }

  @override
  Future<OperationResult<void>> deleteMovimiento(int id) async {
    final result = await localDataSource.deleteMovimiento(id);
    if (result.success == true) {
      movimientos.removeWhere((m) => m.id == id);
    }
    return result;
  }

  // Metodos personalizados adicionales
  bool _isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }
}