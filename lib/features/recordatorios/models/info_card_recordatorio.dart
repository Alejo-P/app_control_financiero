import 'package:control_financiero/core/utils/icon_mapper.dart';
import 'package:flutter/material.dart';

class InfoCardRecordatorio {
  final int? id;
  final String title;
  final String? categoryName;
  final IconData? categoryIcon;
  final Color? categoryColor;
  final bool isEnabled;
  final bool isDefault;
  final DateTime scheduledAt;
  final String recurrency;

  InfoCardRecordatorio({
    this.id,
    required this.title,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    required this.isEnabled,
    required this.isDefault,
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
    bool? isDefault,
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
      isDefault: isDefault ?? this.isDefault,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      recurrency: recurrency ?? this.recurrency,
    );
  }

  factory InfoCardRecordatorio.fromMap(Map<String, dynamic> map) {
    return InfoCardRecordatorio(
      id: map['id'] as int?,
      title: map['title'] as String,
      categoryName: map['category_name'] != null
          ? (map['category_name'] as String)
          : null,
      categoryIcon: map['category_icon'] != null
          ? IconMapper.fromName(map['category_icon'] as String)
          : null,
      categoryColor: map['category_color'] != null
          ? Color((map['category_color'] as num).toInt())
          : null,
      isEnabled: map['is_enabled'] == 1,
      isDefault: map['is_default'] == 1,
      scheduledAt: DateTime.parse(map['scheduled_at'] as String),
      recurrency: map['recurrency'] as String,
    );
  }
}
