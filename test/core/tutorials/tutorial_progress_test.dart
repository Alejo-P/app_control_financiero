import 'dart:io';

import 'package:control_financiero/core/tutorials/tutorial_progress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory directory;
  late Box<dynamic> box;
  late TutorialProgress progress;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('tutorial_progress_');
    Hive.init(directory.path);
    box = await Hive.openBox<dynamic>('settings');
    progress = TutorialProgress(box);
  });

  tearDown(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test('instalación nueva y pasos con datos quedan pendientes', () {
    expect(progress.isPending('movimientos_inicio'), isTrue);
    expect(progress.isPending('movimientos_datos'), isTrue);
    expect(progress.isPending('presupuestos_agregar'), isTrue);
  });

  test('completar el inicio no consume los pasos condicionales', () async {
    await progress.finish('movimientos_inicio', skipped: false);
    expect(progress.states['movimientos_inicio'], 'completado');
    expect(progress.isPending('movimientos_datos'), isTrue);
    expect(progress.isPending('presupuestos_inicio'), isTrue);
  });

  test('omitir se conserva después de volver a abrir Hive', () async {
    await progress.finish('presupuestos_inicio', skipped: true);
    await box.close();
    box = await Hive.openBox<dynamic>('settings');
    progress = TutorialProgress(box);
    expect(progress.isPending('presupuestos_inicio'), isFalse);
    expect(progress.states['presupuestos_inicio'], 'omitido');
    expect(progress.isPending('presupuestos_agregar'), isTrue);
  });

  test('repetir reinicia solo tutoriales y conserva preferencias', () async {
    await box.put('darkMode', true);
    await progress.finish('movimientos_inicio', skipped: false);
    await progress.finish('mas_acciones', skipped: true);
    await progress.reset();
    expect(progress.states, isEmpty);
    expect(box.get('darkMode'), isTrue);
  });

  test('ignora estados locales desconocidos', () async {
    await box.put(TutorialProgress.storageKey, {
      'movimientos_inicio': 'desconocido',
      'historial_inicio': 'completado',
      3: 'omitido',
    });
    expect(progress.isPending('movimientos_inicio'), isTrue);
    expect(progress.isPending('historial_inicio'), isFalse);
    expect(progress.states.length, 1);
  });
}
