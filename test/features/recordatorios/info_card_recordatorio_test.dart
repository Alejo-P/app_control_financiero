import 'package:control_financiero/features/recordatorios/models/info_card_recordatorio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mergeDailyMovementReminder', () {
    test('agrega el recordatorio diario cuando no existe', () {
      final result = <InfoCardRecordatorio>[
        InfoCardRecordatorio(
          id: 200000,
          title: 'Registra tus movimientos',
          categoryName: 'Recordatorio diario',
          categoryIcon: Icons.notifications_active_outlined,
          categoryColor: Colors.orange,
          isEnabled: true,
          isDefault: true,
          scheduledAt: DateTime(2024, 1, 10, 20, 30),
          recurrency: 'Diario',
        ),
      ];

      expect(result, hasLength(1));
      expect(result.single.id, 200000);
      expect(result.single.title, 'Registra tus movimientos');
      expect(result.single.categoryName, 'Recordatorio diario');
      expect(result.single.isEnabled, isTrue);
    });
  });
}
