import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:flutter/material.dart';

enum LogLevel { debug, info, warning, error }

class AppLogger {
  static void log(
    String message, {
    LogLevel level = LogLevel.info,
    String? tag,
  }) {
    final now = currentDateTime.toIso8601String();
    final prefix = '[${level.name.toUpperCase()}]';
    final label = tag != null ? '[$tag]' : '';

    // Por ahora consola
    // Luego puedes redirigir a archivo o servicio remoto
    debugPrint('$now $prefix$label $message');
  }
}
