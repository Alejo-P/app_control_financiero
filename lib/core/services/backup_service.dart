import 'package:control_financiero/core/database/backup_local_datasource.dart';
import 'package:control_financiero/core/models/backup_content.dart';
import 'package:control_financiero/core/models/operation_result.dart';
import 'package:control_financiero/core/utils/app_logger.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/core/utils/encryption_helper.dart';
import 'package:control_financiero/core/utils/file_utils.dart';
import 'package:control_financiero/features/categorias/data/categorias_local_datasource.dart';
import 'package:control_financiero/features/movimientos/data/movimientos_local_datasource.dart';
import 'package:control_financiero/features/notificaciones/data/notificacion_local_datasource.dart';
import 'package:control_financiero/features/presupuestos/data/presupuestos_local_datasource.dart';
import 'dart:convert';
import 'package:control_financiero/features/recordatorios/data/recordatorios_local_datasource.dart';
import 'package:control_financiero/features/tipo_categorias/data/tipo_categoria_local_datasource.dart';

enum BackupFileElement {
  /// The version of the backup file format.
  version,

  /// The initialization vector used for encryption.
  iv,

  /// The encrypted backup (content) data.
  data,
}

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
  final int backupVersion = 1;

  Future<bool> checkBackupfile(String filePath) async {
    try {
      final content = await FileUtils.readFile(filePath);
      final decoded = jsonDecode(content);

      if (decoded is! Map<String, dynamic>) {
        return false;
      }

      final int version = decoded[BackupFileElement.version.name] is int
          ? decoded[BackupFileElement.version.name] as int
          : 0;

      final bool hasData =
          decoded.containsKey(BackupFileElement.data.name) &&
          decoded[BackupFileElement.data.name] is String;

      return (version == backupVersion) && hasData;
    } catch (e) {
      return false;
    }
  }

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

  Future<OperationResult<void>> backupData(String key) async {
    final dir = await FileUtils.pickDirectory();
    if (dir == null) {
      return OperationResult(
        success: false,
        data: null,
        message: 'No se seleccionó ningún directorio para guardar el respaldo.',
      );
    }
    final fileName =
        'backup_${currentDateTime.year}_${currentDateTime.month.toString().padLeft(2, '0')}_${currentDateTime.day.toString().padLeft(2, '0')}.json';
    String outputFile = '$dir/$fileName';

    try {
      final backupData = await _collectDataForBackup();
      final jsonString = jsonEncode(backupData.toMap());
      final encrypted = EncryptionHelper.encryptData(jsonString, key);

      final fileContent = {
        BackupFileElement.version.name: backupVersion,
        BackupFileElement.iv.name: encrypted.iv,
        BackupFileElement.data.name: encrypted.data,
      };

      final result = await FileUtils.writeFile(
        outputFile,
        jsonEncode(fileContent),
      );
      if (!result) {
        throw Exception(
          'Error al escribir el archivo de respaldo en la ruta: $outputFile',
        );
      }

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

  Future<OperationResult<void>> restoreData(String key, String filePath) async {
    final isValidBackup = await checkBackupfile(filePath);
    if (!isValidBackup) {
      return OperationResult<void>(
        success: false,
        data: null,
        message: 'El archivo de respaldo no es válido.',
      );
    }

    try {
      final content = await FileUtils.readFile(filePath);
      final Map fileData = jsonDecode(content);

      final fileContent = EncryptionHelper.decryptData(
        encryptedText: fileData['data'],
        encryptKey: key,
        ivBase64: fileData['iv'],
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
    } on Exception catch (e) {
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
