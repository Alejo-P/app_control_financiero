import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/features/movimientos/models/categoria.dart';
import 'package:control_financiero/features/movimientos/models/category_type.dart';
import 'package:control_financiero/features/movimientos/models/movimiento.dart';
import 'package:flutter/material.dart';

// Importacion de los datos mock
import 'package:control_financiero/features/movimientos/data/mock_categorias.dart';
import 'package:control_financiero/features/movimientos/data/mock_movimientos.dart';

class AppState extends ChangeNotifier {
  int currentTab = 0;
  String currentPageName = 'Inicio';
  DateTime selectedMonth = DateTime.now();

  final List<CategoryType> _tiposCategorias = mockTipoCategorias;
  final List<Categoria> _categorias = mockCategorias;
  final List<Movimiento> _movimientos = mockMovimientos;

  MovimientoFiltro _movimientoFiltro = MovimientoFiltro.todos;

  MovimientoFiltro get movimientoFiltro => _movimientoFiltro;

  void changeMovimientoFiltro(MovimientoFiltro filtro) {
    if (_movimientoFiltro == filtro) return;
    _movimientoFiltro = filtro;
    notifyListeners();
  }

  final List<String> pageNames = [
    'Inicio',
    'Movimientos',
    'Presupuesto',
    'Historial',
    'Ajustes',
  ];

  Categoria? getCategoriaById(String id) {
    return _categorias.firstWhere(
      (cat) => cat.id == id,
      orElse: () => Categoria(
        id: 'unknown',
        name: 'Desconocida',
        description: 'Categoría no encontrada',
        categoryTypeID: 'unknown',
        iconName: 'help_outline',
        iconColorValue: 0xFF9E9E9E,
      )
    );
  }

  CategoryType? getCategoryTypeById(String id) {
    return _tiposCategorias.firstWhere(
      (type) => type.id == id,
      orElse: () => CategoryType(
        id: 'unknown',
        name: 'Desconocido',
        description: 'Tipo de categoría no encontrado',
      )
    );
  }

  List<Movimiento> get movimientos => _movimientos;

  // Obtener todas las fechas únicas de movimientos
  List<DateTime> get uniqueMovementDates {
    final dates = _movimientos.map(
      (mov) => DateTime(mov.date.year, mov.date.month, mov.date.day)
    ).toSet().toList();
    dates.sort((a, b) => b.compareTo(a)); // Ordenar de más reciente a más antiguo
    return dates;
  }

  // Obtener movimientos filtrados por fecha (mes y año)
  List<Movimiento> getMovimientosByDate(DateTime date) {
    return _movimientos.where((mov) =>
      mov.date.month == date.month && mov.date.year == date.year
    ).toList();
  }

  bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year &&
      a.month == b.month &&
      a.day == b.day;
  }


  // Obtener movimientos filtrados por fecha y filtro de tipo
  List<Movimiento> getMovimientosByDateAndFilter(
    DateTime fecha,
    MovimientoFiltro selectedFilter,
  ) {
    return movimientos.where((movimiento) {
      final sameDay = isSameDay(movimiento.date, fecha);

      if (!sameDay) return false;

      switch (selectedFilter) {
        case MovimientoFiltro.todos:
          return true;
        case MovimientoFiltro.ingresos:
          return movimiento.type == TipoMovimiento.ingreso;
        case MovimientoFiltro.gastos:
          return movimiento.type == TipoMovimiento.gasto;
      }
    }).toList();
  }


  void changeTab(int index) {
    if (currentTab == index) return;

    currentTab = index;
    currentPageName = pageNames[index];
    notifyListeners();
  }

  void changeMonth(DateTime month) {
    selectedMonth = month;
    notifyListeners();
  }
}
