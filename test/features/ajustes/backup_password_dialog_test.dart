import 'package:control_financiero/features/ajustes/widgets/backup_password_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> open(
    WidgetTester tester, {
    required bool creating,
    required ValueChanged<String?> result,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result(
                await showDialog<String>(
                  context: context,
                  builder: (_) => BackupPasswordDialog(creating: creating),
                ),
              );
            },
            child: const Text('Abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'crear valida longitud, confirmación y devuelve contraseña exacta',
    (tester) async {
      String? result;
      await open(tester, creating: true, result: (value) => result = value);
      await tester.enterText(find.byType(TextFormField).first, 'corta');
      await tester.tap(find.text('Crear respaldo'));
      await tester.pumpAndSettle();
      expect(find.text('Usa al menos 12 caracteres.'), findsOneWidget);
      const password = ' contraseña larga ';
      await tester.enterText(find.byType(TextFormField).first, password);
      await tester.enterText(find.byType(TextFormField).last, 'distinta');
      await tester.tap(find.text('Crear respaldo'));
      await tester.pumpAndSettle();
      expect(find.text('Las contraseñas no coinciden.'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).last, password);
      await tester.tap(find.text('Crear respaldo'));
      await tester.pumpAndSettle();
      expect(result, password);
    },
  );

  testWidgets('restaurar oculta contraseña y permite cancelar', (tester) async {
    String? result = 'pending';
    await open(tester, creating: false, result: (value) => result = value);
    expect(find.byType(TextFormField), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).obscureText,
      isTrue,
    );
    await tester.tap(find.byTooltip('Mostrar contraseña'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).obscureText,
      isFalse,
    );
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(result, isNull);
  });
}
