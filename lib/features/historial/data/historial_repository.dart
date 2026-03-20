import 'package:control_financiero/features/historial/data/historial_local_datasource.dart';
import 'package:control_financiero/features/historial/models/month_data.dart';

abstract class _HistorialRepository {
  /// Obtener la lista de historial por año
  /// @param date Fecha a la cual obtener la informacion
  /// @return Lista con el resumen de gastos e ingresos por mes
  Future<List<MonthData>> fetchYearHistory(DateTime date);

  /// Obtener una lista de años con registros de movimientos
  /// @return Lista con los años que contienen meses con movimientos registrados
  Future<List<int>> fetchAvailableYears();
}

class HistorialRepository implements _HistorialRepository {
  final HistorialLocalDataSource localDataSource;
  final List<MonthData> historial = [];
  final List<int> availableYears = [];

  HistorialRepository(this.localDataSource);

  @override
  Future<List<MonthData>> fetchYearHistory(DateTime date) async {
    historial.clear();

    historial.addAll(await localDataSource.fetchYearHistory(date));

    return historial;
  }

  @override
  Future<List<int>> fetchAvailableYears() async {
    availableYears.clear();

    availableYears.addAll(await localDataSource.fetchAvailableYears());

    return availableYears;
  }
}
