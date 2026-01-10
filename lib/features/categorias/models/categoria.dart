import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/utils/icon_mapper.dart';
import 'package:flutter/material.dart';

class Categoria {
  final String id;
  final String name;
  final String description;
  final TipoMovimiento movementType;
  final String categoryTypeID;
  final String iconName;
  final int iconColorValue;

  Categoria({
    required this.id,
    required this.name,
    required this.description,
    required this.movementType,
    required this.categoryTypeID,
    required this.iconName,
    required this.iconColorValue,
  });

  // Factory constructor to create a Categoria from JSON
  factory Categoria.fromMap(Map<String, dynamic> map) {
    return Categoria(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      movementType: map['movementType'],
      categoryTypeID: map['categoryTypeID'],
      iconName: map['iconName'],
      iconColorValue: map['iconColorValue'],
    );
  }

  // Method to convert a Categoria to JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'movementType': movementType,
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