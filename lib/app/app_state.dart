import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/models/app_bar_action.dart';
import 'package:control_financiero/features/categorias/data/categorias_repository.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';
import 'package:control_financiero/features/movimientos/data/movimientos_repository.dart';
import 'package:control_financiero/features/movimientos/models/movimiento.dart';
import 'package:control_financiero/features/movimientos/models/totales_mensuales.dart';
import 'package:control_financiero/features/tipo_categorias/data/tipo_categoria_repository.dart';
import 'package:control_financiero/features/tipo_categorias/models/tipo_categoria.dart';
import 'package:flutter/material.dart';

// Importacion de los datos mock
import 'package:control_financiero/features/movimientos/data/mock_categorias.dart';

class AppState extends ChangeNotifier {
  int currentTab = 0;
  String currentPageName = 'Inicio';
  DateTime selectedMonth = DateTime.now();

  final List<String> pageNames = [
    'Inicio',
    'Movimientos',
    'Presupuesto',
    'Historial',
    'Ajustes',
  ];

  List<AppBarAction> _appBarActions = [];
  List<AppBarAction> get appBarActions => _appBarActions;

  final MovimientosRepository _movimientosRepository;
  final CategoriasRepository _categoriasRepository;
  final TipoCategoriaRepository _tipoCategoriaRepository;

  AppState(
    this._movimientosRepository,
    this._categoriasRepository,
    this._tipoCategoriaRepository
  );

  final List<TipoCategoria> _tiposCategorias = mockTipoCategorias;
  final List<Categoria> _categorias = mockCategorias;
  //final List<Movimiento> _movimientos = mockMovimientos;


  MovimientoFiltro _movimientoFiltro = MovimientoFiltro.todos;
  MovimientoFiltro get movimientoFiltro => _movimientoFiltro;

  TotalesMensuales? _totalesMensuales;
  double? _variacionAhorro;
  List<DateTime> _uniqueMovementDates = [];
  Map<DateTime, List<Movimiento>> _movimientosPorFecha = {};

  TotalesMensuales? get totalesMensuales => _totalesMensuales;
  double? get variacionAhorro => _variacionAhorro;
  List<DateTime> get uniqueMovementDates => _uniqueMovementDates;


  List<Categoria> get categorias => _categorias;
  List<TipoCategoria> get tiposCategorias => _tiposCategorias;


  // Cargar datos iniciales de los repositorios
  Future<void> loadInitialData() async {
    await _movimientosRepository.fetchMovimientos();
    await _categoriasRepository.fetchCategorias();
    await _tipoCategoriaRepository.fetchTipoCategorias();
  }

  Future<void> loadMovementsData() async {
    _totalesMensuales =
        await _movimientosRepository.fetchTotalesMensuales(selectedMonth);

    _variacionAhorro = await calcularVariacionAhorro(
      selectedMonth,
      DateTime(selectedMonth.year, selectedMonth.month - 1),
    );

    _movimientosPorFecha = await _fetchMovimientosPorFecha();

    _uniqueMovementDates = await _fetchUniqueMovementDates();

    notifyListeners();
  }


  void changeMovimientoFiltro(MovimientoFiltro filtro) {
    if (_movimientoFiltro == filtro) return;
    _movimientoFiltro = filtro;
    notifyListeners();
  }

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

  TipoCategoria? getCategoryTypeById(String id) {
    return _tiposCategorias.firstWhere(
      (type) => type.id == id,
      orElse: () => TipoCategoria(
        id: 'unknown',
        name: 'Desconocido',
        description: 'Tipo de categoría no encontrado',
      )
    );
  }

  // Obtener todas las fechas únicas de movimientos
  Future<List<DateTime>> _fetchUniqueMovementDates() async {
    final movimientos = await _movimientosRepository.fetchMovimientos();
    final dates = movimientos
        .map((m) => DateTime(m.date.year, m.date.month, m.date.day))
        .toSet()
        .toList();

    dates.sort((a, b) => b.compareTo(a));
    return dates;
  }

  // Obtener movimientos agrupados por fecha
  Future<Map<DateTime, List<Movimiento>>> _fetchMovimientosPorFecha() async {
    final movimientos = await _movimientosRepository.fetchMovimientos();
    final Map<DateTime, List<Movimiento>> groupedMovements = {};

    for (var movimiento in movimientos) {
      final dateKey = DateTime(
        movimiento.date.year,
        movimiento.date.month,
        movimiento.date.day,
      );

      if (!groupedMovements.containsKey(dateKey)) {
        groupedMovements[dateKey] = [];
      }
      groupedMovements[dateKey]!.add(movimiento);
    }

    // Ordenar las fechas de más reciente a más antigua
    final sortedKeys = groupedMovements.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    final sortedMap = <DateTime, List<Movimiento>>{};
    for (var key in sortedKeys) {
      sortedMap[key] = groupedMovements[key]!;
    }

    return sortedMap;
  }


  // Obtener movimientos filtrados por fecha (mes y año)
  List<Movimiento> getMovimientosByDateAndFilter(
    DateTime fecha,
    MovimientoFiltro filtro,
  ) {
    final movimientos = _movimientosPorFecha[fecha] ?? [];

    if (filtro == MovimientoFiltro.todos) return movimientos;

    return movimientos.where((m) =>
      filtro == MovimientoFiltro.ingresos
        ? m.type == TipoMovimiento.ingreso
        : m.type == TipoMovimiento.gasto
    ).toList();
  }

  bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year &&
      a.month == b.month &&
      a.day == b.day;
  }

  // Calcular la variacion de ahorro entre dos meses
  Future<double?> calcularVariacionAhorro(DateTime mesActual, DateTime mesAnterior) async {
    final actual = await _movimientosRepository.fetchTotalesMensuales(mesActual);
    final anterior = await _movimientosRepository.fetchTotalesMensuales(mesAnterior);

    if (anterior.ahorro == 0) return null;

    return ((actual.ahorro - anterior.ahorro) / anterior.ahorro) * 100;
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

  void setAppBarActions(List<AppBarAction> actions) {
    _appBarActions = actions;
    notifyListeners();
  }

  void clearAppBarActions() {
    _appBarActions = [];
    notifyListeners();
  }
}
