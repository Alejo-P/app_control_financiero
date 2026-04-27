import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionResult {
  final String iv;
  final String data;

  EncryptionResult({required this.iv, required this.data});
}

class EncryptionHelper {
  static EncryptionResult encryptData(String plainText, String encryptKey) {
    final key = encrypt.Key.fromUtf8(encryptKey);
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final wrapped = jsonEncode({"magic": "CF_BACKUP_v1", "data": plainText});

    final encrypted = encrypter.encrypt(wrapped, iv: iv);
    return EncryptionResult(iv: iv.base64, data: encrypted.base64);
  }

  static String decryptData({
    required String encryptedText,
    required String encryptKey,
    required String ivBase64,
  }) {
    try {
      final key = encrypt.Key.fromUtf8(encryptKey);
      final iv = encrypt.IV.fromBase64(ivBase64);

      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      final decrypted = encrypter.decrypt64(encryptedText, iv: iv);

      final decoded = jsonDecode(decrypted);

      if (decoded['magic'] != 'CF_BACKUP_v1') {
        throw Exception('Clave incorrecta');
      }

      return decoded['data'];
    } catch (e) {
      throw Exception('Clave incorrecta o archivo inválido');
    }
  }
}
