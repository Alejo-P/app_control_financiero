import 'package:flutter/material.dart';

class AppBarAction {
  final IconData? icon;
  final Widget? iconWidget;
  final VoidCallback onPressed;
  final String? tooltip;
  final String? label;
  final int? badgeCount;

  AppBarAction({
    this.icon,
    this.iconWidget,
    required this.onPressed,
    this.tooltip,
    this.label,
    this.badgeCount,
  });

  String get labelValue => label?.trim() ?? '';
  String get tooltipValue => tooltip?.trim() ?? '';
  int get badgeCountValue => badgeCount ?? 0;
}
