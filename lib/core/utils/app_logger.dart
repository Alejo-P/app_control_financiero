import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

enum LogLevel { debug, info, warning, error }

/// Technical diagnostics only: never pass financial or user content.
class DiagnosticLogStore {
  DiagnosticLogStore(this.directory, {this.maxBytes = 256 * 1024});
  final Directory directory;
  final int maxBytes;
  Future<void> _pending = Future<void>.value();

  Future<void> write(String entry, DateTime now) {
    final next = _pending.then((_) async {
      await directory.create(recursive: true);
      await _prune(now.toUtc());
      final day = now.toUtc().toIso8601String().substring(0, 10);
      final file = File(p.join(directory.path, 'app_log_$day.log'));
      final bytes = utf8.encode(entry);
      if (bytes.length > maxBytes) return;
      if (await file.exists() &&
          await file.length() + bytes.length > maxBytes) {
        final previous = File('${file.path}.previous');
        if (await previous.exists()) await previous.delete();
        await file.rename(previous.path);
      }
      await file.writeAsBytes(bytes, mode: FileMode.append, flush: true);
    });
    _pending = next.catchError((Object _) {});
    return next;
  }

  Future<void> _prune(DateTime now) async {
    final cutoff = DateTime.utc(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 6));
    await for (final entity in directory.list(followLinks: false)) {
      if (entity is! File) continue;
      final match = RegExp(
        r'^app_log_(\d{4}-\d{2}-\d{2})\.log(?:\.previous)?$',
      ).firstMatch(p.basename(entity.path));
      if (match == null) continue;
      final date = DateTime.tryParse('${match[1]}T00:00:00Z');
      if (date != null && date.isBefore(cutoff)) await entity.delete();
    }
  }

  Future<Map<String, String>> snapshot(DateTime now) {
    final next = _pending.then((_) async {
      if (!await directory.exists()) return <String, String>{};
      await _prune(now.toUtc());
      final result = <String, String>{};
      final files = await directory.list(followLinks: false).toList();
      files.sort((a, b) => a.path.compareTo(b.path));
      for (final entity in files) {
        if (entity is! File ||
            !RegExp(
              r'^app_log_\d{4}-\d{2}-\d{2}\.log(?:\.previous)?$',
            ).hasMatch(p.basename(entity.path))) {
          continue;
        }
        if (await entity.length() <= maxBytes) {
          result[p.basename(entity.path)] = await entity.readAsString();
        }
      }
      return result;
    });
    _pending = next.then<void>((_) {}).catchError((Object _) {});
    return next;
  }
}

class AppLogger {
  /// Call before returning from a catch, including when its widget is unmounted.
  /// File I/O must never delay error feedback or replace the original error.
  static void reportError(String operation, Object error, StackTrace stack) {
    unawaited(recordError(operation, error, stack));
  }

  static String errorSummary(Object error) =>
      '${error.runtimeType}'
      '${error is PlatformException && RegExp(r"^[a-zA-Z0-9_-]{1,64}$").hasMatch(error.code) ? ', code=${error.code}' : ''}';

  /// Messages aid diagnosis; structured payloads, SQL and offending values do not.
  static String errorDetail(Object error) {
    if (error is DatabaseException) {
      final code = error.getResultCode();
      final reason = switch (code == null ? null : code & 0xff) {
        1 => 'Consulta SQL inválida o esquema incompatible',
        5 => 'Base de datos bloqueada',
        8 => 'Base de datos de solo lectura',
        11 => 'Base de datos dañada',
        14 => 'No se pudo abrir la base de datos',
        19 => 'Restricción de integridad incumplida',
        20 => 'Tipo de dato incompatible',
        _ => 'Error de base de datos',
      };
      return '$reason (sqlite_code=${code ?? 'desconocido'})';
    }
    // ArgumentError/RangeError.toString include the offending value.
    if (error is ArgumentError) return 'Argumento inválido';
    final message = switch (error) {
      PlatformException() => error.message ?? 'Error de plataforma',
      FormatException() => error.message,
      StateError() => error.message,
      FileSystemException() => error.osError?.message ?? error.message,
      Exception() => error.toString(),
      _ => '',
    };
    var detail = message.replaceAll(RegExp(r'[\r\n\x00-\x1f]'), ' ');
    detail = detail.replaceAll(
      RegExp(
        r'\b(?:password|contraseña|token|authorization|api[_-]?key|secret|nota|note|monto|amount|title|título)\b[^,;]*',
        caseSensitive: false,
      ),
      '[dato oculto]',
    );
    detail = detail.replaceAll(
      RegExp(r'https?://\S+', caseSensitive: false),
      '[URL oculta]',
    );
    detail = detail.replaceAll(
      RegExp(r'[A-Za-z]:[\\/][^,;]*'),
      '[ruta oculta]',
    );
    detail = detail.replaceAll(
      RegExp(r'\b[^\s@]+@[^\s@]+\.[^\s@]+'),
      '[correo oculto]',
    );
    return detail.length > 500 ? '${detail.substring(0, 500)}…' : detail;
  }

  static String diagnosticStack(StackTrace stack) => stack
      .toString()
      .split('\n')
      .where((line) => RegExp(r'\((?:package:|dart:)').hasMatch(line))
      .take(40)
      .join('\n');

  static Future<DiagnosticLogStore>? _store;
  static Future<DiagnosticLogStore> get store async =>
      _store ??= _createStore();

  static Future<DiagnosticLogStore> _createStore() async {
    try {
      return DiagnosticLogStore(
        Directory(
          p.join(
            (await getApplicationSupportDirectory()).path,
            'diagnostic_logs',
          ),
        ),
      );
    } catch (_) {
      _store = null;
      rethrow;
    }
  }

  static Future<void> log(
    String message, {
    LogLevel level = LogLevel.info,
    String? tag,
    StackTrace? stackTrace,
  }) async {
    try {
      final now = DateTime.now().toUtc();
      final frames = stackTrace == null ? null : diagnosticStack(stackTrace);
      final entry =
          '${now.toIso8601String()} [${level.name.toUpperCase()}] '
          '[${tag ?? 'app'}] $message\n${frames == null || frames.isEmpty ? '' : '$frames\n'}';
      if (kDebugMode) debugPrint(entry);
      await (await store).write(entry, now);
    } catch (_) {
      debugPrint('No se pudo guardar el registro de diagnóstico.');
    }
  }

  static Future<void> recordError(
    String operation,
    Object error,
    StackTrace stack,
  ) async {
    String detail;
    try {
      detail = errorDetail(error);
    } catch (_) {
      detail = 'Detalle no disponible';
    }
    await log(
      '$operation (${errorSummary(error)})${detail.isEmpty ? '' : ': $detail'}',
      level: LogLevel.error,
      stackTrace: stack,
    );
  }
}
