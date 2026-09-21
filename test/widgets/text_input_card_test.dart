import 'package:control_financiero/features/shared/widgets/text_input_card.dart';
import 'package:control_financiero/features/shared/widgets/widgets_container.dart';
import 'package:control_financiero/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final action in ['Copiar', 'Cortar', 'Pegar', 'Seleccionar todo']) {
    testWidgets('El menú permite $action en Android', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.reset);
      final controller = TextEditingController(text: 'Hola mundo');
      addTearDown(controller.dispose);
      String clipboard = 'Texto';
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          switch (call.method) {
            case 'Clipboard.hasStrings':
              return {'value': clipboard.isNotEmpty};
            case 'Clipboard.getData':
              return {'text': clipboard};
            case 'Clipboard.setData':
              clipboard = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light.copyWith(platform: TargetPlatform.android),
          locale: const Locale('es'),
          supportedLocales: const [Locale('es')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: Scaffold(
            appBar: AppBar(title: const Text('Agregar Movimiento')),
            body: SingleChildScrollView(
              child: WidgetsContainer(
                title: 'Detalles del movimiento',
                children: [
                  TextInputCard(
                    textController: controller,
                    iconData: Icons.title,
                    iconColor: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.longPressAt(
        tester.getTopLeft(find.byType(EditableText)) + const Offset(12, 10),
      );
      await tester.pumpAndSettle();
      expect(
        controller.selection,
        const TextSelection(baseOffset: 0, extentOffset: 4),
      );
      if (find.text(action).hitTestable().evaluate().isEmpty) {
        await tester.tap(find.byTooltip('Más'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text(action).hitTestable());
      await tester.pumpAndSettle();
      switch (action) {
        case 'Copiar':
          expect(clipboard, 'Hola');
          expect(controller.text, 'Hola mundo');
        case 'Cortar':
          expect(clipboard, 'Hola');
          expect(controller.text, ' mundo');
        case 'Pegar':
          expect(controller.text, 'Texto mundo');
        case 'Seleccionar todo':
          expect(
            controller.selection,
            const TextSelection(baseOffset: 0, extentOffset: 10),
          );
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
