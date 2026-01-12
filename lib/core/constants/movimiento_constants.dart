import 'package:flutter/material.dart';

enum TipoMovimiento { ingreso, gasto }

enum MovimientoFormMode { create, edit }

enum MovimientoFiltro { todos, ingresos, gastos }

extension MovimientoFiltroUI on MovimientoFiltro {
  String get label => switch (this) {
    MovimientoFiltro.ingresos => 'Ingresos',
    MovimientoFiltro.gastos => 'Gastos',
    _ => 'Todos',
  };

  IconData get icon => switch (this) {
    MovimientoFiltro.ingresos => Icons.arrow_upward,
    MovimientoFiltro.gastos => Icons.arrow_downward,
    _ => Icons.list,
  };

  Color get color => switch (this) {
    MovimientoFiltro.ingresos => Colors.green,
    MovimientoFiltro.gastos => Colors.red,
    _ => Colors.grey,
  };
}
