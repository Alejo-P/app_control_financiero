import 'package:control_financiero/core/database/backup_local_datasource.dart';
import 'package:control_financiero/core/models/backup_content.dart';
import 'package:control_financiero/core/models/operation_result.dart';
import 'package:control_financiero/core/utils/app_logger.dart';
import 'package:control_financiero/core/utils/backup_file_writer.dart';
import 'package:control_financiero/core/utils/backup_cipher.dart';
import 'package:flutter/foundation.dart';
import 'package:control_financiero/core/utils/file_utils.dart';
import 'package:control_financiero/features/categorias/data/categorias_local_datasource.dart';
import 'package:control_financiero/features/movimientos/data/movimientos_local_datasource.dart';
import 'package:control_financiero/features/notificaciones/data/notificacion_local_datasource.dart';
import 'package:control_financiero/features/presupuestos/data/presupuestos_local_datasource.dart';
import 'dart:convert';
import 'package:control_financiero/features/recordatorios/data/recordatorios_local_datasource.dart';
import 'package:control_financiero/features/tipo_categorias/data/tipo_categoria_local_datasource.dart';

class BackupService {
  final MovimientosLocalDataSource _movimientosLocalDataSource =
      MovimientosLocalDataSource();
  final CategoriasLocalDataSource _categoriasLocalDataSource =
      CategoriasLocalDataSource();
  final TipoCategoriaLocalDataSource _tipoCategoriaLocalDataSource =
      TipoCategoriaLocalDataSource();
  final PresupuestosLocalDataSource _presupuestosLocalDataSource =
      PresupuestosLocalDataSource();
  final NotificacionLocalDataSource _notificacionLocalDataSource =
      NotificacionLocalDataSource();
  final RecordatoriosLocalDataSource _recordatoriosLocalDataSource =
      RecordatoriosLocalDataSource();
  Future<String?> validateBackupFile(String filePath) async {
    try {
      BackupCipher.validate(jsonDecode(await FileUtils.readFile(filePath)));
      return null;
    } on FormatException catch (e) {
      return e.message;
    } catch (_) {
      return 'No se pudo leer el archivo de respaldo.';
    }
  }

  Future<bool> checkBackupfile(String filePath) async =>
      await validateBackupFile(filePath) == null;

  Future<BackupContent> _collectDataForBackup() async {
    final movimientos = await _movimientosLocalDataSource.fetchAllMovimientos();
    final categorias = await _categoriasLocalDataSource.fetchAllCategorias();
    final tipoCategorias = await _tipoCategoriaLocalDataSource
        .fetchTipoCategorias();
    final presupuestos = await _presupuestosLocalDataSource
        .fetchAllPresupuestos();
    final ingresosPresupuestados = await _presupuestosLocalDataSource
        .fetchAllIngresosPresupuestados();
    final configPorcentajeNotif = await _notificacionLocalDataSource
        .fetchAllBudgetNotifications();
    final movementNotificationConfigs = await _notificacionLocalDataSource
        .fetchAllMovementNotificationConfigs();
    final recordatorios = await _recordatoriosLocalDataSource
        .fetchAllRecordatorios();

    return BackupContent(
      budgetIncomeData: ingresosPresupuestados.map((i) => i.toMap()).toList(),
      budgetsData: presupuestos.map((p) => p.toMap()).toList(),
      categoriesData: categorias.map((c) => c.toMap()).toList(),
      categoryTypesData: tipoCategorias.map((ct) => ct.toMap()).toList(),
      movementsData: movimientos.map((m) => m.toMap()).toList(),
      notifitionsData: configPorcentajeNotif.map((n) => n.toMap()).toList(),
      movementNotificationConfigsData: movementNotificationConfigs
          .map((config) => config.toMap())
          .toList(),
      remindersData: recordatorios.map((r) => r.toMap()).toList(),
    );
  }

  Future<OperationResult<void>> backupData(String password) async {
    final dir = await FileUtils.pickDirectory();
    if (dir == null) {
      return OperationResult(
        success: false,
        data: null,
        message: 'No se seleccionó ningún directorio para guardar el respaldo.',
      );
    }
    try {
      final backupData = await _collectDataForBackup();
      final jsonString = jsonEncode(backupData.toMap());
      final fileContent = await compute(
        (List<String> args) => BackupCipher.encrypt(args[0], args[1]),
        [jsonString, password],
      );

      await BackupFileWriter.write(dir, jsonEncode(fileContent));

      return OperationResult(
        success: true,
        data: null,
        message: 'Respaldo creado correctamente',
      );
    } catch (e) {
      await AppLogger.log('Error al crear respaldo: $e', level: LogLevel.error);
      return OperationResult(
        success: false,
        data: null,
        message: 'Error al crear respaldo',
      );
    }
  }

  Future<OperationResult<void>> restoreData(
    String password,
    String filePath,
  ) async {
    try {
      final content = await FileUtils.readFile(filePath);
      final fileContent = await compute(
        (List<String> args) =>
            BackupCipher.decrypt(jsonDecode(args[0]), args[1]),
        [content, password],
      );
      final backupData = jsonDecode(fileContent) as Map<String, dynamic>;
      final backupContent = BackupContent.fromMap(backupData);

      final restoreResult = await BackupLocalDatasource().restoreDataFromBackup(
        backupContent,
      );

      return OperationResult<void>(
        success: restoreResult.success,
        data: null,
        message: restoreResult.message,
      );
    } on FormatException catch (e) {
      return OperationResult<void>(
        success: false,
        data: null,
        message: e.message,
      );
    } catch (e) {
      await AppLogger.log(
        'Error al restaurar datos: $e',
        level: LogLevel.error,
      );
      return OperationResult<void>(
        success: false,
        data: null,
        message: 'Error al restaurar los datos',
      );
    }
  }
}
