import 'package:flutter/material.dart';

class AppBarAction {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final String? label;
  final int? badgeCount;

  AppBarAction({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.label,
    this.badgeCount,
  });

  String get labelValue => label?.trim() ?? '';
  String get tooltipValue => tooltip?.trim() ?? '';
  int get badgeCountValue => badgeCount ?? 0;
}
