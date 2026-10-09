import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:control_financiero/core/config/app_config.dart';
import 'package:control_financiero/core/utils/app_logger.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ErrorReportService {
  ErrorReportService({
    Future<Map<String, Object?>> Function()? metadata,
    Future<Map<String, String>> Function()? logs,
    Future<Directory> Function()? outputDirectory,
  }) : _metadata = metadata ?? collectMetadata,
       _logs =
           logs ??
           (() async => (await AppLogger.store).snapshot(DateTime.now())),
       _outputDirectory =
           outputDirectory ??
           (() async => Directory(
             p.join((await getTemporaryDirectory()).path, 'error_reports'),
           ));

  final Future<Map<String, Object?>> Function() _metadata;
  final Future<Map<String, String>> Function() _logs;
  final Future<Directory> Function() _outputDirectory;

  static Future<Map<String, Object?>> collectMetadata() async {
    final data = <String, Object?>{
      'platform': Platform.operatingSystem,
      'flavor': AppConfig.flavor,
      'locale': Platform.localeName,
      'timezone': DateTime.now().timeZoneName,
      'utc_offset_minutes': DateTime.now().timeZoneOffset.inMinutes,
      'app_timezone': 'America/Guayaquil',
    };
    try {
      final info = await PackageInfo.fromPlatform().timeout(
        const Duration(seconds: 5),
      );
      data['app'] = {
        'name': info.appName,
        'package': info.packageName,
        'version': info.version,
        'build': info.buildNumber,
      };
    } catch (error, stackTrace) {
      AppLogger.reportError('Obtener versión para reporte', error, stackTrace);
      data['app_info_status'] = 'unavailable';
    }
    try {
      final plugin = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final info = await plugin.androidInfo.timeout(
          const Duration(seconds: 5),
        );
        data['device'] = {
          'manufacturer': info.manufacturer,
          'model': info.model,
          'os_version': info.version.release,
          'sdk': info.version.sdkInt,
          'physical_device': info.isPhysicalDevice,
        };
      } else if (Platform.isIOS) {
        final info = await plugin.iosInfo.timeout(const Duration(seconds: 5));
        data['device'] = {
          'manufacturer': 'Apple',
          'model': info.utsname.machine,
          'os_version': info.systemVersion,
          'physical_device': info.isPhysicalDevice,
        };
      } else {
        data['device'] = {'os_version': Platform.operatingSystemVersion};
      }
    } catch (error, stackTrace) {
      AppLogger.reportError(
        'Obtener dispositivo para reporte',
        error,
        stackTrace,
      );
      data['device_info_status'] = 'unavailable';
    }
    return data;
  }

  Future<File> createReport(String description) async {
    final now = DateTime.now().toUtc();
    final id = now.microsecondsSinceEpoch.toString();
    final metadata = await _metadata();
    Map<String, String> logs;
    try {
      logs = await _logs();
    } catch (error, stackTrace) {
      AppLogger.reportError('Leer registros para reporte', error, stackTrace);
      logs = {};
      metadata['logs_status'] = 'unavailable';
    }
    final archive = Archive();
    void add(String name, String content) {
      final bytes = utf8.encode(content);
      archive.addFile(ArchiveFile(name, bytes.length, bytes));
    }

    add(
      'device_info.json',
      const JsonEncoder.withIndent('  ').convert({
        'report_id': id,
        'generated_at_utc': now.toIso8601String(),
        ...metadata,
      }),
    );
    add('description.txt', description.trim());
    add(
      'README.txt',
      'Reporte de diagnóstico de Mi Presupuesto.\n'
          'Contiene datos técnicos, descripción y registros recientes.\n'
          'No contiene la base de datos ni respaldos financieros.\n'
          'La aceptación del envío no confirma la entrega del correo.\n',
    );
    if (logs.isEmpty) add('logs/empty.txt', 'No hay registros disponibles.');
    for (final entry in logs.entries) {
      add('logs/${p.basename(entry.key)}', entry.value);
    }
    final directory = await _outputDirectory();
    await directory.create(recursive: true);
    await for (final entity in directory.list(followLinks: false)) {
      if (entity is File &&
          RegExp(
            r'^reporte_error_\d+\.zip$',
          ).hasMatch(p.basename(entity.path)) &&
          (await entity.stat()).modified.isBefore(
            now.subtract(const Duration(days: 1)),
          )) {
        await entity.delete();
      }
    }
    final file = File(p.join(directory.path, 'reporte_error_$id.zip'));
    final bytes = await compute(_encode, archive);
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static List<int> _encode(Archive archive) => ZipEncoder().encode(archive)!;
}
