import 'package:control_financiero/core/constants/app_strings.dart'
    as app_strings;
import 'package:control_financiero/core/models/operation_result.dart';
import 'package:control_financiero/core/utils/app_logger.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/core/utils/file_utils.dart';
import 'package:control_financiero/features/categorias/data/categorias_local_datasource.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';
import 'package:control_financiero/features/movimientos/data/movimientos_local_datasource.dart';
import 'package:control_financiero/features/movimientos/models/movimiento.dart';
import 'package:control_financiero/features/notificaciones/data/notificacion_local_datasource.dart';
import 'package:control_financiero/features/notificaciones/models/budget_notification.dart';
import 'package:control_financiero/features/presupuestos/data/presupuestos_local_datasource.dart';
import 'package:control_financiero/features/presupuestos/models/ingreso_presupuestado.dart';
import 'dart:convert';
import 'package:control_financiero/features/presupuestos/models/presupuesto.dart';

class BackupService {
  final MovimientosLocalDataSource _movimientosLocalDataSource =
      MovimientosLocalDataSource();
  final CategoriasLocalDataSource _categoriasLocalDataSource =
      CategoriasLocalDataSource();
  final PresupuestosLocalDataSource _presupuestosLocalDataSource =
      PresupuestosLocalDataSource();
  final NotificacionLocalDataSource _notificacionLocalDataSource =
      NotificacionLocalDataSource();
  final int backupVersion = 1;

  bool _checkBackupVersion(int version) {
    // Implementa la lógica para verificar la compatibilidad de versiones aquí
    // Por ejemplo, podrías comparar con una versión mínima soportada

    return version == backupVersion;
  }

  Future<Map<String, dynamic>> _collectDataForBackup() async {
    final movimientos = await _movimientosLocalDataSource.fetchAllMovimientos();
    final categorias = await _categoriasLocalDataSource.fetchAllCategorias();
    final presupuestos = await _presupuestosLocalDataSource
        .fetchAllPresupuestos();
    final ingresosPresupuestados = await _presupuestosLocalDataSource
        .fetchAllIngresosPresupuestados();
    final configPorcentajeNotif = await _notificacionLocalDataSource
        .fetchAllBudgetNotifications();

    return {
      'movimientos': movimientos.map((m) => m.toMap()).toList(),
      'categorias': categorias.map((c) => c.toMap()).toList(),
      'presupuestos': presupuestos.map((p) => p.toMap()).toList(),
      'ingresosPresupuestados': ingresosPresupuestados
          .map((i) => i.toMap())
          .toList(),
      'configPorcentajeNotif': configPorcentajeNotif
          .map((n) => n.toMap())
          .toList(),
    };
  }

  Future<void> _clearExistingData() async {
    await _movimientosLocalDataSource.deleteAllMovimientos();
    await _presupuestosLocalDataSource.deleteAllPresupuestos();
    await _presupuestosLocalDataSource.deleteAllIngresosPresupuestados();
    await _notificacionLocalDataSource.deleteAllBudgetNotifications();
    await _notificacionLocalDataSource.deleteAllBudgetNotificationEvent();
    await _categoriasLocalDataSource.deleteAllCategorias();
  }

  Future<bool> _restoreDataFromBackup(Map<String, dynamic> backupData) async {
    try {
      final movimientosData = (backupData['movimientos'] ?? []) as List;
      final categoriasData = (backupData['categorias'] ?? []) as List;
      final presupuestosData = (backupData['presupuestos'] ?? []) as List;
      final ingresosPresupuestadosData =
          (backupData['ingresosPresupuestados'] ?? []) as List;
      final configPorcentajeNotifData =
          (backupData['configPorcentajeNotif'] ?? []) as List;

      for (final categoriaMap in categoriasData) {
        await _categoriasLocalDataSource.addCategoria(
          Categoria.fromMap(categoriaMap as Map<String, dynamic>),
        );
      }

      for (final configMap in configPorcentajeNotifData) {
        await _notificacionLocalDataSource.insertOrUpdateBudgetNotification(
          BudgetNotification.fromMap(configMap as Map<String, dynamic>),
        );
      }

      for (final ingresoPresupuestadoMap in ingresosPresupuestadosData) {
        await _presupuestosLocalDataSource.upsertIngresoPresupuestado(
          IngresoPresupuestado.fromMap(
            ingresoPresupuestadoMap as Map<String, dynamic>,
          ),
        );
      }

      for (final movimientoMap in movimientosData) {
        await _movimientosLocalDataSource.addMovimiento(
          Movimiento.fromMap(movimientoMap as Map<String, dynamic>),
        );
      }

      for (final presupuestoMap in presupuestosData) {
        await _presupuestosLocalDataSource.addPresupuesto(
          Presupuesto.fromMap(presupuestoMap as Map<String, dynamic>),
        );
      }

      return true;
    } on Exception catch (e) {
      AppLogger.log('Error al restaurar datos: $e', level: LogLevel.error);
      return false;
    }
  }

  Future<OperationResult<void>> backupData() async {
    try {
      final backupData = await _collectDataForBackup();

      final fileContent = {
        'version': backupVersion,
        'timestamp': DateTime.now().toIso8601String(),
        'app': app_strings.appName,
        'data': backupData,
      };

      final jsonString = jsonEncode(fileContent);

      final dir = await FileUtils.pickDirectory();
      if (dir == null) {
        return OperationResult(
          success: false,
          data: null,
          message:
              'No se seleccionó ningún directorio para guardar el respaldo.',
        );
      }
      final fileName =
          'backup_${currentDateTime.year}_${currentDateTime.month.toString().padLeft(2, '0')}_${currentDateTime.day.toString().padLeft(2, '0')}.json';
      String? outputFile = '$dir/$fileName';

      await FileUtils.writeFile(outputFile, jsonString);

      return OperationResult(
        success: true,
        data: null,
        message: 'Respaldo creado correctamente',
      );
    } catch (e) {
      AppLogger.log('Error al crear respaldo: $e', level: LogLevel.error);
      return OperationResult(
        success: false,
        data: null,
        message: 'Error al crear respaldo',
      );
    }
  }

  Future<OperationResult<void>> restoreData() async {
    final pickedFile = await FileUtils.pickFiles(['json']);
    if (pickedFile == null) {
      return OperationResult(
        success: false,
        data: null,
        message: 'No se seleccionó ningún archivo de respaldo.',
      );
    }

    try {
      final content = await FileUtils.readFile(pickedFile);
      final Map<String, dynamic> fileData = jsonDecode(content);
      final int version = fileData['version'] != null
          ? fileData['version'] as int
          : 0;
      if (!_checkBackupVersion(version)) {
        throw Exception(
          'Versión de respaldo no compatible. Versión encontrada: $version',
        );
      }

      final backupData = fileData['data'] as Map<String, dynamic>;
      await _clearExistingData();
      final restoreSuccess = await _restoreDataFromBackup(backupData);
      if (!restoreSuccess) {
        throw Exception('Error al restaurar los datos del respaldo.');
      }

      return OperationResult<void>(
        success: true,
        data: null,
        message: 'Restauración de datos completada exitosamente.',
      );
    } on Exception catch (e) {
      AppLogger.log('Error al restaurar datos: $e', level: LogLevel.error);
      return OperationResult<void>(
        success: false,
        data: null,
        message: 'Error al restaurar los datos',
      );
    }
  }
}
