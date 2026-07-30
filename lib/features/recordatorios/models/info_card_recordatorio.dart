import 'package:control_financiero/core/utils/icon_mapper.dart';
import 'package:flutter/material.dart';

class InfoCardRecordatorio {
  final int? id;
  final String title;
  final String categoryName;
  final IconData categoryIcon;
  final Color categoryColor;
  final bool isEnabled;
  final DateTime scheduledAt;
  final String recurrency;

  InfoCardRecordatorio({
    this.id,
    required this.title,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.isEnabled,
    required this.scheduledAt,
    required String recurrency,
  }) : recurrency = _capitalize(recurrency);

  static String _capitalize(String value) {
    if (value.isEmpty) return value;

    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  InfoCardRecordatorio copyWith({
    int? id,
    String? title,
    String? categoryName,
    IconData? categoryIcon,
    Color? categoryColor,
    bool? isEnabled,
    DateTime? scheduledAt,
    String? recurrency,
  }) {
    return InfoCardRecordatorio(
      id: id ?? this.id,
      title: title ?? this.title,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
      isEnabled: isEnabled ?? this.isEnabled,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      recurrency: recurrency ?? this.recurrency,
    );
  }

  factory InfoCardRecordatorio.fromMap(Map<String, dynamic> map) {
    return InfoCardRecordatorio(
      id: map['id'] as int?,
      title: map['title'] as String,
      categoryName: map['category_name'] as String,
      categoryIcon: IconMapper.fromName(map['category_icon'] as String),
      categoryColor: Color((map['category_color'] as num).toInt()),
      isEnabled: map['is_enabled'] == 1,
      scheduledAt: DateTime.parse(map['scheduled_at'] as String),
      recurrency: map['recurrency'] as String,
    );
  }
}
