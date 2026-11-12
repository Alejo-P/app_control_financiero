import 'package:flutter/material.dart';
import '../models/monthly_report.dart';
import 'report_charts.dart';

Color reportBudgetColor(BuildContext context, ReportBudgetStatus status) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return switch (status) {
    ReportBudgetStatus.none => Theme.of(context).colorScheme.onSurfaceVariant,
    ReportBudgetStatus.healthy =>
      dark ? const Color(0xFF81C784) : const Color(0xFF247347),
    ReportBudgetStatus.inUse =>
      dark ? const Color(0xFFE0BD45) : const Color(0xFF806000),
    ReportBudgetStatus.nearLimit =>
      dark ? const Color(0xFFFFB36B) : const Color(0xFFA34700),
    ReportBudgetStatus.reached || ReportBudgetStatus.exceeded =>
      dark ? const Color(0xFFFF8A80) : const Color(0xFFB3261E),
  };
}

String reportBudgetMessage(ReportCategory category) =>
    switch (category.status) {
      ReportBudgetStatus.none => 'Sin presupuesto',
      ReportBudgetStatus.healthy => 'Dentro del presupuesto',
      ReportBudgetStatus.inUse => 'Presupuesto en uso',
      ReportBudgetStatus.nearLimit => 'Cerca del límite',
      ReportBudgetStatus.reached => 'Límite alcanzado',
      ReportBudgetStatus.exceeded =>
        'Excedido por ${reportMoney(category.spent - category.budget!)}',
    };
