import 'package:control_financiero/core/utils/app_logger.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class FileUtils {
  static Future<String?> pickFiles(
    List<String> fileExtensions, {
    bool multipleFiles = false,
  }) async {
    final result = await FilePicker.pickFiles(
      allowMultiple: multipleFiles,
      type: FileType.custom,
      allowedExtensions: fileExtensions,
    );

    if (result != null && result.files.single.path != null) {
      return result.files.single.path!;
    }

    return null;
  }

  static Future<String?> pickDirectory() async {
    final result = await FilePicker.getDirectoryPath();
    return result;
  }

  static Future<String> readFile(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw Exception(
        'Archivo de respaldo no encontrado en la ruta: $filePath',
      );
    }
    final content = await file.readAsString();
    return content;
  }

  static Future<bool> writeFile(
    String filePath,
    String content, {
    FileMode mode = FileMode.write,
  }) async {
    try {
      final file = File(filePath);
      await file.create(recursive: true);
      await file.writeAsString(content, mode: mode, flush: true);
      return true;
    } on Exception catch (e) {
      await AppLogger.log(
        'Error al escribir el archivo: $e',
        level: LogLevel.error,
      );
      return false;
    }
  }

  static Future<bool> writeFileBytes(
    String filePath,
    List<int> content, {
    FileMode mode = FileMode.write,
  }) async {
    try {
      final file = File(filePath);
      await file.create(recursive: true);
      await file.writeAsBytes(content, mode: mode, flush: true);
      return true;
    } on Exception catch (e) {
      await AppLogger.log(
        'Error al escribir el archivo: $e',
        level: LogLevel.error,
      );
      return false;
    }
  }
}
