import 'package:flutter/services.dart';

class MoneyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final maxLength = 10;

    // Vacío es válido
    if (text.isEmpty) return newValue;

    // Si el texto es solo un punto, colocar "0."
    if (text == '.') {
      String modifiedText = '0.';
      return TextEditingValue(
        text: modifiedText,
        selection: TextSelection.collapsed(offset: modifiedText.length),
      );
    }

    // No permitir terminar con punto
    if (text.endsWith('.') && text.indexOf('.') == maxLength - 1) {
      return oldValue;
    }

    // Regex: números con hasta 2 decimales
    final regex = RegExp(r'^\d+(\.\d{0,2})?$');

    if (!regex.hasMatch(text)) {
      return oldValue;
    }

    // Límite total de caracteres
    if (text.length > maxLength) {
      return oldValue;
    }

    // Si el texto empieza con 0, colocar el punto después del 0
    if (text.startsWith('0') && text.length > 1 && text[1] != '.') {
      String modifiedText = text;
      modifiedText = '0.${text.substring(1)}';
      return TextEditingValue(
        text: modifiedText,
        selection: TextSelection.collapsed(offset: modifiedText.length),
      );
    }

    return newValue;
  }
}
