import 'package:control_financiero/features/historial/data/category_report_query.dart';
import 'package:control_financiero/features/historial/data/expense_analysis_query.dart';
import 'package:control_financiero/features/historial/models/expense_analysis_page_args.dart';
import 'package:control_financiero/features/movimientos/models/detalle_movimiento.dart';
import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/database/db_helper.dart';
import 'package:control_financiero/core/database/db_tables.dart';
import 'package:control_financiero/features/historial/models/month_data.dart';
import 'package:control_financiero/features/historial/models/monthly_report.dart';
import 'package:control_financiero/features/historial/data/monthly_report_query.dart';

class HistorialLocalDataSource {
  final DBHelper _dbHelper = DBHelper.instance;

  Future<List<DetalleMovimiento>> fetchExpenseAnalysis(
    ExpenseAnalysisResultsPageArgs filters,
  ) async => ExpenseAnalysisQuery.load(await _dbHelper.database, filters);

  Future<List<DetalleMovimiento>> fetchCategoryReportMovements(
    DateTime month,
    int categoryId, {
    int offset = 0,
    bool oldestFirst = false,
  }) async => CategoryReportQuery.load(
    await _dbHelper.database,
    month,
    categoryId,
    offset: offset,
    oldestFirst: oldestFirst,
  );

  Future<MonthlyReport> fetchMonthlyReport(DateTime month) async =>
      MonthlyReportQuery.load(await _dbHelper.database, month);

  Future<List<MonthData>> fetchYearHistory(DateTime date) async {
    final db = await _dbHelper.database;
    final List<MonthData> yearResults = [];

    final year = date.year;
    final startDate = '$year-01-01';
    final endDate = '${year + 1}-01-01';

    final List<Map<String, dynamic>> results = await db.rawQuery(
      '''
      SELECT
        strftime('%Y-%m', m.${MovimientosTable.date}) AS month,
        SUM(CASE WHEN c.${CategoriasTable.movementType} = ? THEN m.${MovimientosTable.amount} ELSE 0 END) AS income,
        SUM(CASE WHEN c.${CategoriasTable.movementType} = ? THEN m.${MovimientosTable.amount} ELSE 0 END) AS spent
      FROM ${MovimientosTable.table} m
      JOIN ${CategoriasTable.table} c 
        ON m.${MovimientosTable.categoryId} = c.${CategoriasTable.id}
      WHERE m.${MovimientosTable.date} >= ?
        AND m.${MovimientosTable.date} < ?
      GROUP BY month
      ORDER BY month DESC;
    ''',
      [
        TipoMovimiento.ingreso.name,
        TipoMovimiento.gasto.name,
        startDate,
        endDate,
      ],
    );

    for (final map in results) {
      yearResults.add(MonthData.fromMap(map));
    }

    return yearResults;
  }

  Future<List<int>> fetchAvailableYears() async {
    final db = await _dbHelper.database;

    final results = await db.rawQuery('''
      SELECT DISTINCT strftime('%Y', ${MovimientosTable.date}) AS year
      FROM ${MovimientosTable.table}
      ORDER BY year DESC;
    ''');

    return results.map((e) => int.parse(e['year'] as String)).toList();
  }
}
