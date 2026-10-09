import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:control_financiero/core/utils/app_logger.dart';
import 'package:control_financiero/core/config/app_config.dart';
import 'package:path/path.dart' as p;

class ReportSendException implements Exception {
  const ReportSendException(this.message);
  final String message;
}

class ReportUploadResponse {
  const ReportUploadResponse(this.statusCode, this.body);
  final int statusCode;
  final String body;
}

class ErrorReportSender {
  ErrorReportSender({
    String? endpoint,
    Future<ReportUploadResponse> Function(Uri, File, String)? upload,
  }) : _endpoint = endpoint ?? AppConfig.errorReportUrl,
       _upload = upload ?? _uploadFile;

  final String _endpoint;
  final Future<ReportUploadResponse> Function(Uri, File, String) _upload;
  static const maxBytes = 4 * 1024 * 1024;

  Future<void> send(File file) async {
    final uri = Uri.tryParse(_endpoint);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasFragment ||
        uri.hasQuery ||
        uri.path != '/reports') {
      throw const ReportSendException(
        'El envío de reportes todavía no está configurado.',
      );
    }
    final match = RegExp(
      r'^reporte_error_(\d{10,20})\.zip$',
    ).firstMatch(p.basename(file.path));
    if (match == null) {
      throw const ReportSendException('El archivo de reporte no es válido.');
    }
    final reportId = match[1]!;
    if (await file.length() > maxBytes) {
      throw const ReportSendException(
        'El reporte supera el tamaño máximo de 4 MB.',
      );
    }
    try {
      final response = await _upload(uri, file, reportId);
      if (response.statusCode == 429) {
        throw const ReportSendException(
          'Se alcanzó el límite de envíos. Espera un minuto e intenta nuevamente.',
        );
      }
      if (response.statusCode == 413) {
        throw const ReportSendException(
          'El reporte supera el tamaño máximo de 4 MB.',
        );
      }
      if (response.statusCode != 202) {
        throw const ReportSendException(
          'No se pudo enviar el reporte. Intenta nuevamente.',
        );
      }
      final body = jsonDecode(response.body);
      if (body is! Map ||
          body['status'] != 'accepted' ||
          body['report_id'] != reportId) {
        throw const ReportSendException(
          'No se pudo confirmar el envío. Intenta nuevamente.',
        );
      }
    } on ReportSendException {
      rethrow;
    } on TimeoutException catch (error, stackTrace) {
      AppLogger.reportError(
        'Enviar reporte: tiempo de espera',
        error,
        stackTrace,
      );
      throw const ReportSendException(
        'La conexión tardó demasiado. Intenta nuevamente.',
      );
    } on IOException catch (error, stackTrace) {
      AppLogger.reportError('Enviar reporte: conexión', error, stackTrace);
      throw const ReportSendException(
        'No se pudo conectar. Revisa tu conexión a internet.',
      );
    } on FormatException catch (error, stackTrace) {
      AppLogger.reportError(
        'Enviar reporte: respuesta inválida',
        error,
        stackTrace,
      );
      throw const ReportSendException(
        'No se pudo confirmar el envío. Intenta nuevamente.',
      );
    }
  }

  static Future<ReportUploadResponse> _uploadFile(
    Uri uri,
    File file,
    String reportId,
  ) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    Future<ReportUploadResponse> run() async {
      final request = await client.postUrl(uri);
      request.followRedirects = false;
      request.headers.contentType = ContentType('application', 'zip');
      request.headers.set('X-Report-ID', reportId);
      request.contentLength = await file.length();
      await request.addStream(file.openRead());
      final response = await request.close();
      final bytes = <int>[];
      await for (final chunk in response) {
        if (bytes.length + chunk.length > 4096) {
          throw const ReportSendException(
            'No se pudo confirmar el envío. Intenta nuevamente.',
          );
        }
        bytes.addAll(chunk);
      }
      return ReportUploadResponse(response.statusCode, utf8.decode(bytes));
    }

    try {
      return await run().timeout(const Duration(seconds: 30));
    } finally {
      client.close(force: true);
    }
  }
}
