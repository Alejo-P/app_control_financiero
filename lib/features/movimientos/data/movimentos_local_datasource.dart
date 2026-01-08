import 'package:control_financiero/features/movimientos/models/movimiento.dart';

class MovimientosLocalDataSource {
  final List<Movimiento> _movimientos = [];

  Future<List<Movimiento>> fetchMovimientos() async {
    // Simula una llamada a una base de datos local o almacenamiento.
    return _movimientos;
  }

  Future<bool> addMovimiento(Movimiento movimiento) async {
    _movimientos.add(movimiento);
    return true;
  }

  Future<bool> updateMovimiento(Movimiento movimiento) async {
    final index = _movimientos.indexWhere((m) => m.id == movimiento.id);
    if (index != -1) {
      _movimientos[index] = movimiento;
      return true;
    }
    return false;
  }

  Future<bool> deleteMovimiento(String id) async {
    final index = _movimientos.indexWhere((m) => m.id == id);
    if (index != -1) {
      _movimientos.removeAt(index);
      return true;
    }
    return false;
  }
}