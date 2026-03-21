import 'package:flutter/material.dart';

enum CategoriaFormMode { create, edit }

// Mapa de nombres exactos de Material Icons a IconData
const Map<String, IconData> categoryIconsMap = {
  'fastfood': Icons.fastfood,
  'shopping_cart': Icons.shopping_cart,
  'home': Icons.home,
  'directions_car': Icons.directions_car,
  'school': Icons.school,
  'favorite': Icons.favorite,
  'savings': Icons.savings,
  'attach_money': Icons.attach_money,
  'receipt_long': Icons.receipt_long,
  'local_grocery_store': Icons.local_grocery_store,
  'health_and_safety': Icons.health_and_safety,
  'pets': Icons.pets,
  'flight': Icons.flight,
  'work': Icons.work,
  'movie': Icons.movie,
  'fitness_center': Icons.fitness_center,
  'local_gas_station': Icons.local_gas_station,
  'restaurant': Icons.restaurant,
  'payments': Icons.payments,
  'directions_bus': Icons.directions_bus,
  'local_hospital': Icons.local_hospital,
  'music_note': Icons.music_note,
  'coffee': Icons.coffee,
  'beach_access': Icons.beach_access,
  'camera_alt': Icons.camera_alt,
  'computer': Icons.computer,
  'phone_android': Icons.phone_android,
  'home_repair_service': Icons.home_repair_service,
  'build': Icons.build,
  'compare_arrows_outlined': Icons.compare_arrows_outlined
};

// Lista para compatibilidad con código existente
final List<IconData> categoryIcons = categoryIconsMap.values.toList();

const List<Color> categoryColors = [
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
