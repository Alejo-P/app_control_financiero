import 'package:control_financiero/core/utils/icon_mapper.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class DetalleRecordatorio extends Equatable {
  final int id;
  final String title;
  final String description;
  final bool isEnabled;
  final bool isDefault;
  final DateTime scheduledAt;
  final String recurrency;
  final int categoryId;
  final String categoryName;
  final IconData categoryIcon;
  final Color categoryColor;

  const DetalleRecordatorio({
    required this.id,
    required this.title,
    required this.description,
    required this.isEnabled,
    required this.isDefault,
    required this.scheduledAt,
    required this.recurrency,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
  });

  DetalleRecordatorio copyWith({
    int? id,
    String? title,
    String? description,
    bool? isEnabled,
    bool? isDefault,
    DateTime? scheduledAt,
    String? recurrency,
    int? categoryId,
    String? categoryName,
    IconData? categoryIcon,
    Color? categoryColor,
  }) {
    return DetalleRecordatorio(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isEnabled: isEnabled ?? this.isEnabled,
      isDefault: isDefault ?? this.isDefault,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      recurrency: recurrency ?? this.recurrency,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
    );
  }

  factory DetalleRecordatorio.fromMap(Map<String, dynamic> map) {
    return DetalleRecordatorio(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      isEnabled: (map['is_enabled'] as int) == 1,
      isDefault: (map['is_default'] as int) == 1,
      scheduledAt: DateTime.parse(map['scheduled_at'] as String),
      recurrency: map['recurrency'] as String,
      categoryId: map['category_id'] as int,
      categoryName: map['category_name'] as String,
      categoryIcon: IconMapper.fromName(map['category_icon'] as String),
      categoryColor: Color(map['category_color'] as int),
    );
  }

  @override
  String toString() {
    return 'DetalleRecordatorio(id: $id, title: $title, description: $description, isEnabled: $isEnabled, isDefault: $isDefault, scheduledAt: $scheduledAt, recurrency: $recurrency, categoryId: $categoryId, categoryName: $categoryName, categoryIcon: $categoryIcon, categoryColor: $categoryColor)';
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    isEnabled,
    isDefault,
    scheduledAt,
    recurrency,
    categoryId,
    categoryName,
    categoryIcon,
    categoryColor,
  ];
}
