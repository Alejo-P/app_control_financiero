import 'dart:async';
import 'dart:io';
import 'package:control_financiero/core/services/error_report_sender.dart';
import 'package:control_financiero/features/ajustes/widgets/error_report_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> open(WidgetTester tester, ErrorReportDialog dialog) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                showDialog<bool>(context: context, builder: (_) => dialog),
            child: const Text('Abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
  }

  testWidgets('cancel does not generate or send a report', (tester) async {
    var calls = 0;
    await open(
      tester,
      ErrorReportDialog(
        createReport: (_) async {
          calls++;
          return File('test.zip');
        },
        sendReport: (_) async {
          calls++;
        },
      ),
    );
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(find.byType(ErrorReportDialog), findsNothing);
  });

  testWidgets(
    'blocks duplicate taps and retries the same ZIP after connection failure',
    (tester) async {
      final completion = Completer<File>();
      var generated = 0;
      final sent = <File>[];
      String? description;
      await open(
        tester,
        ErrorReportDialog(
          createReport: (text) {
            generated++;
            description = text;
            return completion.future;
          },
          sendReport: (file) async {
            sent.add(file);
            if (sent.length == 1) {
              throw const ReportSendException('Revisa tu conexión a internet.');
            }
          },
        ),
      );
      await tester.enterText(find.byType(TextField), 'Error al abrir');
      await tester.tap(find.text('Enviar reporte'));
      await tester.pump();
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Cancelar'))
            .onPressed,
        isNull,
      );
      expect(generated, 1);
      completion.complete(File('test.zip'));
      await tester.pumpAndSettle();
      expect(description, 'Error al abrir');
      expect(find.text('Revisa tu conexión a internet.'), findsOneWidget);
      await tester.tap(find.text('Enviar reporte'));
      await tester.pumpAndSettle();
      expect(generated, 1);
      expect(sent.length, 2);
      expect(identical(sent[0], sent[1]), isTrue);
      expect(find.byType(ErrorReportDialog), findsNothing);
    },
  );

  testWidgets('editing description after failure generates a new report', (
    tester,
  ) async {
    final descriptions = <String>[];
    await open(
      tester,
      ErrorReportDialog(
        createReport: (text) async {
          descriptions.add(text);
          return File('report${descriptions.length}.zip');
        },
        sendReport: (_) async =>
            throw const ReportSendException('Error de envío.'),
      ),
    );
    await tester.enterText(find.byType(TextField), 'Primera descripción');
    await tester.tap(find.text('Enviar reporte'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Descripción corregida');
    await tester.tap(find.text('Enviar reporte'));
    await tester.pumpAndSettle();
    expect(descriptions, ['Primera descripción', 'Descripción corregida']);
  });

  testWidgets('creation failure shows error and re-enables button', (
    tester,
  ) async {
    await open(
      tester,
      ErrorReportDialog(
        createReport: (_) async => throw const FileSystemException('test'),
      ),
    );
    await tester.tap(find.text('Enviar reporte'));
    await tester.pumpAndSettle();
    expect(
      find.text('No se pudo preparar o enviar el reporte. Intenta nuevamente.'),
      findsOneWidget,
    );
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });
}
