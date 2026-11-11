import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/features/historial/models/expense_analysis_page_args.dart';
import 'package:control_financiero/features/movimientos/models/detalle_movimiento.dart';
import 'package:sqflite/sqflite.dart';

class ExpenseAnalysisQuery {
  static Future<List<DetalleMovimiento>> load(
    DatabaseExecutor db,
    ExpenseAnalysisResultsPageArgs filters,
  ) async {
    final categoryIds = filters.categoryIds.toList();
    if (categoryIds.isEmpty) return [];
    final range = filters.range;
    if (filters.period == ExpenseAnalysisPeriod.custom && range == null) {
      throw ArgumentError('El período personalizado requiere un rango.');
    }

    final placeholders = List.filled(categoryIds.length, '?').join(', ');
    final conditions = [
      'c.movement_type = ?',
      'm.category_id IN ($placeholders)',
      if (range != null) 'm.date BETWEEN ? AND ?',
      if (filters.concept.isNotEmpty)
        // SQLite lower() handles ASCII. Fold Spanish uppercase letters too.
        "instr(lower(replace(replace(replace(replace(replace(replace(replace(m.title, 'Á', 'á'), 'É', 'é'), 'Í', 'í'), 'Ó', 'ó'), 'Ú', 'ú'), 'Ü', 'ü'), 'Ñ', 'ñ')), ?) > 0",
    ];
    final rows = await db.rawQuery(
      '''
      SELECT m.id, m.title, CAST(m.amount AS REAL) AS amount, m.date,
        c.name AS category_name, c.movement_type, c.id AS category_id
      FROM movimientos m
      JOIN categorias c ON m.category_id = c.id
      WHERE ${conditions.join(' AND ')}
      ORDER BY m.date DESC, m.time DESC, m.id DESC
      ''',
      [
        TipoMovimiento.gasto.name,
        ...categoryIds,
        if (range != null) ...[
          range.start.toIso8601String().substring(0, 10),
          range.end.toIso8601String().substring(0, 10),
        ],
        if (filters.concept.isNotEmpty) filters.concept.toLowerCase(),
      ],
    );
    return rows.map(DetalleMovimiento.fromMap).toList(growable: false);
  }
}
