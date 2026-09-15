import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

/// Portable v2 envelope. Passwords are UTF-8 encoded without normalization.
/// `data` contains ciphertext followed by the 16-byte GCM authentication tag.
class BackupCipher {
  static const iterations = 600000;
  static const legacyMessage =
      'Este respaldo v1 usa una clave de la instalación original, no una '
      'contraseña. Restáuralo con la versión anterior en esa instalación y '
      'crea un respaldo v2 después de actualizar. Sin la clave original no '
      'se puede recuperar.';

  static Uint8List _random(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(length, (_) => random.nextInt(256)),
    );
  }

  static Uint8List _derive(String password, Uint8List salt, int rounds) {
    final kdf = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(Pbkdf2Parameters(salt, rounds, 32));
    return kdf.process(Uint8List.fromList(utf8.encode(password)));
  }

  static Uint8List _header(Map<String, dynamic> file) => Uint8List.fromList(
    utf8.encode(
      jsonEncode([
        file['version'],
        file['cipher'],
        file['kdf'],
        file['iterations'],
        file['keyLength'],
        file['salt'],
        file['nonce'],
      ]),
    ),
  );

  static Map<String, dynamic> encrypt(String content, String password) {
    if (password.runes.length < 12) {
      throw const FormatException(
        'Usa una contraseña de al menos 12 caracteres.',
      );
    }
    final salt = _random(16);
    final nonce = _random(12);
    final file = <String, dynamic>{
      'version': 2,
      'cipher': 'AES-256-GCM',
      'kdf': 'PBKDF2-HMAC-SHA256',
      'iterations': iterations,
      'keyLength': 32,
      'salt': base64Encode(salt),
      'nonce': base64Encode(nonce),
    };
    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        true,
        AEADParameters(
          KeyParameter(_derive(password, salt, iterations)),
          128,
          nonce,
          _header(file),
        ),
      );
    file['data'] = base64Encode(
      cipher.process(Uint8List.fromList(utf8.encode(content))),
    );
    return file;
  }

  static Uint8List _bytes(dynamic value, {int? length}) {
    if (value is! String) throw const FormatException('Campo inválido.');
    final bytes = base64Decode(value);
    if (base64Encode(bytes) != value ||
        (length != null && bytes.length != length)) {
      throw const FormatException('Campo inválido.');
    }
    return bytes;
  }

  /// Validate before performing expensive derivation or touching the database.
  static Map<String, dynamic> validate(dynamic value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('El archivo de respaldo no es válido.');
    }
    if (value['version'] == 1) throw const FormatException(legacyMessage);
    if (value['version'] != 2) {
      throw const FormatException('Versión de respaldo no compatible.');
    }
    if (value['cipher'] != 'AES-256-GCM' ||
        value['kdf'] != 'PBKDF2-HMAC-SHA256' ||
        value['keyLength'] != 32 ||
        value['iterations'] is! int ||
        value['iterations'] < iterations ||
        value['iterations'] > 1200000) {
      throw const FormatException('Parámetros de cifrado no compatibles.');
    }
    _bytes(value['salt'], length: 16);
    _bytes(value['nonce'], length: 12);
    if (_bytes(value['data']).length < 16) {
      throw const FormatException('El respaldo está incompleto.');
    }
    return value;
  }

  static String decrypt(dynamic envelope, String password) {
    final file = validate(envelope);
    try {
      final cipher = GCMBlockCipher(AESEngine())
        ..init(
          false,
          AEADParameters(
            KeyParameter(
              _derive(
                password,
                _bytes(file['salt']),
                file['iterations'] as int,
              ),
            ),
            128,
            _bytes(file['nonce']),
            _header(file),
          ),
        );
      return utf8.decode(cipher.process(_bytes(file['data'])));
    } catch (_) {
      throw const FormatException('Contraseña incorrecta o respaldo dañado.');
    }
  }
}
