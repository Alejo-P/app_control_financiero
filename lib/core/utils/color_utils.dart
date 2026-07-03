import 'dart:math';
import 'package:flutter/material.dart';

const List<Color> colors = [
  Colors.blue,
  Colors.green,
  Colors.red,
  Colors.orange,
  Colors.purple,
  Colors.teal,
  Colors.pink,
  Colors.brown,
  Colors.grey,
  Colors.indigo,
  Colors.cyan,
  Colors.lime,
  Colors.amber,
  Colors.deepOrange,
  Colors.lightBlue,
  Colors.lightGreen,
  Colors.deepPurple,
  Colors.yellow,
];

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

Color getRandomColor([List<Color>? from]) {
  final colorsList = from ?? colors;
  final limit = colorsList.length;
  final index = Random().nextInt(limit);
  final color = colorsList[index];

  return color;
}
