enum LogLevel { debug, info, warning, error }

class AppLogger {
  static void log(
    String message, {
    LogLevel level = LogLevel.info,
    String? tag,
  }) {
    final now = DateTime.now().toIso8601String();
    final prefix = '[${level.name.toUpperCase()}]';
    final label = tag != null ? '[$tag]' : '';

    // Por ahora consola
    // Luego puedes redirigir a archivo o servicio remoto
    print('$now $prefix$label $message');
  }
}
