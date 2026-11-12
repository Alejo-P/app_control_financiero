import 'package:control_financiero/features/historial/models/monthly_report.dart';
import 'package:flutter/material.dart';

class CategoryReportPageArgs {
  final DateTime month;
  final ReportCategory category;
  final double totalSpent;
  final Color color;

  CategoryReportPageArgs({
    required this.month,
    required this.category,
    required this.totalSpent,
    required this.color,
  });
}
