import 'package:control_financiero/features/movimientos/models/detalle_movimiento.dart';
import 'package:control_financiero/features/historial/data/historial_local_datasource.dart';
import 'package:control_financiero/features/historial/models/month_data.dart';
import 'package:control_financiero/features/historial/models/monthly_report.dart';
import 'package:control_financiero/features/historial/models/expense_analysis_page_args.dart';

class HistorialRepository {
  final HistorialLocalDataSource localDataSource;

  HistorialRepository(this.localDataSource);

  Future<List<DetalleMovimiento>> fetchExpenseAnalysis(
    ExpenseAnalysisResultsPageArgs filters,
  ) => localDataSource.fetchExpenseAnalysis(filters);

  Future<List<DetalleMovimiento>> fetchCategoryReportMovements(
    DateTime month,
    int categoryId, {
    int offset = 0,
    bool oldestFirst = false,
  }) => localDataSource.fetchCategoryReportMovements(
    month,
    categoryId,
    offset: offset,
    oldestFirst: oldestFirst,
  );

  Future<MonthlyReport> fetchMonthlyReport(DateTime month) =>
      localDataSource.fetchMonthlyReport(month);

  /// Obtener la lista de historial por año
  /// @param date Fecha a la cual obtener la informacion
  /// @return Lista con el resumen de gastos e ingresos por mes
  Future<List<MonthData>> fetchYearHistory(DateTime date) async {
    return await localDataSource.fetchYearHistory(date);
  }

  /// Obtener una lista de años con registros de movimientos
  /// @return Lista con los años que contienen meses con movimientos registrados
  Future<List<int>> fetchAvailableYears() async {
    return await localDataSource.fetchAvailableYears();
  }
}
