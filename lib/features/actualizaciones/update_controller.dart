import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'update_release.dart';
import 'update_service.dart';

enum UpdatePhase {
  checking,
  available,
  downloading,
  ready,
  current,
  failed,
  cancelled,
}

class UpdateController extends ChangeNotifier {
  UpdateController(this.service);
  final UpdateService service;
  UpdatePhase phase = UpdatePhase.checking;
  UpdateRelease? release;
  DownloadProgress? progress;
  String? error;
  File? _file;
  UpdateCancellation? _operation;
  bool _disposed = false;
  bool installing = false;
  bool _waitingForPermission = false;

  void _emit() {
    if (!_disposed) notifyListeners();
  }

  bool _active(UpdateCancellation token) => !_disposed && !token.cancelled;
  String _message(Object failure) {
    if (failure is UpdateException) return failure.message;
    if (failure is PlatformException) {
      return failure.message ?? 'No se pudo abrir el instalador.';
    }
    if (failure is TimeoutException ||
        failure is SocketException ||
        failure is HttpException) {
      return 'No se pudo completar la conexión. Revise su internet e inténtelo de nuevo.';
    }
    return 'No se pudo procesar la actualización. Inténtelo de nuevo.';
  }

  Future<void> check() async {
    _operation?.cancel();
    final token = _operation = UpdateCancellation();
    phase = UpdatePhase.checking;
    error = null;
    _emit();
    try {
      final result = await service.check(token);
      if (!_active(token)) return;
      release = result;
      phase = result == null ? UpdatePhase.current : UpdatePhase.available;
    } catch (failure) {
      if (!_active(token)) return;
      error = _message(failure);
      phase = UpdatePhase.failed;
    }
    _emit();
  }

  Future<void> download() async {
    if (phase != UpdatePhase.available || release == null) return;
    final token = _operation = UpdateCancellation();
    phase = UpdatePhase.downloading;
    progress = null;
    error = null;
    _emit();
    try {
      final file = await service.download(release!, token, (value) {
        if (_active(token)) {
          progress = value;
          _emit();
        }
      });
      if (!_active(token)) {
        if (await file.exists()) await file.delete();
        return;
      }
      _file = file;
      phase = UpdatePhase.ready;
    } catch (failure) {
      if (!_active(token)) return;
      error = _message(failure);
      phase = UpdatePhase.failed;
    }
    _emit();
  }

  /// Inactive/hidden/paused all cancel network work; permission settings are
  /// opened only once the file is ready and therefore never cancel that APK.
  void leaveForeground() {
    if (phase == UpdatePhase.downloading || phase == UpdatePhase.checking) {
      cancel();
    }
  }

  void cancel() {
    _operation?.cancel();
    if (phase == UpdatePhase.downloading || phase == UpdatePhase.checking) {
      phase = UpdatePhase.cancelled;
      _emit();
    }
  }

  Future<void> resume() async {
    if (!_waitingForPermission || _disposed) return;
    _waitingForPermission = false;
    try {
      if (await service.canInstall()) {
        if (!_disposed) await install();
      } else if (!_disposed) {
        error =
            'No se autorizó la instalación. Pulse «Instalar» para intentarlo de nuevo.';
        _emit();
      }
    } catch (failure) {
      if (!_disposed) {
        error = _message(failure);
        _emit();
      }
    }
  }

  Future<void> install() async {
    if (_disposed ||
        phase != UpdatePhase.ready ||
        installing ||
        _file == null) {
      return;
    }
    installing = true;
    error = null;
    _emit();
    try {
      final permitted = await service.canInstall();
      if (_disposed) return;
      if (!permitted) {
        if (_waitingForPermission) return;
        _waitingForPermission = true;
        await service.requestInstallPermission();
        if (!_disposed) {
          error =
              'Autorice «Permitir desde esta fuente» para instalar. Si no lo autoriza, puede intentarlo después.';
        }
      } else {
        _waitingForPermission = false;
        await service.install(_file!, release!);
      }
    } catch (failure) {
      _waitingForPermission = false;
      error = _message(failure);
    } finally {
      installing = false;
      _emit();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _operation?.cancel();
    super.dispose();
  }
}
