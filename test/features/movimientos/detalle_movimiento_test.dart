import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/features/movimientos/models/detalle_movimiento.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> movementMap() => {
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
      expect(detalle.amount, 42.5);
      expect(detalle.date, DateTime(2026, 8, 7));
      expect(detalle.note, 'Compra semanal');
      expect(detalle.categoryName, 'Alimentación');
      expect(detalle.categoryIcon, Icons.shopping_cart);
      expect(detalle.categoryColor, const Color(0xFF2E7D32));
      expect(detalle.categoryId, 9);
      expect(detalle.movementType, TipoMovimiento.gasto);
      expect(detalle.time, const TimeOfDay(hour: 10, minute: 30));
    });

    test('mapea ingresos y admite campos opcionales ausentes', () {
      final detalle = DetalleMovimiento.fromMap({
        'title': 'Sueldo',
        'amount': 1500.0,
        'movement_type': 'ingreso',
        'date': '2026-09-01',
      });
      expect(detalle.movementType, TipoMovimiento.ingreso);
      expect(detalle.id, isNull);
      expect(detalle.categoryId, isNull);
      expect(detalle.categoryName, isNull);
      expect(detalle.categoryColor, isNull);
      expect(detalle.categoryIcon, Icons.category);
      expect(detalle.time, isNull);
      expect(detalle.note, isEmpty);
    });

    test('usa ayuda para un nombre de icono desconocido', () {
      final detalle = DetalleMovimiento.fromMap({
        ...movementMap(),
        'category_icon': 'icono_inexistente',
      });
      expect(detalle.categoryIcon, Icons.help_outline);
    });
  });

  group('DetalleMovimiento.toMap', () {
    test('exporta las claves actuales del modelo', () {
      final detalle = DetalleMovimiento.fromMap(movementMap());
      // Este mapa de exportación usa claves distintas al SELECT de SQLite.
      expect(detalle.toMap(), {
        'id': 1,
        'titulo': 'Supermercado',
        'monto': 42.5,
        'tipoMovimiento': 'gasto',
        'fecha': '2026-08-07T00:00:00.000',
        'nota': 'Compra semanal',
        'categoriaIcono': 'shopping_cart',
        'categoriaColor': 0xFF2E7D32,
        'categoria': 'Alimentación',
        'time': '10:30',
        'categoriaId': 9,
      });
    });

    test('exporta ingresos sin categoría, hora ni nota', () {
      final detalle = DetalleMovimiento.fromMap({
        'title': 'Sueldo',
        'amount': 1500.0,
        'movement_type': 'ingreso',
        'date': '2026-09-01',
      });
      expect(detalle.toMap(), {
        'id': null,
        'titulo': 'Sueldo',
        'monto': 1500.0,
        'tipoMovimiento': 'ingreso',
        'fecha': '2026-09-01T00:00:00.000',
        'nota': '',
        // Icons.category no está registrado en el mapa inverso actual.
        'categoriaIcono': 'category',
        'categoriaColor': null,
        'categoria': null,
        'time': null,
        'categoriaId': null,
      });
    });
  });

  group('DetalleMovimiento.copyWith e igualdad', () {
    test('una copia sin cambios conserva todos los valores y la igualdad', () {
      final original = DetalleMovimiento.fromMap(movementMap());
      final copy = original.copyWith();
      expect(copy, original);
      expect(copy.hashCode, original.hashCode);
      expect(copy, isNot(same(original)));
    });

    test('sustituye todos los campos sin modificar el original', () {
      final original = DetalleMovimiento.fromMap(movementMap());
      final updated = original.copyWith(
        id: 2,
        title: 'Sueldo',
        amount: 1500,
        movementType: TipoMovimiento.ingreso,
        date: DateTime(2026, 9, 1),
        categoryName: 'Trabajo',
        categoryIcon: Icons.home,
        categoryColor: Colors.blue,
        categoryId: 10,
        time: const TimeOfDay(hour: 9, minute: 5),
        note: '',
      );
      expect(
        updated,
        DetalleMovimiento(
          id: 2,
          title: 'Sueldo',
          amount: 1500,
          movementType: TipoMovimiento.ingreso,
          date: DateTime(2026, 9, 1),
          categoryName: 'Trabajo',
          categoryIcon: Icons.home,
          categoryColor: Colors.blue,
          categoryId: 10,
          time: const TimeOfDay(hour: 9, minute: 5),
          note: '',
        ),
      );
      expect(original, DetalleMovimiento.fromMap(movementMap()));
    });

    test('cada campo participa en la detección de cambios', () {
      final original = DetalleMovimiento.fromMap(movementMap());
      final changes = {
        'id': original.copyWith(id: 2),
        'title': original.copyWith(title: 'Otro'),
        'amount': original.copyWith(amount: 0),
        'movementType': original.copyWith(movementType: TipoMovimiento.ingreso),
        'date': original.copyWith(date: DateTime(2027)),
        'categoryName': original.copyWith(categoryName: 'Otra'),
        'categoryIcon': original.copyWith(categoryIcon: Icons.home),
        'categoryColor': original.copyWith(categoryColor: Colors.blue),
        'categoryId': original.copyWith(categoryId: 10),
        'time': original.copyWith(time: const TimeOfDay(hour: 0, minute: 0)),
        'note': original.copyWith(note: ''),
      };
      for (final change in changes.entries) {
        expect(change.value, isNot(original), reason: change.key);
      }
    });
  });
}
