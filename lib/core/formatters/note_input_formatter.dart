import 'package:flutter/services.dart';

class NoteInputFormatter extends TextInputFormatter  {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Vacío es válido
    if (text.isEmpty) return newValue;

    // Permitir letras, números, espacios y puntuación básica
    final regex = RegExp(
      r'^[\p{L}\p{N} .,!?()\-]*$',
      unicode: true,
    );

    if (!regex.hasMatch(text)) {
      return oldValue;
    }

    // Si inicia con un punto, eliminarlo
    if (text.startsWith('.')) {
      String modifiedText = text.substring(1);
      return TextEditingValue(
        text: modifiedText,
        selection: TextSelection.collapsed(offset: modifiedText.length),
      );
    }

    // Convertir la primera letra en mayúscula
    String modifiedText = text[0].toUpperCase() + text.substring(1);

    return TextEditingValue(
      text: modifiedText,
      selection: TextSelection.collapsed(offset: modifiedText.length),
    );
  }
}