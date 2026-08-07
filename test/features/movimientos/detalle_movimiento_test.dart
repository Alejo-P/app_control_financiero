import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/features/movimientos/models/detalle_movimiento.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DetalleMovimiento.fromMap', () {
    test('mapea category_id desde la clave correcta del SELECT de SQLite', () {
      final map = {
        'id': 1,
        'title': 'Supermercado',
        'amount': 42.5,
        'movement_type': 'gasto',
        'date': '2026-08-07',
        'note': 'Compra semanal',
        'category_icon': 'shopping_cart',
        'category_color': 0xFF2E7D32,
        'category_name': 'Alimentación',
        'time': '10:30',
        'category_id': 9,
      };

      final detalle = DetalleMovimiento.fromMap(map);

      expect(detalle.id, 1);
      expect(detalle.title, 'Supermercado');
      expect(detalle.categoryId, 9);
      expect(detalle.movementType, TipoMovimiento.gasto);
      expect(detalle.time, const TimeOfDay(hour: 10, minute: 30));
    });
  });
}
