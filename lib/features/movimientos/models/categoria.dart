import 'package:control_financiero/core/utils/icon_mapper.dart';
import 'package:flutter/material.dart';

class Categoria {
  final String id;
  final String name;
  final String description;
  final String categoryTypeID;
  final String iconName;
  final int iconColorValue;

  Categoria({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryTypeID,
    required this.iconName,
    required this.iconColorValue,
  });


  // Factory constructor to create a Categoria from JSON
  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      categoryTypeID: json['categoryTypeID'],
      iconName: json['iconName'],
      iconColorValue: json['iconColorValue'],
    );
  }

  // Method to convert a Categoria to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'categoryTypeID': categoryTypeID,
      'iconName': iconName,
      'iconColorValue': iconColorValue,
    };
  }

  // Method to get IconData from iconName
  IconData get iconData => IconMapper.fromName(iconName);

  // Method to get Color from iconColorValue
  Color get iconColor => Color(iconColorValue);
}