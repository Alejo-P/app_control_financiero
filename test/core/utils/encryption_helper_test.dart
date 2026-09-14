import 'dart:convert';

import 'package:control_financiero/core/utils/encryption_helper.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_test/flutter_test.dart';

void main() {
  final keyBytes = List<int>.generate(32, (index) => index);
  final key = base64Encode(keyBytes);
  final invalidBackup = throwsA(
    isA<Exception>().having(
      (error) => error.toString(),
      'message',
      'Exception: Clave incorrecta o archivo inválido',
    ),
  );

  String decrypt(EncryptionResult result, {String? withKey}) {
    return EncryptionHelper.decryptData(
      encryptedText: result.data,
      encryptKey: withKey ?? key,
      ivBase64: result.iv,
    );
  }

  // Crea archivos cifrados independientes del formato que genera el helper.
  EncryptionResult encryptRaw(String content) {
    final iv = encrypt.IV.fromSecureRandom(16);
    final cipher = encrypt.Encrypter(encrypt.AES(encrypt.Key.fromBase64(key)));
    return EncryptionResult(
      iv: iv.base64,
      data: cipher.encrypt(content, iv: iv).base64,
    );
  }

  group('generateRandomKey', () {
    test('genera una clave Base64 de 32 bytes utilizable para un respaldo', () {
      final generated = EncryptionHelper.generateRandomKey();
      expect(base64Decode(generated), hasLength(32));
      final result = EncryptionHelper.encryptData('respaldo', generated);
      expect(decrypt(result, withKey: generated), 'respaldo');
    });

    test('genera claves diferentes en llamadas consecutivas', () {
      expect(
        EncryptionHelper.generateRandomKey(),
        isNot(EncryptionHelper.generateRandomKey()),
      );
    });
  });

  group('parseKey', () {
    test('recupera exactamente los bytes originales', () {
      expect(EncryptionHelper.parseKey(key).bytes, orderedEquals(keyBytes));
    });

    test('rechaza texto que no es Base64', () {
      expect(() => EncryptionHelper.parseKey('***'), throwsFormatException);
    });

    for (final length in [0, 16, 24, 31, 33]) {
      test('rechaza una clave Base64 de $length bytes', () {
        final invalidKey = base64Encode(List<int>.filled(length, 1));
        expect(
          () => EncryptionHelper.parseKey(invalidKey),
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'message',
              'La clave AES debe tener 32 bytes.',
            ),
          ),
        );
      });
    }
  });

  group('encryptData / decryptData', () {
    final contents = {
      'texto vacío': '',
      'JSON con Unicode': '{"nota":"Alimentación 🍎", "monto":12.50}',
      'saltos de línea y espacios': '  ingreso\ngasto\t\r\n',
      'contenido extenso': 'Movimiento á €\n' * 1000,
    };

    for (final entry in contents.entries) {
      test('conserva ${entry.key}', () {
        final result = EncryptionHelper.encryptData(entry.value, key);
        expect(decrypt(result), entry.value);
      });
    }

    test('usa un IV de 16 bytes diferente para cada cifrado', () {
      final first = EncryptionHelper.encryptData('mismo contenido', key);
      final second = EncryptionHelper.encryptData('mismo contenido', key);
      expect(base64Decode(first.iv), hasLength(16));
      expect(base64Decode(second.iv), hasLength(16));
      expect(first.iv, isNot(second.iv));
      expect(first.data, isNot(second.data));
      expect(decrypt(first), 'mismo contenido');
      expect(decrypt(second), 'mismo contenido');
    });

    test('rechaza una clave inválida al cifrar', () {
      expect(
        () => EncryptionHelper.encryptData('respaldo', '***'),
        throwsFormatException,
      );
    });
  });

  group('decryptData: errores', () {
    late EncryptionResult result;

    setUp(() {
      result = EncryptionHelper.encryptData('respaldo', key);
    });

    test('rechaza una clave válida pero incorrecta', () {
      final wrongKey = base64Encode(List<int>.filled(32, 255));
      expect(() => decrypt(result, withKey: wrongKey), invalidBackup);
    });

    test('normaliza el error de una clave malformada', () {
      expect(() => decrypt(result, withKey: '***'), invalidBackup);
    });

    test('rechaza datos que no son Base64', () {
      expect(
        () => decrypt(EncryptionResult(iv: result.iv, data: '***')),
        invalidBackup,
      );
    });

    test('rechaza un IV que no es Base64', () {
      expect(
        () => decrypt(EncryptionResult(iv: '***', data: result.data)),
        invalidBackup,
      );
    });

    test('rechaza contenido descifrado que no es JSON', () {
      expect(() => decrypt(encryptRaw('no es JSON')), invalidBackup);
    });

    test('rechaza un respaldo con identificador incorrecto', () {
      final file = encryptRaw(
        jsonEncode({'magic': 'OTRO_FORMATO', 'data': 'respaldo'}),
      );
      expect(() => decrypt(file), invalidBackup);
    });

    test('rechaza un respaldo sin identificador', () {
      final file = encryptRaw(jsonEncode({'data': 'respaldo'}));
      expect(() => decrypt(file), invalidBackup);
    });
  });
}
