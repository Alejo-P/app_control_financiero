import 'package:control_financiero/features/movimientos/models/detalle_movimiento.dart';

class MovimientoSearchPageResult {
  final List<DetalleMovimiento> movimientos;
  final int total;
  final int page;

  const MovimientoSearchPageResult({
    required this.movimientos,
    required this.total,
    required this.page,
  });
}
