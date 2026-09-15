import 'dart:convert';
import 'dart:io';

import 'package:control_financiero/core/services/backup_service.dart';
import 'package:control_financiero/core/utils/backup_cipher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late File file;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('backup_test_');
    file = File('${directory.path}/backup.json');
  });
  tearDown(() async => directory.delete(recursive: true));

  test(
    'v1 muestra instrucciones y no intenta abrir la base de datos',
    () async {
      await file.writeAsString(
        jsonEncode({'version': 1, 'iv': 'old', 'data': 'old'}),
      );
      final service = BackupService();
      expect(
        await service.validateBackupFile(file.path),
        BackupCipher.legacyMessage,
      );
      final result = await service.restoreData(
        'contraseña cualquiera',
        file.path,
      );
      expect(result.success, isFalse);
      expect(result.message, BackupCipher.legacyMessage);
    },
  );

  test('contraseña errónea falla antes de acceder a SQLite', () async {
    await file.writeAsString(
      jsonEncode(BackupCipher.encrypt('{}', 'contraseña correcta')),
    );
    final service = BackupService();
    expect(await service.checkBackupfile(file.path), isTrue);
    final result = await service.restoreData('incorrecta', file.path);
    expect(result.success, isFalse);
    expect(result.message, 'Contraseña incorrecta o respaldo dañado.');
  });

  test('JSON malformado se rechaza sin restaurar', () async {
    await file.writeAsString('{');
    expect(await BackupService().checkBackupfile(file.path), isFalse);
    expect(
      (await BackupService().restoreData('password', file.path)).success,
      isFalse,
    );
  });
}
