import 'package:flutter/material.dart';

class AppBarAction {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  AppBarAction({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });
}
