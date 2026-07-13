import 'package:flutter/material.dart';

extension ResponsiveExtension on BuildContext {
  double get width => MediaQuery.sizeOf(this).width;

  // Ancho maximo para considerar un dispositivo como teléfono
  bool get isPhone => width < 600;

  // Ancho mínimo para considerar un dispositivo como tablet y ancho máximo para considerar un dispositivo como tablet
  bool get isTablet => width >= 600 && width < 1024;

  // Ancho mínimo para considerar un dispositivo como escritorio
  bool get isDesktop => width >= 1024;
}
