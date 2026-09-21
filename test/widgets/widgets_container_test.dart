import 'package:control_financiero/features/shared/widgets/widgets_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('La barra inferior no cambia la altura de los grupos', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(bottom: 48);
    tester.view.viewPadding = const FakeViewPadding(bottom: 48);
    addTearDown(tester.view.reset);

    Future<double> measure({required bool withBottomBar}) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Categoría')),
            bottomNavigationBar: withBottomBar
                ? const SizedBox(height: 80)
                : null,
            body: const SingleChildScrollView(
              child: WidgetsContainer(
                title: 'Opciones',
                children: [SizedBox(height: 50), SizedBox(height: 50)],
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      // Dos filas de 50 y un separador de 8, sin relleno del sistema.
      expect(tester.getSize(find.byType(ListView)).height, 108);
      return tester.getSize(find.byType(WidgetsContainer)).height;
    }

    final withBar = await measure(withBottomBar: true);
    final withoutBar = await measure(withBottomBar: false);
    expect(withoutBar, withBar);
  });
}
