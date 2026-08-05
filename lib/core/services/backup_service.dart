import 'package:control_financiero/core/models/operation_result.dart';
import 'package:control_financiero/core/utils/app_logger.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/core/utils/encryption_helper.dart';
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
import 'package:control_financiero/features/recordatorios/data/recordatorios_local_datasource.dart';
import 'package:control_financiero/features/recordatorios/models/recordatorio.dart';

class BackupService {
  final MovimientosLocalDataSource _movimientosLocalDataSource =
      MovimientosLocalDataSource();
  final CategoriasLocalDataSource _categoriasLocalDataSource =
      CategoriasLocalDataSource();
  final PresupuestosLocalDataSource _presupuestosLocalDataSource =
      PresupuestosLocalDataSource();
  final NotificacionLocalDataSource _notificacionLocalDataSource =
      NotificacionLocalDataSource();
  final RecordatoriosLocalDataSource _recordatoriosLocalDataSource =
      RecordatoriosLocalDataSource();
  final int backupVersion = 1;

  Future<bool> checkBackupfile(String filePath) async {
    try {
      final content = await FileUtils.readFile(filePath);
      final decoded = jsonDecode(content);

      if (decoded is! Map<String, dynamic>) {
        return false;
      }

      final int version = decoded['version'] is int
          ? decoded['version'] as int
          : 0;

      return version == backupVersion;
    } catch (e) {
      return false;
    }
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
    final recordatorios = await _recordatoriosLocalDataSource
        .fetchAllRecordatoriosBackup();

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
      'recordatorios': recordatorios.map((r) => r.toMap()).toList(),
    };
  }

  Future<void> _clearExistingData() async {
    await _recordatoriosLocalDataSource.deleteAllRecordatorios();
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
      final recordatoriosData = (backupData['recordatorios'] ?? []) as List;
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

      for (final recordatorioMap in recordatoriosData) {
        await _recordatoriosLocalDataSource.insertRecordatorio(
          Recordatorio.fromMap(recordatorioMap as Map<String, dynamic>),
        );
      }

      return true;
    } on Exception catch (e) {
      AppLogger.log('Error al restaurar datos: $e', level: LogLevel.error);
      return false;
    }
  }

  Future<OperationResult<void>> backupData(String key) async {
    try {
      final backupData = await _collectDataForBackup();
      final jsonString = jsonEncode(backupData);
      final encrypted = EncryptionHelper.encryptData(jsonString, key);

      final fileContent = {
        'version': backupVersion,
        'iv': encrypted.iv,
        'data': encrypted.data,
      };

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

      await FileUtils.writeFile(outputFile, jsonEncode(fileContent));

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

  Future<OperationResult<void>> restoreData(String key, String filePath) async {
    try {
      final content = await FileUtils.readFile(filePath);

      final Map fileData = jsonDecode(content);

      final fileContent = EncryptionHelper.decryptData(
        encryptedText: fileData['data'],
        encryptKey: key,
        ivBase64: fileData['iv'],
      );
      final backupData = jsonDecode(fileContent) as Map<String, dynamic>;

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
