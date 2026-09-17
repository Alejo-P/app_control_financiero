import 'package:control_financiero/features/historial/data/historial_local_datasource.dart';
import 'package:control_financiero/features/historial/models/month_data.dart';

class HistorialRepository {
  final HistorialLocalDataSource localDataSource;

  HistorialRepository(this.localDataSource);

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
