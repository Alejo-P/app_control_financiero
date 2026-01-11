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

class AppState extends ChangeNotifier {
  DateTime selectedMonth = DateTime.now();

  final List<String> pageNames = [
    'Movimientos',
    'Presupuesto',
    'Categorías',
    'Historial',
    'Ajustes',
  ];
  String currentPageName = 'Movimientos';
  int currentTab = 0;

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

  MovimientoFiltro _movimientoFiltro = MovimientoFiltro.todos;
  MovimientoFiltro get movimientoFiltro => _movimientoFiltro;

  TotalesMensuales? _totalesMensuales;
  double? _variacionAhorro;
  List<DateTime> _uniqueMovementDates = [];
  Map<DateTime, List<Movimiento>> _movimientosPorFecha = {};

  TotalesMensuales? get totalesMensuales => _totalesMensuales;
  double? get variacionAhorro => _variacionAhorro;
  List<DateTime> get uniqueMovementDates => _uniqueMovementDates;

  List<Categoria> get categorias => _categoriasRepository.categorias;
  List<TipoCategoria> get tiposCategorias => _tipoCategoriaRepository.tipoCategorias;
  List<Movimiento> get movimientos => _movimientosRepository.movimientos;

  String transactionResultMessage = '';
  bool loadingInitialData = true;

  // Cargar datos iniciales de los repositorios
  Future<void> loadInitialData() async {
    await Future.wait([
      _tipoCategoriaRepository.fetchTipoCategorias(),
      _categoriasRepository.fetchCategorias(),
      _movimientosRepository.fetchMovimientos(),
    ]);
    await loadMovementsData(notify: false);
    loadingInitialData = false;

    notifyListeners();
  }



  Future<void> loadMovementsData({bool notify = true}) async {
    _totalesMensuales = _movimientosRepository.fetchTotalesMensuales(selectedMonth);

    _variacionAhorro = calcularVariacionAhorro(
      selectedMonth,
      DateTime(selectedMonth.year, selectedMonth.month - 1),
    );

    _movimientosPorFecha = _fetchMovimientosPorFecha();

    _uniqueMovementDates = _fetchUniqueMovementDates();

    if (notify) notifyListeners();
  }

  void changeMovimientoFiltro(MovimientoFiltro filtro) {
    if (_movimientoFiltro == filtro) return;
    _movimientoFiltro = filtro;
    notifyListeners();
  }

  Categoria? getCategoriaById(int id) {
    try {
      final categoria = categorias.firstWhere((cat) => cat.id == id);
      return categoria;
    } catch (e) {
      return null;
    }
  }

  TipoCategoria? getCategoryTypeById(int id) {
    return _tipoCategoriaRepository.getTipoCategoriaById(id);
  }

  // Obtener todas las fechas únicas de movimientos
  List<DateTime> _fetchUniqueMovementDates() {
    final dates = movimientos
        .map((m) => DateTime(m.date.year, m.date.month, m.date.day))
        .toSet()
        .toList();

    dates.sort((a, b) => b.compareTo(a));
    return dates;
  }

  // Obtener movimientos agrupados por fecha
  Map<DateTime, List<Movimiento>> _fetchMovimientosPorFecha() {
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
  double? calcularVariacionAhorro(DateTime mesActual, DateTime mesAnterior) {
    final actual = _movimientosRepository.fetchTotalesMensuales(mesActual);
    final anterior = _movimientosRepository.fetchTotalesMensuales(mesAnterior);

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

  // ================================= MOVIMIENTOS CRUD =================================
  Future<void> agregarMovimiento(Movimiento movimiento) async {
    final result = await _movimientosRepository.addMovimiento(movimiento);
    transactionResultMessage = result['message'] ?? '';
    if (result['success'] == true) {
      await loadMovementsData();
    }
  }

  Future<void> actualizarMovimiento(Movimiento movimiento) async {
    final result = await _movimientosRepository.updateMovimiento(movimiento);
    transactionResultMessage = result['message'] ?? '';
    if (result['success'] == true) {
      await loadMovementsData();
    }
  }

  Future<void> eliminarMovimiento(int id) async {
    final result = await _movimientosRepository.deleteMovimiento(id);
    transactionResultMessage = result['message'] ?? '';
    if (result['success'] == true) {
      await loadMovementsData();
    }
  }


  // ================================ CATEGORIAS CRUD =================================
  Future<void> agregarCategoria(Categoria categoria) async {
    final result = await _categoriasRepository.addCategoria(categoria);
    transactionResultMessage = result['message'] ?? '';
    if (result['success'] == true) {
      await _categoriasRepository.fetchCategorias();
      notifyListeners();
    }
  }

  Future<void> actualizarCategoria(Categoria categoria) async {
    final result = await _categoriasRepository.updateCategoria(categoria);
    transactionResultMessage = result['message'] ?? '';
    if (result['success'] == true) {
      await _categoriasRepository.fetchCategorias();
      notifyListeners();
    }
  }

  Future<void> eliminarCategoria(int id) async {
    final result = await _categoriasRepository.deleteCategoria(id);
    transactionResultMessage = result['message'] ?? '';
    if (result['success'] == true) {
      await _categoriasRepository.fetchCategorias();
      notifyListeners();
    }
  }
}