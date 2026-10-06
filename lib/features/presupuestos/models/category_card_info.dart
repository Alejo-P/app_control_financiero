import 'package:control_financiero/core/utils/icon_mapper.dart';
import 'package:flutter/material.dart';

class CategoryCardInfo {
  final IconData icon;
  final Color color;
  final String title;
  final double spent;
  final double total;
  final double percentage;
  final DateTime date;
  final int categoryId;
  final int? budgetId;
  final double remainingAmount;
  final bool isOverBudget;

  CategoryCardInfo({
    required this.icon,
    required this.color,
    required this.title,
    required this.spent,
    required this.total,
    required this.date,
    required this.percentage,
    required this.categoryId,
    this.budgetId,
  }) : remainingAmount = total - spent,
       isOverBudget = spent > total;

  factory CategoryCardInfo.fromMap(Map<String, dynamic> map) {
    return CategoryCardInfo(
      icon: map['categoryIcon'] != null
          ? IconMapper.fromName(map['categoryIcon'])
          : Icons.category,
      color: Color(map['categoryColor'] ?? 0xFF000000),
      title: map['categoryName'] ?? 'Categoría desconocida',
      spent: (map['spent'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
      date: map['budgetDate'] != null
          ? DateTime.parse(map['budgetDate'])
          : DateTime.now(),
      percentage: (map['percentage'] as num).toDouble(),
      categoryId: (map['categoryId'] as num).toInt(),
      budgetId: map['budgetId'] != null
          ? (map['budgetId'] as num).toInt()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryIcon': IconMapper.toName(icon),
      'categoryColor': color.value,
      'categoryName': title,
      'spent': spent,
      'total': total,
      'budgetDate': date.toIso8601String(),
      'percentage': percentage,
      'categoryId': categoryId,
      'budgetId': budgetId,
    };
  }
}
