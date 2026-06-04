import 'package:flutter/services.dart';

class NumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;
    TextSelection selection = newValue.selection;
    final maxLength = 10;

    // Vacío es válido
    if (text.isEmpty) return newValue;

    // 👉 Si empieza con ".", agregar "0"
    if (text.startsWith('.')) {
      text = '0$text';
      selection = TextSelection.collapsed(offset: text.length);
    }

    // 👉 Evitar múltiples puntos
    if ('.'.allMatches(text).length > 1) {
      return oldValue;
    }

    // 👉 Regex: hasta 2 decimales
    final regex = RegExp(r'^\d+(\.\d{0,2})?$');

    if (!regex.hasMatch(text)) {
      return oldValue;
    }

    // 👉 Límite de longitud
    if (text.length > maxLength) {
      return oldValue;
    }

    return TextEditingValue(
      text: text,
      selection: selection,
    );
  }
}