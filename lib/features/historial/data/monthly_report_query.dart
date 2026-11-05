import 'package:sqflite/sqflite.dart';
import '../models/monthly_report.dart';

class MonthlyReportQuery {
  static String _date(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-01';

  /// Una sola instantánea de lectura; agrega antes de unir para no multiplicar
  /// gastos cuando hay varios movimientos y presupuestos en una categoría.
  static Future<MonthlyReport> load(Database db, DateTime selected) {
    final month = DateTime(selected.year, selected.month);
    final start = _date(month);
    final end = _date(DateTime(month.year, month.month + 1));
    final previous = _date(DateTime(month.year, month.month - 1));
    return db.transaction((txn) async {
      final totals = (await txn.rawQuery(
        '''
        SELECT
          COALESCE(SUM(CASE WHEN c.movement_type = 'ingreso'
            AND m.date >= ? THEN m.amount ELSE 0 END), 0) AS income,
          COALESCE(SUM(CASE WHEN c.movement_type = 'gasto'
            AND m.date >= ? THEN m.amount ELSE 0 END), 0) AS spent,
          COALESCE(SUM(CASE WHEN c.movement_type = 'gasto'
            AND m.date < ? THEN m.amount ELSE 0 END), 0) AS previous_spent
        FROM movimientos m JOIN categorias c ON c.id = m.category_id
        WHERE m.date >= ? AND m.date < ?
      ''',
        [start, start, start, previous, end],
      )).single;
      final rows = await txn.rawQuery(
        '''
        SELECT c.id, c.name, c.icon_color_value AS color,
          COALESCE(m.spent, 0) AS spent, COALESCE(m.count, 0) AS count,
          p.budget
        FROM categorias c
        LEFT JOIN (
          SELECT category_id, SUM(amount) AS spent, COUNT(*) AS count
          FROM movimientos WHERE date >= ? AND date < ? GROUP BY category_id
        ) m ON m.category_id = c.id
        LEFT JOIN (
          SELECT category_id, SUM(amount) AS budget
          FROM presupuestos WHERE date >= ? AND date < ? GROUP BY category_id
        ) p ON p.category_id = c.id
        WHERE c.movement_type = 'gasto' AND (p.budget IS NOT NULL OR m.spent > 0)
        ORDER BY c.id
      ''',
        [start, end, start, end],
      );
      return MonthlyReport(
        month: month,
        income: reportAmount(totals['income'] as num),
        spent: reportAmount(totals['spent'] as num),
        previousSpent: reportAmount(totals['previous_spent'] as num),
        categories: rows.map(ReportCategory.fromMap).toList(),
      );
    });
  }
}
