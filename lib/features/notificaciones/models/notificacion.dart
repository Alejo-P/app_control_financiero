import 'package:control_financiero/core/utils/icon_mapper.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class Notificacion {
  final int? id;
  final String title;
  final String description;
  final bool isRead;
  final String iconName;
  final int iconColorValue;
  final Map<String, dynamic>? extraData;
  final DateTime? createdAt;

  Notificacion({
    this.id,
    required this.title,
    required this.iconName,
    required this.iconColorValue,
    this.description = '',
    this.isRead = false,
    this.extraData,
    this.createdAt,
  });

  Notificacion copyWith({
    int? id,
    String? title,
    String? iconName,
    int? iconColorValue,
    String? description,
    bool? isRead,
    Map<String, dynamic>? extraData,
    DateTime? createdAt,
  }) {
    return Notificacion(
      id: id ?? this.id,
      title: title ?? this.title,
      iconName: iconName ?? this.iconName,
      iconColorValue: iconColorValue ?? this.iconColorValue,
      description: description ?? this.description,
      isRead: isRead ?? this.isRead,
      extraData: extraData ?? this.extraData,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Notificacion.fromMap(Map<String, dynamic> map) {
    return Notificacion(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      iconName: map['iconName'],
      iconColorValue: map['icon_color'],
      isRead: map['is_read'] == 1,
      extraData: map['extra_data'] != null && map['extra_data'] != ''
          ? Map<String, dynamic>.from(jsonDecode(map['extra_data']))
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconName': iconName,
      'icon_color': iconColorValue,
      'is_read': isRead ? 1 : 0,
      'extra_data': extraData != null ? jsonEncode(extraData) : null,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Method to get IconData from iconName
  IconData get iconData => IconMapper.fromName(iconName);

  // Method to get Color from iconColorValue
  Color get iconColor => Color(iconColorValue);
}
