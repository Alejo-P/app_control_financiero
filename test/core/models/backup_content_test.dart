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

    final restored = BackupContent.fromMap(content.toMap());

    expect(restored.movementNotificationConfigs, hasLength(1));
    expect(restored.movementNotificationConfigs.single.typeKey, config.typeKey);
    expect(restored.movementNotificationConfigs.single.isEnabled, isTrue);
    expect(restored.movementNotificationConfigs.single.isDefault, isTrue);
  });
}
