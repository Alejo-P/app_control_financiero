import 'package:control_financiero/features/etiquetas/models/etiqueta.dart';
import 'package:control_financiero/features/movimientos/widgets/tags_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:textfield_tags/textfield_tags.dart';

void main() {
  testWidgets('TagsInput renders the initial tags', (tester) async {
    final controller = StringTagController();
    final tags = [
      Etiqueta(id: 1, name: 'Trabajo', colorValue: 0xFF123456),
      Etiqueta(id: 2, name: 'Urgente', colorValue: 0xFF654321),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TagsInput(tagsController: controller, tags: tags, placeholder: 'Buscar etiquetas...'),
        ),
      ),
    );

    expect(find.text('Trabajo'), findsOneWidget);
    expect(find.text('Urgente'), findsOneWidget);
  });

  testWidgets('TagsInput uses the etiqueta color for the chip background', (
    tester,
  ) async {
    final controller = StringTagController();
    final tags = [Etiqueta(id: 1, name: 'Trabajo', colorValue: 0xFF123456)];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TagsInput(tagsController: controller, tags: tags),
        ),
      ),
    );

    final chip = tester.widget<InputChip>(find.byType(InputChip));

    expect(chip.backgroundColor, tags.first.color);
  });

  testWidgets('TagsInput calls onTagAdded when a tag is submitted', (
    tester,
  ) async {
    final controller = StringTagController();
    final addedTags = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TagsInput(
            tagsController: controller,
            onTagAdded: addedTags.add,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Trabajo');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(addedTags, ['Trabajo']);
  });

  testWidgets('TagsInput calls onTagRemoved when a chip is deleted', (
    tester,
  ) async {
    final controller = StringTagController();
    final removedTags = <String>[];
    final tags = [Etiqueta(id: 1, name: 'Trabajo', colorValue: 0xFF123456)];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TagsInput(
            tagsController: controller,
            tags: tags,
            onTagRemoved: removedTags.add,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    expect(removedTags, ['Trabajo']);
  });
}
