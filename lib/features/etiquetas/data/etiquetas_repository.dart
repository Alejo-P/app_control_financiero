import 'package:control_financiero/features/etiquetas/data/etiquetas_local_datasource.dart';
import 'package:control_financiero/features/etiquetas/models/etiqueta.dart';

class EtiquetasRepository {
  final EtiquetasLocalDataSource _localDataSource;

  EtiquetasRepository(this._localDataSource);

  Future<List<Etiqueta>> getAllEtiquetas() async {
    return await _localDataSource.getAllEtiquetas();
  }

  Future<int> insertEtiqueta(Etiqueta etiqueta) async {
    return await _localDataSource.insertEtiqueta(etiqueta);
  }

  Future<int> updateEtiqueta(Etiqueta etiqueta) async {
    return await _localDataSource.updateEtiqueta(etiqueta);
  }

  Future<int> deleteEtiqueta(int id) async {
    return await _localDataSource.deleteEtiqueta(id);
  }

  Future<int> assignEtiquetaToMovimiento(int movimientoId, int etiquetaId) async {
    return await _localDataSource.assignEtiquetaToMovimiento(movimientoId, etiquetaId);
  }

  Future<int> removeEtiquetaFromMovimiento(int movimientoId, int etiquetaId) async {
    return await _localDataSource.removeEtiquetaFromMovimiento(movimientoId, etiquetaId);
  }

  Future<List<Etiqueta>> getEtiquetasForMovimiento(int movimientoId) async {
    return await _localDataSource.getEtiquetasForMovimiento(movimientoId);
  }
}
