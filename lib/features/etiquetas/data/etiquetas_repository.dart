import 'package:control_financiero/core/models/operation_result.dart';
import 'package:control_financiero/features/etiquetas/data/etiquetas_local_datasource.dart';
import 'package:control_financiero/features/etiquetas/models/etiqueta.dart';

class EtiquetasRepository {
  final EtiquetasLocalDataSource _localDataSource;

  EtiquetasRepository(this._localDataSource);

  Future<List<Etiqueta>> getAllEtiquetas() async {
    return await _localDataSource.getAllEtiquetas();
  }

  Future<OperationResult> insertEtiqueta(Etiqueta etiqueta) async {
    final id = await _localDataSource.insertEtiqueta(etiqueta);

    return OperationResult<int>(
      success: id > 0,
      data: id > 0 ? id : null,
      message: id > 0 ? 'Etiqueta creada' : 'No se pudo crear la etiqueta',
    );
  }

  Future<OperationResult> updateEtiqueta(Etiqueta etiqueta) async {
    final result = await _localDataSource.updateEtiqueta(etiqueta);

    return OperationResult<int>(
      success: result > 0,
      data: result > 0 ? result : null,
      message: result > 0
          ? 'Etiqueta actualizada'
          : 'No se pudo actualizar la etiqueta',
    );
  }

  Future<OperationResult> deleteEtiqueta(int id) async {
    final result = await _localDataSource.deleteEtiqueta(id);

    return OperationResult<int>(
      success: result > 0,
      data: result > 0 ? result : null,
      message: result > 0
          ? 'Etiqueta eliminada'
          : 'No se pudo eliminar la etiqueta',
    );
  }

  Future<int> assignEtiquetaToMovimiento(
    int movimientoId,
    int etiquetaId,
  ) async {
    return await _localDataSource.assignEtiquetaToMovimiento(
      movimientoId,
      etiquetaId,
    );
  }

  Future<int> removeEtiquetaFromMovimiento(
    int movimientoId,
    int etiquetaId,
  ) async {
    return await _localDataSource.removeEtiquetaFromMovimiento(
      movimientoId,
      etiquetaId,
    );
  }

  Future<List<Etiqueta>> getEtiquetasForMovimiento(int movimientoId) async {
    return await _localDataSource.getEtiquetasForMovimiento(movimientoId);
  }
}
