import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/models/operation_result.dart';
import 'package:control_financiero/core/utils/app_logger.dart';
import 'package:control_financiero/features/categorias/data/categorias_local_datasource.dart';
import 'package:control_financiero/features/movimientos/data/movimientos_local_datasource.dart';
import 'package:control_financiero/features/movimientos/models/movimiento.dart';
import 'package:control_financiero/features/movimientos/models/totales_mensuales.dart';

abstract class _MovimientosRepository {
  ///Obtiene la lista de movimientos financieros.
  ///@return Una lista de objetos Movimiento.
  Future<List<Movimiento>> fetchMovimientosByMonthAndYear(DateTime date);

  /// Obtener cantidad de movimientos por categoría
  /// @param categoryId El ID de la categoría.
  /// @return La cantidad de movimientos asociados a la categoría.
  Future<int> fetchMovimientoCountByCategory(int categoryId);

  /// Obtener movimientos por categoría y mes
  /// @param categoryId El ID de la categoría.
  /// @param date La fecha para filtrar los movimientos.
  /// @return Una lista de objetos Movimiento.
  List<Movimiento> fetchMovimientosByCategoryAndMonth(
    int categoryId,
    DateTime date,
  );

  /// Obtener movimientos por fecha
  /// @param date La fecha para filtrar los movimientos.
  /// @return Una lista de objetos Movimiento.
  List<Movimiento> fetchMovimientosByDate(DateTime date);

  /// Obtener totales mensuales (ingresos y gastos) para una fecha dada
  /// @param date La fecha para la cual se desean los totales.
  /// @return Un objeto TotalesMensuales con los totales de ingresos y gastos.
  Future<TotalesMensuales> fetchTotalesMensuales(DateTime date);

  /// Obtener totales mensuales (ingresos y gastos) para el mes pasado de una fecha dada
  /// @param date La fecha para la cual se desean los totales del mes pasado.
  /// @return Un objeto TotalesMensuales con los totales de ingresos y gastos del mes pasado.
  Future<TotalesMensuales> fetchTotalesMensualesMesPasado(DateTime date);

  /// Obtener el conteo de movimientos por categoría
  /// @return Un mapa con el ID de la categoría como clave y la cantidad de movimientos como valor.
  Future<Map<int, int>> getMovementsCountByCategory();
  
  /// Obtener todos los movimientos asociados a una categoria
  /// @parram categoryID El ID de la categoria a obtener los movimientos
  /// @return Una lista de objetos Movimiento.
  Future<List<Movimiento>> getMovementsByCategoryID(int categoryID);

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
  final CategoriasLocalDataSource _categoriasLocalDataSource =
      CategoriasLocalDataSource();
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
      await localDataSource.fetchMovimientosByMonthAndYear(date),
    );

    // Obtener movimientos del mes pasado
    final mesPasado = DateTime(date.year, date.month - 1);
    movimientosMesPasado.addAll(
      await localDataSource.fetchMovimientosByMonthAndYear(mesPasado),
    );

    return movimientos;
  }

  @override
  Future<int> fetchMovimientoCountByCategory(int categoryId) async {
    final cantidadMovimientos = await localDataSource
        .fetchMovimientoCountByCategory(categoryId);
    return cantidadMovimientos;
  }

  @override
  List<Movimiento> fetchMovimientosByCategoryAndMonth(
    int categoryId,
    DateTime date,
  ) {
    final filteredMovements = movimientos
        .where((m) => m.categoryID == categoryId && _isSameMonth(m.date, date))
        .toList();
    return filteredMovements;
  }

  @override
  List<Movimiento> fetchMovimientosByDate(DateTime date) {
    return movimientos
        .where(
          (m) =>
              m.date.year == date.year &&
              m.date.month == date.month &&
              m.date.day == date.day,
        )
        .toList();
  }

  @override
  Future<TotalesMensuales> fetchTotalesMensuales(DateTime date) async {
    double totalIngresos = 0.0;
    double totalGastos = 0.0;

    try {
      for (var movimiento in movimientos) {
        if (_isSameMonth(movimiento.date, date)) {
          // Aquí se asume que los ingresos son positivos y los gastos negativos
          final categoria = await _categoriasLocalDataSource.fetchCategoriaById(
            movimiento.categoryID,
          );
          if (categoria != null) {
            if (categoria.movementType == TipoMovimiento.ingreso) {
              totalIngresos += movimiento.amount;
            } else if (categoria.movementType == TipoMovimiento.gasto) {
              totalGastos += movimiento.amount;
            }
          }
        }
      }
    } on Exception catch (e) {
      AppLogger.log(
        'Error al calcular totales mensuales: $e',
        level: LogLevel.error,
      );
    }

    return TotalesMensuales(ingresos: totalIngresos, gastos: totalGastos);
  }

  @override
  Future<TotalesMensuales> fetchTotalesMensualesMesPasado(DateTime date) async {
    double totalIngresos = 0.0;
    double totalGastos = 0.0;
    DateTime mesPasado = DateTime(date.year, date.month - 1);

    try {
      for (var movimiento in movimientosMesPasado) {
        if (_isSameMonth(movimiento.date, mesPasado)) {
          // Aquí se asume que los ingresos son positivos y los gastos negativos
          final categoria = await _categoriasLocalDataSource.fetchCategoriaById(
            movimiento.categoryID,
          );
          if (categoria != null) {
            if (categoria.movementType == TipoMovimiento.ingreso) {
              totalIngresos += movimiento.amount;
            } else if (categoria.movementType == TipoMovimiento.gasto) {
              totalGastos += movimiento.amount;
            }
          }
        }
      }
    } on Exception catch (e) {
      AppLogger.log(
        'Error al calcular totales mensuales mes pasado: $e',
        level: LogLevel.error,
      );
    }

    return TotalesMensuales(ingresos: totalIngresos, gastos: totalGastos);
  }

  @override
  Future<Map<int, int>> getMovementsCountByCategory() async {
    return await localDataSource.getMovementsCountByCategory();
  }

  @override
  Future<List<Movimiento>> getMovementsByCategoryID(int categoryID) async {
    return await localDataSource.getMovementsByCategoryID(categoryID);
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
