import 'package:control_financiero/core/constants/categoria_constants.dart';
import 'package:flutter/material.dart';

class IconMapper {
  // Mapa String -> IconData (nombres exactos de Material Icons)
  static final Map<String, IconData> _nameToIcon = categoryIconsMap;

  // Mapa inverso IconData -> String (usando codePoint como identificador)
  static final Map<int, String> _iconToName = {
    for (final entry in categoryIconsMap.entries) entry.value.codePoint: entry.key,
  };

  /// Obtiene un IconData a partir de su nombre exacto de Material Icons
  /// 
  /// Devuelve [Icons.help_outline] si el nombre no existe
  static IconData fromName(String name) {
    return _nameToIcon[name] ?? Icons.help_outline;
  }

  /// Obtiene el nombre exacto de un IconData
  /// 
  /// Devuelve 'help_outline' si el ícono no se encuentra en el mapa
  static String toName(IconData icon) {
    return _iconToName[icon.codePoint] ?? 'help_outline';
  }

  /// Valida si un nombre de ícono es válido
  /// 
  /// Útil para validación antes de guardar en base de datos
  static bool isValidIconName(String name) {
    return _nameToIcon.containsKey(name);
  }

  /// Obtiene la lista de todos los nombres de iconos disponibles
  static List<String> getAllIconNames() {
    return _nameToIcon.keys.toList();
  }

  /// Obtiene la lista de todos los IconData disponibles
  static List<IconData> getAllIcons() {
    return _nameToIcon.values.toList();
  }
}
