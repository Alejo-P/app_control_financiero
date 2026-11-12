import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'update_release.dart';

class DownloadProgress {
  const DownloadProgress(this.received, this.total, this.bytesPerSecond);
  final int received;
  final int total;
  final double bytesPerSecond;
  double get fraction => (received / total).clamp(0, 1);
  int? get remainingSeconds =>
      bytesPerSecond > 0 ? ((total - received) / bytesPerSecond).ceil() : null;
}

/// Closing this client aborts both requests and response streams immediately.
class UpdateCancellation {
  bool cancelled = false;
  HttpClient? _client;
  void cancel() {
    cancelled = true;
    _client?.close(force: true);
  }

  void check() {
    if (cancelled) throw const UpdateException('Descarga cancelada.');
  }
}

class UpdateService {
  UpdateService({
    Uri? apiEndpoint,
    Future<Directory> Function()? temporaryDirectory,
    Future<PackageInfo> Function()? packageInfo,
    HttpClient Function()? clientFactory,
  }) : apiEndpoint =
           apiEndpoint ??
           Uri.https('api.github.com', '/repos/$repository/releases/latest'),
       temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory,
       packageInfo = packageInfo ?? PackageInfo.fromPlatform,
       clientFactory = clientFactory ?? HttpClient.new;
  final Uri apiEndpoint;
  final Future<Directory> Function() temporaryDirectory;
  final Future<PackageInfo> Function() packageInfo;
  final HttpClient Function() clientFactory;
  static const repository = 'Alejo-P/app_control_financiero';
  static const channel = MethodChannel('mi_presupuesto/updates');
  static const timeout = Duration(seconds: 15);

  Future<Directory> _directory() async {
    final root = await temporaryDirectory();
    return Directory('${root.path}/app_updates').create(recursive: true);
  }

  /// Called on startup, including after Android killed a previous download.
  Future<void> cleanDownloads() async {
    final directory = await _directory();
    await for (final entry in directory.list()) {
      if (entry is File) await entry.delete();
    }
  }

  Uri assetUrl(dynamic value) {
    final uri = Uri.tryParse(value is String ? value : '');
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host != 'github.com' ||
        uri.hasPort ||
        uri.userInfo.isNotEmpty ||
        !uri.path.startsWith('/$repository/releases/download/')) {
      throw const UpdateException('El enlace de descarga no es válido.');
    }
    return uri;
  }

  Future<Map<String, dynamic>> _json(HttpClient client, Uri url) async {
    final request = await client.getUrl(url).timeout(timeout);
    request.headers.set(
      HttpHeaders.acceptHeader,
      'application/vnd.github+json',
    );
    request.headers.set(HttpHeaders.userAgentHeader, 'Mi-Presupuesto-Updater');
    final response = await request.close().timeout(timeout);
    if (response.statusCode == 404) {
      throw const UpdateException(
        'No hay una actualización pública disponible.',
      );
    }
    if (response.statusCode == 403 || response.statusCode == 429) {
      throw const UpdateException(
        'GitHub no permite consultar ahora. Inténtelo más tarde.',
      );
    }
    if (response.statusCode != 200) {
      throw const UpdateException('No se pudo consultar la actualización.');
    }
    final bytes = <int>[];
    await for (final chunk in response.timeout(timeout)) {
      bytes.addAll(chunk);
      if (bytes.length > 1024 * 1024) {
        throw const UpdateException(
          'La respuesta de actualización es demasiado grande.',
        );
      }
    }
    return jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
  }

  Future<UpdateRelease?> check(UpdateCancellation cancellation) async {
    final client = clientFactory()..connectionTimeout = timeout;
    cancellation._client = client;
    try {
      cancellation.check();
      final installed = await packageInfo();
      if (installed.packageName.endsWith('.dev')) {
        throw const UpdateException(
          'Las actualizaciones están disponibles en la aplicación de producción.',
        );
      }
      final release = await _json(client, apiEndpoint);
      cancellation.check();
      if (release['draft'] != false || release['prerelease'] != false) {
        throw const UpdateException(
          'La release no es una versión estable publicada.',
        );
      }
      final tag = release['tag_name'] as String;
      if (compareVersions(tag, installed.version) <= 0) return null;
      final assets = (release['assets'] as List).cast<Map<String, dynamic>>();
      Map<String, dynamic> find(String name) {
        final matches = assets.where((asset) => asset['name'] == name).toList();
        if (matches.length != 1) {
          throw const UpdateException(
            'La release no contiene todos los archivos de actualización.',
          );
        }
        return matches.single;
      }

      final apk = find('mi-presupuesto-$tag.apk');
      final manifest = find('update.json');
      final json = await _json(
        client,
        assetUrl(manifest['browser_download_url']),
      );
      cancellation.check();
      final update = UpdateRelease.fromManifest(
        json,
        tag: tag,
        notes: release['body'] as String? ?? '',
        url: assetUrl(apk['browser_download_url']),
        assetName: apk['name'] as String,
        assetSize: apk['size'] as int,
      );
      if (update.buildNumber <= int.parse(installed.buildNumber)) {
        throw const UpdateException(
          'La versión publicada no tiene un número de compilación superior.',
        );
      }
      return update;
    } finally {
      client.close(force: true);
      cancellation._client = null;
    }
  }

  Future<File> download(
    UpdateRelease release,
    UpdateCancellation cancellation,
    void Function(DownloadProgress) onProgress,
  ) async {
    final client = clientFactory()..connectionTimeout = timeout;
    cancellation._client = client;
    File? file;
    IOSink? sink;
    var complete = false;
    try {
      cancellation.check();
      final directory = await _directory();
      cancellation.check();
      final name = 'update-${DateTime.now().microsecondsSinceEpoch}.apk';
      file = File('${directory.path}/$name.part');
      final request = await client
          .getUrl(assetUrl(release.url.toString()))
          .timeout(timeout);
      request.headers.set(
        HttpHeaders.userAgentHeader,
        'Mi-Presupuesto-Updater',
      );
      final response = await request.close().timeout(timeout);
      if (response.statusCode != 200 ||
          (response.contentLength >= 0 &&
              response.contentLength != release.size)) {
        throw const UpdateException('No se pudo descargar el APK esperado.');
      }
      sink = file.openWrite();
      final watch = Stopwatch()..start();
      var received = 0;
      var lastReport = 0;
      await for (final chunk in response.timeout(timeout)) {
        cancellation.check();
        received += chunk.length;
        if (received > release.size) {
          throw const UpdateException('El tamaño del APK no coincide.');
        }
        sink.add(chunk);
        // Flush provides backpressure without buffering an entire APK in memory.
        await sink.flush();
        if (watch.elapsedMilliseconds - lastReport >= 200 ||
            received == release.size) {
          lastReport = watch.elapsedMilliseconds;
          onProgress(
            DownloadProgress(
              received,
              release.size,
              received * 1000 / watch.elapsedMilliseconds.clamp(1, 1 << 40),
            ),
          );
        }
      }
      await sink.close();
      sink = null;
      cancellation.check();
      if (received != release.size ||
          (await sha256.bind(file.openRead()).first).toString() !=
              release.sha256) {
        throw const UpdateException(
          'El archivo descargado no pasó la verificación de integridad.',
        );
      }
      cancellation.check();
      // Android receives an .apk path only after the complete hash matches.
      file = await file.rename('${directory.path}/$name');
      cancellation.check();
      await channel.invokeMethod<void>('verify', {
        'path': file.path,
        'version': release.version,
        'buildNumber': release.buildNumber,
      });
      cancellation.check();
      complete = true;
      return file;
    } finally {
      client.close(force: true);
      cancellation._client = null;
      try {
        await sink?.close();
      } finally {
        if (!complete && file != null && await file.exists()) {
          await file.delete();
        }
      }
    }
  }

  Future<bool> canInstall() async =>
      await channel.invokeMethod<bool>('canInstall') ?? false;
  Future<void> requestInstallPermission() =>
      channel.invokeMethod<void>('permission');
  Future<void> install(File file, UpdateRelease release) =>
      channel.invokeMethod<void>('install', {
        'path': file.path,
        'version': release.version,
        'buildNumber': release.buildNumber,
      });
}
