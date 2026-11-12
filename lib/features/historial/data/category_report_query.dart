import 'package:sqflite/sqflite.dart';
import '../../movimientos/models/detalle_movimiento.dart';

class CategoryReportQuery {
  static Future<List<DetalleMovimiento>> load(
    Database db,
    DateTime month,
    int categoryId, {
    int offset = 0,
    bool oldestFirst = false,
  }) async {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    final order = oldestFirst ? 'ASC' : 'DESC';
    final rows = await db.rawQuery(
      '''
      SELECT m.id, m.title, m.amount, m.date, m.time, m.note,
        c.name AS category_name, c.icon_name AS category_icon,
        c.icon_color_value AS category_color, c.movement_type,
        c.id AS category_id
      FROM movimientos m JOIN categorias c ON c.id = m.category_id
      WHERE m.category_id = ? AND c.movement_type = 'gasto'
        AND m.date >= ? AND m.date < ?
      ORDER BY m.date $order, m.time $order, m.id $order
      LIMIT 10 OFFSET ?
    ''',
      [
        categoryId,
        start.toIso8601String().substring(0, 10),
        end.toIso8601String().substring(0, 10),
        offset,
      ],
    );
    return rows.map(DetalleMovimiento.fromMap).toList();
  }
}
