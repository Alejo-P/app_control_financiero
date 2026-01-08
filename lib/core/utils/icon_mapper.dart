import 'package:flutter/material.dart';

class IconMapper {
  static const Map<String, IconData> _icons = {
    'shopping_cart': Icons.shopping_cart,
    'directions_bus': Icons.directions_bus,
    'attach_money': Icons.attach_money,
    'movie': Icons.movie,
    'restaurant': Icons.restaurant,
    'home': Icons.home,
    'category': Icons.category,
  };

  static IconData fromName(String name) {
    return _icons[name] ?? Icons.help_outline;
  }
}
