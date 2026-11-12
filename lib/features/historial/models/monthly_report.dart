import 'package:control_financiero/core/utils/icon_mapper.dart';
import 'package:flutter/material.dart';

/// Importes redondeados a centavos para comparar límites monetarios.
double reportAmount(num value) => (value * 100).round() / 100;

enum ReportBudgetStatus { none, healthy, inUse, nearLimit, reached, exceeded }

class ReportCategory {
  final int id;
  final String name;
  final IconData icon;
  final int colorValue;
  final double spent;
  final int count;
  final double? budget;

  const ReportCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
    required this.spent,
    required this.count,
    this.budget,
  });

  factory ReportCategory.fromMap(Map<String, Object?> map) => ReportCategory(
    id: (map['id'] as num).toInt(),
    name: map['name'] as String,
    icon: map['icon'] != null ? IconMapper.fromName(map['icon'] as String) : Icons.category,
    colorValue: (map['color'] as num?)?.toInt() ?? 0xFF607D8B,
    spent: reportAmount(map['spent'] as num? ?? 0),
    count: (map['count'] as num? ?? 0).toInt(),
    budget: map['budget'] == null ? null : reportAmount(map['budget'] as num),
  );

  double? get ratio => budget != null && budget! > 0 ? spent / budget! : null;
  double? get remaining =>
      budget == null ? null : reportAmount(budget! - spent);
  ReportBudgetStatus get status {
    if (budget == null) return ReportBudgetStatus.none;
    if (spent > budget!) return ReportBudgetStatus.exceeded;
    if (spent == budget!) return ReportBudgetStatus.reached;
    if ((ratio ?? 0) >= .85) return ReportBudgetStatus.nearLimit;
    if ((ratio ?? 0) >= .5) return ReportBudgetStatus.inUse;
    return ReportBudgetStatus.healthy;
  }
}

class MonthlyReport {
  final DateTime month;
  final double income;
  final double spent;
  final double previousSpent;
  final List<ReportCategory> categories;

  MonthlyReport({
    required DateTime month,
    required this.income,
    required this.spent,
    required this.previousSpent,
    required List<ReportCategory> categories,
  }) : month = DateTime(month.year, month.month),
       categories = List.unmodifiable(categories);

  double get balance => reportAmount(income - spent);
  double? get savingsPercent => income > 0 ? balance / income * 100 : null;
  double get expenseChange => reportAmount(spent - previousSpent);
  double? get expenseChangePercent => previousSpent > 0
      ? expenseChange / previousSpent * 100
      : spent == 0
      ? 0
      : null;
  DateTime get previousMonth => DateTime(month.year, month.month - 1);

  List<ReportCategory> get expenseCategories {
    final result = categories.where((c) => c.spent > 0).toList();
    result.sort((a, b) {
      final bySpent = b.spent.compareTo(a.spent);
      if (bySpent != 0) return bySpent;
      final byName = a.name.compareTo(b.name);
      return byName != 0 ? byName : a.id.compareTo(b.id);
    });
    return result;
  }

  List<ReportCategory> get budgetCategories {
    final result = categories
        .where((c) => c.budget != null || c.spent > 0)
        .toList();
    result.sort((a, b) {
      if ((a.budget == null) != (b.budget == null)) {
        return a.budget == null ? 1 : -1;
      }
      final byName = a.name.compareTo(b.name);
      return byName != 0 ? byName : a.id.compareTo(b.id);
    });
    return result;
  }
}
