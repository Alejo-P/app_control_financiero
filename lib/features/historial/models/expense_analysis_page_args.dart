import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';
import 'package:flutter/material.dart';

enum ExpenseAnalysisPeriod {
  allHistory('Todo el historial'),
  thisMonth('Este mes'),
  lastMonth('Mes pasado'),
  twoMonthsAgo('2 meses atrás'),
  thisYear('Este año'),
  custom('Otro período');

  const ExpenseAnalysisPeriod(this.label);

  final String label;

  String optionLabel(DateTime today) =>
      this == thisYear ? '$label (${today.year})' : label;

  DateTimeRange? resolve(DateTime today, DateTimeRange? customRange) {
    return switch (this) {
      allHistory => null,
      thisMonth => _month(today, 0),
      lastMonth => _month(today, -1),
      twoMonthsAgo => _month(today, -2),
      thisYear => DateTimeRange(
        start: DateTime(today.year),
        end: DateTime(today.year, 12, 31),
      ),
      custom => customRange,
    };
  }

  static DateTimeRange _month(DateTime today, int offset) => DateTimeRange(
    start: DateTime(today.year, today.month + offset),
    end: DateTime(today.year, today.month + offset + 1, 0),
  );
}

class ExpenseAnalysisFormPageArgs {
  const ExpenseAnalysisFormPageArgs({required this.initialPeriod});

  final ExpenseAnalysisPeriod initialPeriod;
}

class ExpenseAnalysisResultsPageArgs {
  ExpenseAnalysisResultsPageArgs({
    required this.period,
    required DateTime today,
    required Iterable<Categoria> categories,
    required String concept,
    DateTimeRange? customRange,
  }) : range = period.resolve(today, customRange),
       categories = List.unmodifiable(categories),
       concept = concept.trim();

  final ExpenseAnalysisPeriod period;
  final DateTimeRange? range;
  final List<Categoria> categories;
  final String concept;

  Iterable<int> get categoryIds => categories.map((category) => category.id!);

  String get periodLabel {
    final dates = range;
    if (dates == null) return period.label;
    return switch (period) {
      ExpenseAnalysisPeriod.custom =>
        '${formatDate(dates.start)} – ${formatDate(dates.end)}',
      ExpenseAnalysisPeriod.thisYear => period.optionLabel(dates.start),
      _ => '${period.label} · ${formatMonthYear(dates.start)}',
    };
  }
}
