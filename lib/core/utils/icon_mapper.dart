import 'package:flutter/material.dart';

// TODO> Implementar o unificar los iconos de la lista categoryIcons
class IconMapper {
  static const Map<String, IconData> _icons = {
    'shopping_cart': Icons.shopping_cart,
    'directions_bus': Icons.directions_bus,
    'attach_money': Icons.attach_money,
    'movie': Icons.movie,
    'restaurant': Icons.restaurant,
    'home': Icons.home,
    'category': Icons.category,
    'fitness_center': Icons.fitness_center,
    'local_gas_station': Icons.local_gas_station,
    'flight': Icons.flight,
    'local_hospital': Icons.local_hospital,
    'payments': Icons.payments,
    'school': Icons.school,
  };

  static IconData fromName(String name) {
    return _icons[name] ?? Icons.help_outline;
  }
}
