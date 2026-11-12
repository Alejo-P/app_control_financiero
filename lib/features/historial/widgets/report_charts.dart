import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/monthly_report.dart';

const reportIncomeColor = Color(0xFF299C68);
const reportExpenseColor = Color(0xFFDC7951);

String reportMoney(double amount) =>
    '${amount < 0 ? '-' : ''}\$${NumberFormat('#,##0.00', 'es_EC').format(amount.abs())}';
String reportPercent(double value) =>
    '${NumberFormat('0.#', 'es_EC').format(value == 0 ? 0 : value)} %';

/// Colores locales al informe; orden por ID para mantener la asignación estable
/// al seleccionar o reordenar filas. No escribe en las categorías.
Map<int, Color> reportCategoryColors(List<ReportCategory> categories) {
  final sorted = [...categories]..sort((a, b) => a.id.compareTo(b.id));
  final result = <int, Color>{};
  double distance(Color a, Color b) => math.sqrt(
    math.pow(a.r - b.r, 2) + math.pow(a.g - b.g, 2) + math.pow(a.b - b.b, 2),
  );
  for (final category in sorted) {
    var color = Color(category.colorValue).withValues(alpha: 1);
    if (result.values.any((other) => distance(color, other) < .28)) {
      var bestDistance = -1.0;
      // Variar matiz y luminosidad evita limitarse a una paleta corta que se repite.
      for (var i = 0; i < 144; i++) {
        final candidate = HSLColor.fromAHSL(
          1,
          (category.id * 137.508 + i * 137.508) % 360,
          .68,
          [.38, .50, .62][i % 3],
        ).toColor();
        final nearest = result.values
            .map((other) => distance(candidate, other))
            .reduce(math.min);
        if (nearest > bestDistance) {
          bestDistance = nearest;
          color = candidate;
        }
      }
    }
    result[category.id] = color;
  }
  return result;
}

class ReportBarChart extends StatelessWidget {
  final double income;
  final double spent;
  const ReportBarChart({super.key, required this.income, required this.spent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final maxAmount = math.max(income, spent);
    Widget bar(String label, double value, Color color) => Expanded(
      child: Column(
        children: [
          SizedBox(
            height: 132 + MediaQuery.textScalerOf(context).scale(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                      reportMoney(value),
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 52,
                  height: maxAmount <= 0
                      ? 0
                      : (value / maxAmount * 112).clamp(0, 112).toDouble(),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Theme.of(context).colorScheme.primary),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.circle, size: 9, color: color),
              const SizedBox(width: 5),
              Text(
                  label,
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary),
              ),
            ],
          ),
        ],
      ),
    );
    return Semantics(
      label: 'Ingresos ${reportMoney(income)}. Gastos ${reportMoney(spent)}.',
      child: Row(
        children: [
          bar('Ingresos', income, reportIncomeColor),
          const SizedBox(width: 12),
          bar('Gastos', spent, reportExpenseColor),
        ],
      ),
    );
  }
}

class ReportDonut extends StatelessWidget {
  final List<ReportCategory> categories;
  final Map<int, Color> colors;
  final int? selectedId;
  final ValueChanged<int> onSelected;
  const ReportDonut({
    super.key,
    required this.categories,
    required this.colors,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final total = categories.fold(0.0, (sum, c) => sum + c.spent);
    final selected = categories.where((c) => c.id == selectedId).firstOrNull;
    return Center(
      child: SizedBox.square(
        dimension: 220,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              onTapUp: (event) {
                final delta =
                    event.localPosition -
                    Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
                if (delta.distance < 70 || delta.distance > 108 || total <= 0) {
                  return;
                }
                final angle =
                    (math.atan2(delta.dy, delta.dx) +
                        math.pi / 2 +
                        math.pi * 2) %
                    (math.pi * 2);
                var end = 0.0;
                for (final category in categories) {
                  end += category.spent / total * math.pi * 2;
                  if (angle < end) {
                    onSelected(category.id);
                    break;
                  }
                }
              },
              child: CustomPaint(
                painter: _DonutPainter(categories, colors, selectedId),
                child: Center(
                  child: SizedBox(
                    width: 130,
                    height: 130,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(
                        width: 130,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              selected?.name ?? 'TOTAL',
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                reportMoney(selected?.spent ?? total),
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              selected == null
                                  ? '${categories.length} categorías'
                                  : reportPercent(selected.spent / total * 100),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<ReportCategory> categories;
  final Map<int, Color> colors;
  final int? selectedId;
  _DonutPainter(this.categories, this.colors, this.selectedId);

  @override
  void paint(Canvas canvas, Size size) {
    final total = categories.fold(0.0, (sum, c) => sum + c.spent);
    if (total <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    var start = -math.pi / 2;
    for (final category in categories) {
      final selected = category.id == selectedId;
      final sweep = category.spent / total * math.pi * 2;
      final rect = Rect.fromCircle(center: center, radius: selected ? 94 : 90);
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..color = colors[category.id]!
          ..style = PaintingStyle.stroke
          ..strokeWidth = selected ? 30 : 24,
      );
      if (selected) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: 111),
          start,
          sweep,
          false,
          Paint()
            ..color = colors[category.id]!
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => true;
}
