import 'package:control_financiero/core/models/operation_result.dart';
import 'package:control_financiero/features/recordatorios/data/recordatorios_local_datasource.dart';
import 'package:control_financiero/features/recordatorios/models/detalle_recordatorio.dart';
import 'package:control_financiero/features/recordatorios/models/info_card_recordatorio.dart';
import 'package:control_financiero/features/recordatorios/models/recordatorio.dart';

class RecordatoriosRepository {
  final RecordatoriosLocalDataSource localDataSource;

  RecordatoriosRepository(this.localDataSource);

  ///Obtiene la lista de todos los recordatorios.
  ///@return Una lista de objetos Recordatorio.
  Future<List<Recordatorio>> fetchAllRecordatorios() async {
    return await localDataSource.fetchAllRecordatorios();
  }

  ///Obtiene la lista de todos los recordatorios.
  ///@return Una lista de objetos InfoCardRecordatorio para mostrar en la vista.
  Future<List<InfoCardRecordatorio>> fetchAllDetailedRecordatorios() async {
    return await localDataSource.fetchAllDetailedRecordatorios();
  }

  ///Obtiene un recordatorios por su ID.
  ///@param id El ID del recordatorio.
  ///@return Un objeto InfoCardRecordatorio para mostrar en la vista.
  Future<InfoCardRecordatorio?> fetchDetailedRecordatorioById(int id) async {
    return await localDataSource.fetchDetailedRecordatorioById(id);
  }

  ///Obtiene el detalle de un recordatorio por su ID.
  ///@param id El ID del recordatorio.
  ///@return Un objeto DetalleRecordatorio si se encuentra, de lo contrario null.
  Future<DetalleRecordatorio?> fetchDetalleRecordatorioById(int id) async {
    return await localDataSource.fetchDetalleRecordatorioById(id);
  }

  ///Inserta un nuevo recordatorio en la base de datos.
  ///@param recordatorio El objeto Recordatorio a insertar.
  ///@return Un objeto OperationResult que contiene el ID del recordatorio insertado si la operación fue exitosa, de lo contrario null.
  Future<OperationResult<int?>> insertRecordatorio(
    Recordatorio recordatorio,
  ) async {
    return await localDataSource.insertRecordatorio(recordatorio);
  }

  ///Actualiza un recordatorio existente en la base de datos.
  ///@param recordatorio El objeto Recordatorio a actualizar.
  ///@return Un objeto OperationResult que contiene informacion del recordatorio actualizado si la operación fue exitosa, de lo contrario null.
  Future<OperationResult<InfoCardRecordatorio?>> updateRecordatorio(
    Recordatorio recordatorio,
  ) async {
    final result = await localDataSource.updateRecordatorio(recordatorio);

    return OperationResult<InfoCardRecordatorio?>(
      success: result.success,
      message: result.message,
      data: result.success
          ? await localDataSource.fetchDetailedRecordatorioById(
              recordatorio.id!,
            )
          : null,
    );
  }

  ///Actualiza el estado habilitado de un recordatorio en la base de datos.
  ///@param id El ID del recordatorio a actualizar.
  ///@param enabled El nuevo estado habilitado.
  ///@return Un objeto OperationResult que contiene el número de filas actualizadas si la operación fue exitosa, de lo contrario null.
  Future<OperationResult<int?>> updateRecordatorioEnabled(
    int id,
    bool enabled,
  ) async {
    return await localDataSource.updateRecordatorioEnabled(id, enabled);
  }

  ///Elimina un recordatorio de la base de datos.
  ///@param id El ID del recordatorio a eliminar.
  ///@return Un objeto OperationResult que contiene el id del recordatorio eliminado si la operación fue exitosa, de lo contrario null.
  Future<OperationResult<int?>> deleteRecordatorio(int id) async {
    final result = await localDataSource.deleteRecordatorio(id);

    return OperationResult<int?>(
      message: result.message,
      success: result.success,
      data: result.success ? id : null,
    );
  }
}
