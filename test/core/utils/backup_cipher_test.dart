import 'dart:convert';
import 'dart:io';
import 'package:control_financiero/core/utils/backup_cipher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'descifra fixture creado con Node crypto independientemente de Dart',
    () {
      final file = jsonDecode(
        File('test/fixtures/backup_v2.json').readAsStringSync(),
      );
      expect(
        BackupCipher.decrypt(file, 'fixture password'),
        'respaldo independiente á',
      );
    },
  );
  const password = 'Mi contraseña 🍎 segura';
  late Map<String, dynamic> file;
  setUpAll(() {
    file = BackupCipher.encrypt('Datos á 🍎 con espacios  ', password);
  });

  test('recupera únicamente con archivo serializado y contraseña', () {
    final serialized = jsonEncode(file);
    expect(serialized, isNot(contains(password)));
    expect(
      BackupCipher.decrypt(jsonDecode(serialized), password),
      'Datos á 🍎 con espacios  ',
    );
    expect(file['iterations'], 600000);
    expect(file['keyLength'], 32);
  });

  test('cada respaldo usa salt y nonce nuevos', () {
    final second = BackupCipher.encrypt('Datos á 🍎 con espacios  ', password);
    for (final field in ['salt', 'nonce', 'data']) {
      expect(second[field], isNot(file[field]));
    }
  });

  test('contraseña incorrecta no produce contenido', () {
    expect(
      () => BackupCipher.decrypt(file, 'otra contraseña'),
      throwsFormatException,
    );
  });

  test('autentica contenido, salt, nonce y parámetros', () {
    for (final field in ['data', 'salt', 'nonce']) {
      final bytes = base64Decode(file[field] as String);
      bytes[0] ^= 1;
      expect(
        () => BackupCipher.decrypt({
          ...file,
          field: base64Encode(bytes),
        }, password),
        throwsFormatException,
      );
    }
    expect(
      () => BackupCipher.decrypt({...file, 'iterations': 600001}, password),
      throwsFormatException,
    );
  });

  test(
    'rechaza parámetros inseguros, excesivos o malformados antes del KDF',
    () {
      for (final rounds in [0, 599999, 1200001, 1e100, '600000', null]) {
        expect(
          () => BackupCipher.validate({...file, 'iterations': rounds}),
          throwsFormatException,
        );
      }
      for (final patch in [
        {'cipher': 'AES-CBC'},
        {'kdf': 'unknown'},
        {'keyLength': 16},
        {'salt': '***'},
        {
          'nonce': base64Encode([1]),
        },
        {'data': ''},
        {'version': 3},
      ]) {
        expect(
          () => BackupCipher.validate({...file, ...patch}),
          throwsFormatException,
        );
      }
      expect(() => BackupCipher.validate([]), throwsFormatException);
    },
  );

  test('v1 explica la dependencia de la instalación original', () {
    expect(
      () => BackupCipher.decrypt({'version': 1}, password),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          BackupCipher.legacyMessage,
        ),
      ),
    );
  });

  test('contraseña corta no crea respaldo', () {
    expect(() => BackupCipher.encrypt('datos', 'corta'), throwsFormatException);
  });
}
