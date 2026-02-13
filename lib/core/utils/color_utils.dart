import 'package:flutter/material.dart';

List<int> getRGBFromColor(Color color) {
  // Convert Color components (0..1) to 0..255 ints to avoid deprecated accessors
  final int r = ((color.r * 255.0).round().clamp(0, 255)).toInt();
  final int g = ((color.g * 255.0).round().clamp(0, 255)).toInt();
  final int b = ((color.b * 255.0).round().clamp(0, 255)).toInt();
  return [r, g, b];
}

// Comparar si ambor colores son iguales (El mismo valor)
// ignore: deprecated_member_use
bool compareColors(Color a, Color b) => a.value == b.value;

