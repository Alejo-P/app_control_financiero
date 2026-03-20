import 'package:flutter/material.dart';

class AppBarAction {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final String? label;

  AppBarAction({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.label,
  });

  String get labelValue => label?.trim() ?? '';
  String get tooltipValue => tooltip?.trim() ?? '';
}
