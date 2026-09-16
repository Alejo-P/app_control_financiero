import 'dart:io';

import 'package:control_financiero/core/utils/backup_file_writer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory directory;
  final date = DateTime(2026, 9, 16, 8, 5, 3);

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('backup_names_');
  });
  tearDown(() async => directory.delete(recursive: true));

  Future<File> write(String content, {DateTime? at}) =>
      BackupFileWriter.write(directory.path, content, createdAt: at ?? date);

  test('conserva ambos respaldos del mismo día y el formato JSON', () async {
    final first = await write('{"data":1}');
    final second = await write(
      '{"data":2}',
      at: date.add(const Duration(seconds: 1)),
    );

    expect(p.basename(first.path), 'backup_2026_09_16_08_05_03.json');
    expect(p.basename(second.path), 'backup_2026_09_16_08_05_04.json');
    expect(await first.readAsString(), '{"data":1}');
    expect(await second.readAsString(), '{"data":2}');
  });

  test('incrementa el sufijo sin alterar archivos existentes', () async {
    final existing = [
      File(p.join(directory.path, 'backup_2026_09_16.json')),
      File(p.join(directory.path, 'backup_2026_09_16_08_05_03.json')),
      File(p.join(directory.path, 'backup_2026_09_16_08_05_03_1.json')),
    ];
    for (final file in existing) {
      await file.writeAsString('original');
    }

    final result = await write('nuevo');

    expect(p.basename(result.path), 'backup_2026_09_16_08_05_03_2.json');
    expect(await result.readAsString(), 'nuevo');
    for (final file in existing) {
      expect(await file.readAsString(), 'original');
    }
  });

  test(
    'respaldos simultáneos en el mismo segundo conservan sus datos',
    () async {
      final files = await Future.wait([
        for (var i = 0; i < 10; i++) write('contenido $i'),
      ]);

      expect(files.map((file) => file.path).toSet(), hasLength(10));
      for (var i = 0; i < files.length; i++) {
        expect(await files[i].readAsString(), 'contenido $i');
      }
    },
  );

  test('omite un directorio que ocupa el nombre del respaldo', () async {
    final occupied = Directory(
      p.join(directory.path, 'backup_2026_09_16_08_05_03.json'),
    );
    await occupied.create();

    final result = await write('nuevo');

    expect(p.basename(result.path), 'backup_2026_09_16_08_05_03_1.json');
    expect(await occupied.exists(), isTrue);
    expect(await result.readAsString(), 'nuevo');
  });

  test('propaga errores de destino sin reintentar indefinidamente', () async {
    await expectLater(
      BackupFileWriter.write(
        p.join(directory.path, 'inexistente'),
        'datos',
        createdAt: date,
      ),
      throwsA(isA<FileSystemException>()),
    );
  });
}
