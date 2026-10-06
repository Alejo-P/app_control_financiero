import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/features/ajustes/presentation/notification_config_page.dart';
import 'package:control_financiero/features/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../support/app_state_fakes.dart';

void main() {
  testWidgets('El umbral rechaza decimales y acepta enteros de 1 a 100', (
    tester,
  ) async {
    final state = TestAppState();
    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: const MaterialApp(home: NotificationConfigPage()),
      ),
    );

    final field = find.byType(TextFormField);
    for (final value in ['25.5', '25,5', '25.', '100.0']) {
      await tester.enterText(field, value);
      await tester.pump();
      expect(
        find.text('El umbral debe ser un número entero, sin decimales'),
        findsOneWidget,
      );
      expect(
        tester.widget<CustomButton>(find.byType(CustomButton)).onTap,
        isNull,
      );
    }

    for (final value in ['0', '101', '']) {
      await tester.enterText(field, value);
      await tester.pump();
      expect(
        tester.widget<CustomButton>(find.byType(CustomButton)).onTap,
        isNull,
      );
    }

    for (final value in ['1', '25', '100']) {
      await tester.enterText(field, value);
      await tester.pump();
      expect(
        find.text('El umbral debe ser un número entero, sin decimales'),
        findsNothing,
      );
      expect(
        tester.widget<CustomButton>(find.byType(CustomButton)).onTap,
        isNotNull,
      );
    }
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });
}
