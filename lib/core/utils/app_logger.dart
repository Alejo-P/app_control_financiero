import 'dart:io';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/core/utils/file_utils.dart';
import 'package:control_financiero/core/utils/path_utils.dart' as path_utils;
import 'package:flutter/material.dart';

enum LogLevel { debug, info, warning, error }

class AppLogger {
  static Future<void> log(
    String message, {
    LogLevel level = LogLevel.info,
    String? tag,
    StackTrace? stackTrace,
  }) async {
    final filePath = await path_utils.getLogsFilePath(currentDateTime);
    final now = currentDateTime.toIso8601String();
    final prefix = '[${level.name.toUpperCase()}]';
    final label = tag != null ? '[$tag]' : '';

    // Por ahora consola
    // Luego puedes redirigir a archivo o servicio remoto
    debugPrint('$now $prefix$label: $message');
    await FileUtils.writeFile(
      filePath,
      '$now $prefix$label: $message\n',
      mode: FileMode.append,
    );
    if (stackTrace != null) {
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
