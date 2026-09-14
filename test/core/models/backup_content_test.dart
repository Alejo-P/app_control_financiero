import 'dart:convert';

import 'package:control_financiero/core/database/db_init_data.dart';
import 'package:control_financiero/core/models/backup_content.dart';
import 'package:control_financiero/features/notificaciones/models/movement_notification_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('conserva la configuración de notificaciones de movimientos', () {
    final config = MovementNotificationConfig(
      typeKey: MovementNotificationConfig.createMovementKey,
      isEnabled: true,
      isDefault: true,
      createdAt: DateTime(2026, 9, 14),
    );
    final content = BackupContent(
      movementsData: [],
      categoriesData: [],
      categoryTypesData: [],
      budgetsData: [],
      budgetIncomeData: [],
      notifitionsData: [],
      movementNotificationConfigsData: [config.toMap()],
      remindersData: [],
    );

    final restored = BackupContent.fromMap(
      jsonDecode(jsonEncode(content.toMap())),
    );

    expect(restored.movementNotificationConfigs, hasLength(1));
    expect(restored.movementNotificationConfigs.single.typeKey, config.typeKey);
    expect(restored.movementNotificationConfigs.single.isEnabled, isTrue);
    expect(restored.movementNotificationConfigs.single.isDefault, isTrue);
    expect(
      restored.movementNotificationConfigs.single.createdAt,
      config.createdAt,
    );
  });

  test(
    'restaura respaldos antiguos con los valores predeterminados actuales',
    () {
      final restored = BackupContent.fromMap({});
      expect(restored.movements, isEmpty);
      expect(restored.budgets, isEmpty);
      expect(restored.budgetIncome, isEmpty);
      expect(restored.budgetNotifications, isEmpty);
      expect(restored.movementNotificationConfigs, isEmpty);
      expect(restored.reminders, isEmpty);
      expect(
        restored.categories.map((c) => c.toMap()).toList(),
        categoriasList.map((c) => c.toMap()).toList(),
      );
      expect(
        restored.categoryTypes.map((c) => c.toMap()).toList(),
        tipoCategoriasList.map((c) => c.toMap()).toList(),
      );
      expect(restored.categories, isNotEmpty);
      expect(restored.categoryTypes, isNotEmpty);
    },
  );

  test(
    'respeta las listas vacías explícitas sin añadir datos predeterminados',
    () {
      final map = <String, dynamic>{
        'movements': [],
        'categories': [],
        'categoryTypes': [],
        'budgets': [],
        'budgetIncome': [],
        'notifications': [],
        'movementNotificationConfigs': [],
        'reminders': [],
      };
      final restored = BackupContent.fromMap(map);
      expect(restored.toMap(), map);
      expect(restored.categories, isEmpty);
      expect(restored.categoryTypes, isEmpty);
    },
  );

  test('conserva todas las secciones al serializar y restaurar JSON', () {
    final map = <String, dynamic>{
      'movements': [
        {
          'id': 1,
          'title': 'Compra',
          'category_id': 9,
          'amount': 42.5,
          'date': '2026-09-14',
          'time': '10:30',
          'note': 'Fruta',
        },
      ],
      'categories': [categoriasList.first.toMap()],
      'categoryTypes': [tipoCategoriasList.first.toMap()],
      'budgets': [
        {
          'id': 2,
          'category_id': 9,
          'date': '2026-09-01',
          'amount': 200,
          'repeat_budget': 1,
        },
      ],
      'budgetIncome': [
        {'id': 3, 'amount': 1500, 'date': '2026-09-01'},
      ],
      'notifications': [
        {
          'id': 4,
          'threshold': 80.0,
          'category_id': 9,
          'is_enabled': 1,
          'is_default': 0,
          'created_at': '2026-09-14T10:30:00',
        },
      ],
      'movementNotificationConfigs': [
        {
          'id': 5,
          'type_key': 'movimiento_edicion',
          'is_enabled': 0,
          'is_default': 1,
          'created_at': '2026-09-14T10:30:00',
        },
      ],
      'reminders': [
        {
          'id': 6,
          'title': 'Pagar',
          'description': 'Factura',
          'category_id': 9,
          'scheduled_at': '2026-09-15T20:30:00',
          'completed': 0,
          'enabled': 1,
          'is_default': 0,
          'recurrencia': 'mensual',
        },
      ],
    };
    final content = BackupContent.fromMap(map);
    final restored = BackupContent.fromMap(
      jsonDecode(jsonEncode(content.toMap())),
    );
    expect(restored.toMap(), map);
    expect(restored.movements.single.title, 'Compra');
    expect(restored.movements.single.amount, 42.5);
    expect(restored.movements.single.categoryID, 9);
    expect(restored.categories.single.toMap(), categoriasList.first.toMap());
    expect(
      restored.categoryTypes.single.toMap(),
      tipoCategoriasList.first.toMap(),
    );
    expect(restored.budgets.single.amount, 200.0);
    expect(restored.budgets.single.repeatBudget, isTrue);
    expect(restored.budgetIncome.single.monto, 1500.0);
    expect(restored.budgetNotifications.single.threshold, 80.0);
    expect(restored.budgetNotifications.single.isEnabledNotification, isTrue);
    expect(restored.movementNotificationConfigs.single.id, 5);
    expect(
      restored.movementNotificationConfigs.single.typeKey,
      MovementNotificationConfig.editMovementKey,
    );
    expect(restored.movementNotificationConfigs.single.isEnabled, isFalse);
    expect(restored.reminders.single.title, 'Pagar');
    expect(restored.reminders.single.enabled, isTrue);
    expect(
      restored.reminders.single.scheduledAt,
      DateTime(2026, 9, 15, 20, 30),
    );
  });
}
