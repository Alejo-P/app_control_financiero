import 'package:control_financiero/features/recordatorios/models/info_card_recordatorio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> reminderMap() => {
    'id': 7,
    'title': 'Pagar alimentos',
    'category_name': 'Alimentación',
    'category_icon': 'shopping_cart',
    'category_color': 0xFF2E7D32,
    'is_enabled': 1,
    'is_default': 1,
    'category_id': 3,
    'scheduled_at': '2026-09-14T20:30:00',
    'recurrency': 'diario',
  };

  group('InfoCardRecordatorio.fromMap', () {
    test('convierte los datos de SQLite para la tarjeta', () {
      final reminder = InfoCardRecordatorio.fromMap(reminderMap());
      expect(reminder.id, 7);
      expect(reminder.title, 'Pagar alimentos');
      expect(reminder.categoryName, 'Alimentación');
      expect(reminder.categoryIcon, Icons.shopping_cart);
      expect(reminder.categoryColor, const Color(0xFF2E7D32));
      expect(reminder.isEnabled, isTrue);
      expect(reminder.isDefault, isTrue);
      expect(reminder.scheduledAt, DateTime(2026, 9, 14, 20, 30));
      expect(reminder.recurrency, 'Diario');
      expect(reminder.categoryId, 3);
    });

    test('admite un recordatorio sin categoría ni id y desactivado', () {
      final reminder = InfoCardRecordatorio.fromMap({
        ...reminderMap(),
        'id': null,
        'category_name': null,
        'category_icon': null,
        'category_color': null,
        'category_id': null,
        'is_enabled': 0,
        'is_default': 0,
      });
      expect(reminder.id, isNull);
      expect(reminder.categoryName, isNull);
      expect(reminder.categoryIcon, isNull);
      expect(reminder.categoryColor, isNull);
      expect(reminder.isEnabled, isFalse);
      expect(reminder.isDefault, isFalse);
      expect(reminder.categoryId, isNull);
    });

    test('usa ayuda para un icono desconocido', () {
      final reminder = InfoCardRecordatorio.fromMap({
        ...reminderMap(),
        'category_icon': 'icono_inexistente',
      });
      expect(reminder.categoryIcon, Icons.help_outline);
    });
  });

  group('InfoCardRecordatorio.copyWith', () {
    test('conserva los campos omitidos sin modificar el original', () {
      final original = InfoCardRecordatorio.fromMap(reminderMap());
      final updated = original.copyWith(
        isEnabled: false,
        recurrency: 'semanal',
      );
      expect(updated, isNot(same(original)));
      expect(updated.id, original.id);
      expect(updated.title, original.title);
      expect(updated.categoryName, original.categoryName);
      expect(updated.categoryIcon, original.categoryIcon);
      expect(updated.categoryColor, original.categoryColor);
      expect(updated.isDefault, isTrue);
      expect(updated.scheduledAt, original.scheduledAt);
      expect(updated.isEnabled, isFalse);
      expect(updated.recurrency, 'Semanal');
      expect(original.isEnabled, isTrue);
      expect(original.recurrency, 'Diario');
    });

    test('permite sustituir todos los campos', () {
      final updated = InfoCardRecordatorio.fromMap(reminderMap()).copyWith(
        id: 8,
        title: 'Otro',
        categoryName: 'Otra',
        categoryIcon: Icons.home,
        categoryColor: Colors.blue,
        isEnabled: false,
        isDefault: false,
        scheduledAt: DateTime(2027, 1, 2),
        recurrency: 'mensual',
      );
      expect(updated.id, 8);
      expect(updated.title, 'Otro');
      expect(updated.categoryName, 'Otra');
      expect(updated.categoryIcon, Icons.home);
      expect(updated.categoryColor, Colors.blue);
      expect(updated.isEnabled, isFalse);
      expect(updated.isDefault, isFalse);
      expect(updated.scheduledAt, DateTime(2027, 1, 2));
      expect(updated.recurrency, 'Mensual');
    });
  });

  for (final entry in {
    '': '',
    'diario': 'Diario',
    'Semanal': 'Semanal',
    'mENSUAL': 'MENSUAL',
  }.entries) {
    test('capitaliza "${entry.key}" como "${entry.value}"', () {
      final reminder = InfoCardRecordatorio(
        title: 'Recordatorio',
        isEnabled: true,
        isDefault: false,
        scheduledAt: DateTime(2026, 9, 14),
        recurrency: entry.key,
      );
      expect(reminder.recurrency, entry.value);
    });
  }
}
