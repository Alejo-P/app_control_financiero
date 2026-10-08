import 'package:flutter/material.dart';
import 'package:control_financiero/core/tutorials/tutorial_step.dart';

class AppBarAction {
  final IconData? icon;
  final Widget? iconWidget;
  final VoidCallback onPressed;
  final String? tooltip;
  final String? label;
  final int? badgeCount;
  final TutorialStep? tutorialStep;

  AppBarAction({
    this.icon,
    this.iconWidget,
    required this.onPressed,
    this.tooltip,
    this.label,
    this.badgeCount,
    this.tutorialStep,
  });

  String get labelValue => label?.trim() ?? '';
  String get tooltipValue => tooltip?.trim() ?? '';
  int get badgeCountValue => badgeCount ?? 0;
}
