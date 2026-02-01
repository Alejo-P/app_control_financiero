import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/models/app_bar_action.dart';
import 'package:control_financiero/features/categorias/data/categorias_repository.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';
import 'package:control_financiero/features/movimientos/data/movimientos_repository.dart';
import 'package:control_financiero/features/movimientos/models/movimiento.dart';
import 'package:control_financiero/features/movimientos/models/totales_mensuales.dart';
import 'package:control_financiero/features/presupuestos/data/presupuestos_repository.dart';
import 'package:control_financiero/features/presupuestos/models/presupuesto.dart';
import 'package:control_financiero/features/tipo_categorias/data/tipo_categoria_repository.dart';
import 'package:control_financiero/features/tipo_categorias/models/tipo_categoria.dart';
import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  // Estado unico para movimientos
  DateTime selectedMovementsMonth = DateTime.now();
  DateTime get getSelectedMovementsMonth => selectedMovementsMonth;
  bool _isLoadingMonth = false;
  bool get isLoadingMonth => _isLoadingMonth;

  // Estado unico para presupuestos
  DateTime selectedBudgetMonth = DateTime.now();
  DateTime get getSelectedBudgetMonth => selectedBudgetMonth;
  bool _isLoadingBudget = false;
  bool get isLoadingBudget => _isLoadingBudget;

  final List<String> pageNames = [
    'Movimientos',
    'Presupuesto',
    'Historial',
    'Más acciones',
  ];
  String currentPageName = 'Movimientos';
  int currentTab = 0;
  bool isDarkMode = false;

  List<AppBarAction> _appBarActions = [];
  List<AppBarAction> get appBarActions => _appBarActions;

  final MovimientosRepository _movimientosRepository;
  final CategoriasRepository _categoriasRepository;
  final TipoCategoriaRepository _tipoCategoriaRepository;
  final PresupuestosRepository _presupuestosRepository;

  AppState(
    this._movimientosRepository,
    this._categoriasRepository,
    this._tipoCategoriaRepository,
    this._presupuestosRepository,
  );

  MovimientoFiltro _movimientoFiltro = MovimientoFiltro.todos;
  MovimientoFiltro get movimientoFiltro => _movimientoFiltro;

  TotalesMensuales? _totalesMensuales;
  double? _variacionAhorro;
  List<DateTime> _uniqueMovementDates = [];
  Map<DateTime, List<Movimiento>> _movimientosPorFecha = {};
  List<String> _uniqueTipeCategoryNames = [];

  TotalesMensuales? get totalesMensuales => _totalesMensuales;
  double? get variacionAhorro => _variacionAhorro;
  List<DateTime> get uniqueMovementDates => _uniqueMovementDates;
  List<String> get uniqueTipeCategoryNames => _uniqueTipeCategoryNames;

  List<Categoria> get categorias => _categoriasRepository.categorias;

  List<TipoCategoria> get tiposCategorias =>
      _tipoCategoriaRepository.tipoCategorias;
  List<Movimiento> get movimientos => _movimientosRepository.movimientos;

  List<Presupuesto> get presupuestos => _presupuestosRepository.presupuestos;

  String transactionResultMessage = '';
  bool transactionSuccess = false;
  bool loadingInitialData = true;

  // Cargar datos iniciales de los repositorios
  Future<void> loadInitialData() async {
    await Future.wait([
      _tipoCategoriaRepository.fetchTipoCategorias(),
      _categoriasRepository.fetchCategorias(),
      loadMovementsByMonthAndYear(selectedMovementsMonth, notify: false),
      loadPresupuestosByMonthAndYear(selectedBudgetMonth, notify: false),
    ]);
    await loadCategoryData(notify: false);
    loadingInitialData = false;

    notifyListeners();
  }

  Future<void> loadCategoryData({bool notify = true}) async {
    await _categoriasRepository.fetchCategorias();
    _uniqueTipeCategoryNames = getUniqueTipeCategoryNames();

    if (notify) notifyListeners();
  }

  Future<void> loadMovementsByMonthAndYear(
    DateTime date, {
    bool notify = true,
  }) async {
    await _movimientosRepository.fetchMovimientosByMonthAndYear(date);

    _totalesMensuales = await _movimientosRepository.fetchTotalesMensuales(
      selectedMovementsMonth,
    );

    _variacionAhorro = await calcularVariacionAhorro(selectedMovementsMonth);

    _movimientosPorFecha = _fetchMovimientosPorFecha();

    _uniqueMovementDates = _fetchUniqueMovementDates();

    if (notify) notifyListeners();
  }

  Future<void> loadPresupuestosByMonthAndYear(DateTime date, {bool notify = true}) async {
    await _presupuestosRepository.fetchPresupuestosByMonthAndYear(date);
    if (notify) notifyListeners();
  }

  Future<int> countMovementsByCategory(int categoryId) async {
    return await _movimientosRepository.fetchMovimientoCountByCategory(
      categoryId,
    );
  }

  void changeMovimientoFiltro(MovimientoFiltro filtro) {
    if (_movimientoFiltro == filtro) return;
    _movimientoFiltro = filtro;
    notifyListeners();
  }

  int getTotalCategoriasCount() {
    return categorias.length;
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
    try {
      return tiposCategorias.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  TipoMovimiento? getTipoMovimientoByCategoriaId(int categoriaId) {
    final categoria = getCategoriaById(categoriaId);
    if (categoria == null) return null;

    return categoria.movementType;
  }

  Presupuesto? getPresupuestoByCategoriaId(int categoriaId) {
    try {
      return presupuestos.firstWhere((p) => p.categoryId == categoriaId);
    } catch (e) {
      return null;
    }
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

  // Obtener movimientos por categoria (id)
  List<Movimiento> getMovimientosByCategoriaId(int categoriaId) {
    return movimientos.where((m) => m.categoryID == categoriaId).toList();
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

    return movimientos
        .where(
          (m) => filtro == MovimientoFiltro.ingresos
              ? getTipoMovimientoByCategoriaId(m.categoryID) == TipoMovimiento.ingreso
              : getTipoMovimientoByCategoriaId(m.categoryID) == TipoMovimiento.gasto,
        )
        .toList();
  }

  // Obtener todas las categorias de un tipo de categoria
  List<Categoria> getCategoriasByTipoCategoria(String tipoCategoriaName) {
    return categorias
        .where(
          (cat) =>
              getCategoryTypeById(cat.categoryTypeID)?.name ==
              tipoCategoriaName,
        )
        .toList();
  }

  List<String> getUniqueTipeCategoryNames() {
    return tiposCategorias.map((tipoCat) => tipoCat.name).toSet().toList();
  }

  // Calcular la variacion de ahorro entre dos meses
  Future<double?> calcularVariacionAhorro(DateTime mesActual) async {
    final actual = await _movimientosRepository.fetchTotalesMensuales(mesActual);
    final anterior = await _movimientosRepository.fetchTotalesMensualesMesPasado(
      mesActual,
    );

    if (anterior.ahorro == 0) return null;

    return ((actual.ahorro - anterior.ahorro) / anterior.ahorro) * 100;
  }

  // Obtener el acumulado de gastos para una categoria en el mes seleccionado
  double getGastoAcumuladoPorCategoriaEnMes(int categoriaId) {
    final movimientosCategoria = getMovimientosByCategoriaId(categoriaId);

    final gastosEnMes = movimientosCategoria.where((m) {
      return getTipoMovimientoByCategoriaId(m.categoryID) == TipoMovimiento.gasto &&
          m.date.year == selectedMovementsMonth.year &&
          m.date.month == selectedMovementsMonth.month;
    }).toList();

    final totalGastos = gastosEnMes.fold<double>(
      0.0,
      (sum, m) => sum + m.amount,
    );

    return totalGastos;
  }

  void setDarkMode(bool value) {
    isDarkMode = value;
    notifyListeners();
  }

  void changeTab(int index) {
    if (currentTab == index) return;

    currentTab = index;
    currentPageName = pageNames[index];
    notifyListeners();
  }

  Future<void> changeMovementsMonth(DateTime month) async {
    selectedMovementsMonth = month;
    _isLoadingMonth = true;
    notifyListeners();

    await loadMovementsByMonthAndYear(month);

    _isLoadingMonth = false;
    notifyListeners();
  }

  Future<void> changeBudgetMonth(DateTime month) async {
    selectedBudgetMonth = month;
    _isLoadingBudget = true;
    notifyListeners();

    await loadPresupuestosByMonthAndYear(month);

    _isLoadingBudget = false;
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
    transactionResultMessage = result.message;
    transactionSuccess = result.success;
    if (result.success == true) {
      await loadMovementsByMonthAndYear(selectedMovementsMonth);
    }
  }

  Future<void> actualizarMovimiento(Movimiento movimiento) async {
    final result = await _movimientosRepository.updateMovimiento(movimiento);
    transactionResultMessage = result.message;
    transactionSuccess = result.success;
    if (result.success == true) {
      await loadMovementsByMonthAndYear(selectedMovementsMonth);
    }
  }

  Future<void> eliminarMovimiento(int id) async {
    final result = await _movimientosRepository.deleteMovimiento(id);
    transactionResultMessage = result.message;
    transactionSuccess = result.success;
    if (result.success == true) {
      await loadMovementsByMonthAndYear(selectedMovementsMonth);
    }
  }

  // ================================ CATEGORIAS CRUD =================================
  Future<void> agregarCategoria(Categoria categoria) async {
    final result = await _categoriasRepository.addCategoria(categoria);
    transactionResultMessage = result.message;
    transactionSuccess = result.success;
    if (result.success == true) {
      await loadCategoryData();
    }
  }

  Future<void> actualizarCategoria(Categoria categoria) async {
    final result = await _categoriasRepository.updateCategoria(categoria);
    transactionResultMessage = result.message;
    transactionSuccess = result.success;
    if (result.success == true) {
      await loadCategoryData();
    }
  }

  Future<void> eliminarCategoria(int id) async {
    final result = await _categoriasRepository.deleteCategoria(id);
    transactionResultMessage = result.message;
    transactionSuccess = result.success;
    if (result.success == true) {
      await loadCategoryData();
    }
  }

  // ================================ PRESUPUESTOS CRUD =================================
  Future<void> agregarPresupuesto(Presupuesto presupuesto) async {
    final result = await _presupuestosRepository.addPresupuesto(presupuesto);
    transactionResultMessage = result.message;
    transactionSuccess = result.success;
    if (result.success == true) {
      await loadPresupuestosByMonthAndYear(selectedBudgetMonth);
    }
  }

  Future<void> actualizarPresupuesto(Presupuesto presupuesto) async {
    final result = await _presupuestosRepository.updatePresupuesto(presupuesto);
    transactionResultMessage = result.message;
    transactionSuccess = result.success;
    if (result.success == true) {
      await loadPresupuestosByMonthAndYear(selectedBudgetMonth);
    }
  }

  Future<void> eliminarPresupuesto(int id) async {
    final result = await _presupuestosRepository.deletePresupuesto(id);
    transactionResultMessage = result.message;
    transactionSuccess = result.success;
    if (result.success == true) {
      await loadPresupuestosByMonthAndYear(selectedBudgetMonth);
    }
  }
}
