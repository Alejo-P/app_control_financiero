import 'package:control_financiero/core/models/operation_result.dart';
import 'package:control_financiero/core/utils/app_logger.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/core/utils/file_utils.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';

class ExcelExporter {
  // Agrupar cada transaccion registrada por mes (para separarlo por tablas y tabs)
  static Map<String, List<Map<String, dynamic>>> agruparPorMes(List data) {
    Map<String, List<Map<String, dynamic>>> resultado = {};

    for (var item in data) {
      DateTime fecha = DateTime.parse(item["Fecha transaccion"]);
      String clave = "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}";

      if (!resultado.containsKey(clave)) {
        resultado[clave] = [];
      }

      resultado[clave]!.add(item);
    }

    return resultado;
  }

  // Preparar el contenido que se escribira en el archivo
  static Excel crearExcel(Map<String, List<Map<String, dynamic>>> datosPorMes) {
    final excel = Excel.createExcel();
    excel.delete('Sheet1');

    final keysOrdenadas = datosPorMes.keys.toList()..sort();
    for (var mes in keysOrdenadas) {
      final registros = datosPorMes[mes]!;
      Sheet sheet = excel[mes];

      // Encabezados
      sheet.appendRow([
        'Concepto',
        'Cantidad',
        'Fecha',
        'Categoría',
        'Tipo',
        'Descripción',
      ]);

      // Datos
      for (var item in registros) {
        sheet.appendRow([
          item['Concepto'],
          item['Cantidad'],
          item['Fecha transaccion'],
          item['Categoria'],
          item['Tipo movimiento'],
          item['Descripcion'] ?? '',
        ]);
      }

      double total = registros.fold(
        0.0,
        (sum, item) => sum + (item['Cantidad'] as num).toDouble(),
      );
      sheet.appendRow([]);
      sheet.appendRow(['TOTAL', total]);
    }

    return excel;
  }

  static Future<OperationResult> guardarExcel(Excel excel) async {
    try {
      //Directory directory = Directory('/storage/emulated/0/Download');
      String? directory = await FileUtils.pickDirectory();

      final now = currentDateTime;
      final fileName = "reporte_${now.year}_${now.month}_${now.day}.xlsx";
      final path = "$directory/$fileName";

      final fileBytes = excel.encode();

      await FileUtils.writeFileBytes(path, fileBytes!);

      return OperationResult<void>(
        success: true,
        message: "Archivo creado correctamente",
      );
    } catch (e) {
      await AppLogger.log("Error al guardar Excel: $e", level: LogLevel.error);

      return OperationResult<void>(
        success: false,
        message: "Error al guardar archivo",
      );
    }
  }

  static Future<OperationResult> exportarExcel(List data) async {
    final agrupado = agruparPorMes(data);
    final excel = crearExcel(agrupado);
    final result = await guardarExcel(excel);

    return result;
  }

  String nombreMes(DateTime fecha) {
    return DateFormat('MMMM yyyy', 'es_ES').format(fecha);
  }
}
