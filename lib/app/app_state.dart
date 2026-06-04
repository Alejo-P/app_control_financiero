import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/models/app_bar_action.dart';
import 'package:control_financiero/core/services/backup_service.dart';
import 'package:control_financiero/core/services/notification_service.dart';
import 'package:control_financiero/core/utils/app_logger.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/features/categorias/data/categorias_repository.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';
import 'package:control_financiero/features/categorias/models/detalle_categoria.dart';
import 'package:control_financiero/features/historial/data/historial_repository.dart';
import 'package:control_financiero/features/historial/models/month_data.dart';
import 'package:control_financiero/features/movimientos/data/movimientos_repository.dart';
import 'package:control_financiero/features/movimientos/models/detalle_movimiento.dart';
import 'package:control_financiero/features/movimientos/models/movimiento.dart';
import 'package:control_financiero/features/movimientos/models/totales_mensuales.dart';
import 'package:control_financiero/features/notificaciones/data/notificacion_repository.dart';
import 'package:control_financiero/features/notificaciones/models/budget_notification.dart';
import 'package:control_financiero/features/notificaciones/models/budget_notification_event.dart';
import 'package:control_financiero/features/notificaciones/models/notificacion.dart';
import 'package:control_financiero/features/presupuestos/data/presupuestos_repository.dart';
import 'package:control_financiero/features/presupuestos/models/detalle_presupuesto.dart';
import 'package:control_financiero/features/presupuestos/models/ingreso_presupuestado.dart';
import 'package:control_financiero/features/presupuestos/models/presupuesto.dart';
import 'package:control_financiero/features/tipo_categorias/data/tipo_categoria_repository.dart';
import 'package:control_financiero/features/tipo_categorias/models/tipo_categoria.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:io';

class AppState extends ChangeNotifier {
  // Estado unico para movimientos
  DateTime selectedMovementsMonth = currentDateTime;
  DateTime get getSelectedMovementsMonth => selectedMovementsMonth;
  bool _isLoadingMonth = false;
  bool get isLoadingMonth => _isLoadingMonth;

  // Estado unico para presupuestos
  DateTime selectedBudgetMonth = currentDateTime;
  DateTime get getSelectedBudgetMonth => selectedBudgetMonth;
  bool _isLoadingBudget = false;
  bool get isLoadingBudget => _isLoadingBudget;

  // Estado unico para el historial
  DateTime selectedHistoryMonth = currentDateTime;
  bool _isLoadingHistory = false;
  bool get isLoadingHistory => _isLoadingHistory;

  // Estados para las notificaciones
  bool _isLoadingNotif = false;
  bool _hasMoreNotif = false;
  bool get isLoadingNotif => _isLoadingNotif;
  bool get hasMoreNotif => _hasMoreNotif;

  final List<String> pageNames = [
    'Movimientos',
    'Presupuestos',
    'Historial',
    'Más acciones',
  ];
  String currentPageName = 'Movimientos';
  int currentTab = 0;

  // Configuracion de caja para Hive
  static const _settingsBox = 'settings';
  static const _themeKey = 'dark_mode';
  static const _notificationKey = 'enable_notifications';

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  bool _isEnableNotifications = true;
  bool get isEnableNotifications => _isEnableNotifications;

  List<AppBarAction> _appBarActions = [];
  List<AppBarAction> get appBarActions => _appBarActions;

  final MovimientosRepository _movimientosRepository;
  final CategoriasRepository _categoriasRepository;
  final TipoCategoriaRepository _tipoCategoriaRepository;
  final PresupuestosRepository _presupuestosRepository;
  final HistorialRepository _historialRepository;
  final NotificacionRepository _notificacionRepository;

  AppState(
    this._movimientosRepository,
    this._categoriasRepository,
    this._tipoCategoriaRepository,
    this._presupuestosRepository,
    this._historialRepository,
    this._notificacionRepository,
  );

  MovimientoFiltro _movimientoFiltro = MovimientoFiltro.todos;
  MovimientoFiltro get movimientoFiltro => _movimientoFiltro;

  TotalesMensuales? _totalesMensuales;
  IngresoPresupuestado? _ingresoPresupuestado;
  double? _totalIngresoPresupuestado;
  double? _variacionAhorro;
  double? _totalGastos;
  List<DateTime> _uniqueMovementDates = [];
  Map<DateTime, List<Movimiento>> _movimientosPorFecha = {};
  List<String> _uniqueTipeCategoryNames = [];
  TotalesMensuales? get totalesMensuales => _totalesMensuales;
  IngresoPresupuestado? get ingresoPresupuestado => _ingresoPresupuestado;
  double? get totalIngresoPresupuestado => _totalIngresoPresupuestado;
  double? get variacionAhorro => _variacionAhorro;
  List<DateTime> get uniqueMovementDates => _uniqueMovementDates;
  List<DateTime> get uniqueBudgetMovementDates =>
      _fetchUniqueBudgetMovementDates();
  List<String> get uniqueTipeCategoryNames => _uniqueTipeCategoryNames;

  List<TipoCategoria> get tiposCategorias =>
      _tipoCategoriaRepository.tipoCategorias;

  List<Movimiento> movimientos = [];
  List<Categoria> categorias = [];

  List<Presupuesto> get presupuestos => _presupuestosRepository.presupuestos;
  List<BudgetNotification> budgetNotifications = [];
  List<double> get budgetThresholds => budgetNotifications.map((n) => n.threshold).toList();
  List<Movimiento> get movimientosPresupuestos =>
      _presupuestosRepository.movimientos;
  double? get totalGastos => _totalGastos;

  List<MonthData> get historialAnual => _historialRepository.historial;
  List<int> get aniosDisponibles => _historialRepository.availableYears;

  List<Notificacion> notificaciones = [];
  int notifSinLeer = 0;
  int totalNotif = 0;
  int offset = 0;

  String transactionResultMessage = '';
  bool transactionSuccess = false;
  bool loadingInitialData = true;

  // Cargar datos iniciales de los repositorios
  Future<void> loadInitialData() async {
    await initialize();

    await Future.wait([
      _tipoCategoriaRepository.fetchTipoCategorias(),
      _categoriasRepository.fetchAllCategorias(),
      loadMovementsByMonthAndYear(selectedMovementsMonth, notify: false),
      loadPresupuestosByMonthAndYear(selectedBudgetMonth, notify: false),
      updateHistory(),
      getAllThresholds(),
      loadNotifications(),
    ]);
    await loadCategoryData(notify: false);
    loadingInitialData = false;

    notifyListeners();
  }

  Future<void> loadCategoryData({bool notify = true}) async {
    categorias = await _categoriasRepository.fetchAllCategorias();
    _uniqueTipeCategoryNames = getUniqueTipeCategoryNames();

    if (notify) notifyListeners();
  }

  Future<void> loadMovementsByMonthAndYear(
    DateTime date, {
    bool notify = true,
  }) async {
    movimientos = await _movimientosRepository.fetchMovimientosByMonthAndYear(
      date,
    );

    _totalesMensuales = await _movimientosRepository.fetchTotalesMensuales(
      selectedMovementsMonth,
    );

    _variacionAhorro = await calcularVariacionAhorro(selectedMovementsMonth);

    _movimientosPorFecha = _fetchMovimientosPorFecha();

    _uniqueMovementDates = _fetchUniqueMovementDates();

    if (notify) notifyListeners();
  }

  Future<Box> _getSettingsBox() async {
    if (!Hive.isBoxOpen(_settingsBox)) {
      return await Hive.openBox(_settingsBox);
    }
    return Hive.box(_settingsBox);
  }

  Future<void> initialize() async {
    final box = await _getSettingsBox();
    _isDarkMode = box.get(_themeKey, defaultValue: false);
    _isEnableNotifications = box.get(_notificationKey, defaultValue: true);
  }

  Future<void> loadPresupuestosByMonthAndYear(
    DateTime date, {
    bool notify = true,
  }) async {
    await _presupuestosRepository.fetchPresupuestosByMonthAndYear(date);

    _ingresoPresupuestado = await _presupuestosRepository
        .fetchIngresosPresupuestadosByMonthAndYear(date);
    calculateTotalIngresoPresupuestado();
    _totalGastos = _presupuestosRepository.getTotalGastosByMonthAndYear(date);
    if (notify) notifyListeners();
  }

  Future<Presupuesto?> fetchPresupuestoById(int id) async {
    final presupuesto = await _presupuestosRepository.fetchPresupuestoById(id);
    return presupuesto;
  }

  Future<DetallePresupuesto?> obtenerDetallePresupuestoPorId(int id) async {
    final detallePresupuesto = await _presupuestosRepository
        .fetchDetallePresupuestoById(id);
    return detallePresupuesto;
  }

  Future<double> obtenerSumaPresupuestosPorFecha(DateTime date) async {
    return await _presupuestosRepository
        .fetchPresupuestosAmountSumByMonthAndYear(date);
  }

  Future<double> _getUsedBudgetPercentage(int categoryID, DateTime date) async {
    final presupuestoUsado = await _presupuestosRepository
        .fetchPresupuestoUtilizadoPercentageByCategoryAndMonth(
          categoryID,
          date,
        );

    return presupuestoUsado;
  }

  Future<List<double>> getThresholdsToNotify(
    int categoryId,
    DateTime date,
  ) async {
    final porcentajeUsado = await _getUsedBudgetPercentage(categoryId, date);

    final configs = await _notificacionRepository
        .fetchGlobalEnabledThresholds();

    final events = await _notificacionRepository
        .fetchBudgetNotificationEventsByCategoryIdAndDate(categoryId, date);

    final sentThresholds = events.map((e) => e.threshold).toSet();

    final thresholdsToNotify = <double>[];

    for (final threshold in configs) {
      final shouldNotify =
          porcentajeUsado >= threshold && !sentThresholds.contains(threshold);

      if (shouldNotify) {
        thresholdsToNotify.add(threshold);
      }
    }

    return thresholdsToNotify;
  }

  Future<void> getAllThresholds() async {
    final configs = await _notificacionRepository.fetchAllBudgetNotifications();
    // Ordenar por umbral de mayor a menor
    configs.sort((a, b) => b.threshold.compareTo(a.threshold));
    budgetNotifications = configs;
    notifyListeners();
  }

  Future<void> addOrUpdateBudgetNotification(BudgetNotification notification) async {
    int newId = await _notificacionRepository.addOrUpdateBudgetNotification(notification);
    if (notification.id == null) {
      final newNotification = notification.copyWith(id: newId);
      budgetNotifications.add(newNotification);
      budgetNotifications.sort((a, b) => b.threshold.compareTo(a.threshold));
    }
    notifyListeners();
  }

  Future<void> updateBudgetNotification({
    required int id,
    bool? isEnabledNotification,
  }) async {
    final notification = budgetNotifications.firstWhere((n) => n.id == id);
    final updatedNotification = notification.copyWith(
      isEnabledNotification: isEnabledNotification ?? notification.isEnabledNotification,
    );
    budgetNotifications = budgetNotifications.map((n) => n.id == id ? updatedNotification : n).toList();
    budgetNotifications.sort((a, b) => b.threshold.compareTo(a.threshold));

    await addOrUpdateBudgetNotification(updatedNotification);
  }

  Future<void> deleteBudgetNotification(int id) async {
    final success = await _notificacionRepository.deleteBudgetNotification(id);
    if (success) {
      budgetNotifications.removeWhere((n) => n.id == id);
      notifyListeners();
    }
  }

  Future<void> updateHistory() async {
    await _historialRepository.fetchAvailableYears();
    await _historialRepository.fetchYearHistory(selectedHistoryMonth);
    notifyListeners();
  }

  Future<void> loadNotifications() async {
    offset = 0;

    final data = await _notificacionRepository.fetchNotificaciones(
      offset: offset,
    );

    notificaciones = data;

    offset += data.length;

    _hasMoreNotif = data.isNotEmpty && data.length >= 10;

    await updateCountersNotif(notify: false);

    notifyListeners();
  }

  Future<void> updateCountersNotif({bool notify = true}) async {
    totalNotif = await _notificacionRepository.countNotificaciones();
    notifSinLeer = await _notificacionRepository.getUnreadCount();
    if (notify) notifyListeners();
  }

  Future<void> fetchMoreNotifications() async {
    if (_isLoadingNotif || !_hasMoreNotif) return;

    _isLoadingNotif = true;
    notifyListeners();

    final newData = await _notificacionRepository.fetchNotificaciones(
      offset: offset,
    );

    if (newData.isEmpty) {
      _hasMoreNotif = false;
    } else {
      offset += newData.length;
      notificaciones.addAll(newData);

      _hasMoreNotif = newData.isNotEmpty;
    }

    _isLoadingNotif = false;
    notifyListeners();
  }

  int countMovementsByCategory(int categoryId) {
    int total = 0;

    for (var movimiento in movimientos) {
      if (movimiento.categoryID == categoryId) {
        total += 1;
      }
    }

    return total;
  }

  Future<IngresoPresupuestado> getIngresoPresupuestadoByMonthAndYear(
    DateTime date,
  ) async {
    return await _presupuestosRepository
        .fetchIngresosPresupuestadosByMonthAndYear(date);
  }

  // Descontar del ingreso total presupuestado el monto de los presupuestos asignados
  Future<void> calculateTotalIngresoPresupuestado() async {
    if (_ingresoPresupuestado == null) return;

    _totalIngresoPresupuestado = _ingresoPresupuestado!.monto;
    if (_totalIngresoPresupuestado == null) return;

    if (_totalIngresoPresupuestado! <= 0) return;

    for (var presupuesto in presupuestos) {
      _totalIngresoPresupuestado =
          _totalIngresoPresupuestado! - presupuesto.amount;
    }
    notifyListeners();
  }

  Future<void> setIngresoPresupuestado(IngresoPresupuestado ingreso) async {
    final result = await _presupuestosRepository.upsertIngresoPresupuestado(
      ingreso,
    );
    transactionResultMessage = result.message;
    transactionSuccess = result.success;
    if (result.success && result.data != null) {
      _ingresoPresupuestado = ingreso.copyWith(id: result.data!);
      await calculateTotalIngresoPresupuestado();
      notifyListeners();
    }
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

  // Obtener todas las fechas únicas de movimientos presupuestos
  List<DateTime> _fetchUniqueBudgetMovementDates() {
    final dates = movimientosPresupuestos
        .map((m) => DateTime(m.date.year, m.date.month, m.date.day))
        .toSet()
        .toList();
    dates.sort((a, b) => b.compareTo(a));
    return dates;
  }

  // Obtener todas las fechas únicas de movimientos (pasando la lista de movimientos como parametro)
  List<DateTime> fetchUniqueMovementDatesInList(
    List<Movimiento> listaMovimientos,
  ) {
    final dates = listaMovimientos
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

  // Obtener movimientos (para presupuesto) por categoria (id)
  List<Movimiento> getMovimientosPresupuestoByCategoriaId(int categoriaId) {
    return movimientosPresupuestos
        .where((m) => m.categoryID == categoriaId)
        .toList();
  }

  // Obtener movimientos presupuestos filtrados por fecha (mes y año)

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
    DateTime fecha, {
    MovimientoFiltro filtro = MovimientoFiltro.todos,
  }) {
    final movimientos = _movimientosPorFecha[fecha] ?? [];

    if (filtro == MovimientoFiltro.todos) return movimientos;

    return movimientos
        .where(
          (m) => filtro == MovimientoFiltro.ingresos
              ? getTipoMovimientoByCategoriaId(m.categoryID) ==
                    TipoMovimiento.ingreso
              : getTipoMovimientoByCategoriaId(m.categoryID) ==
                    TipoMovimiento.gasto,
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
    final actual = await _movimientosRepository.fetchTotalesMensuales(
      mesActual,
    );

    final mesAnterior = DateTime(mesActual.year, mesActual.month - 1);
    final anterior = await _movimientosRepository.fetchTotalesMensuales(
      mesAnterior,
    );

    if (anterior.ahorro == 0 && actual.ahorro == 0) return 0;
    if (anterior.ahorro == 0) return null;

    return ((actual.ahorro - anterior.ahorro) / anterior.ahorro) * 100;
  }

  // Obtener el acumulado de gastos para una categoria en el mes seleccionado
  double getGastoAcumuladoPorCategoriaEnMes(int categoriaId) {
    final movimientosCategoria = movimientosPresupuestos
        .where((m) => m.categoryID == categoriaId)
        .toList();

    final gastosEnMes = movimientosCategoria.where((m) {
      return getTipoMovimientoByCategoriaId(m.categoryID) ==
              TipoMovimiento.gasto &&
          isSameMonth(m.date, selectedBudgetMonth);
    }).toList();

    final totalGastos = gastosEnMes.fold<double>(
      0.0,
      (sum, m) => sum + m.amount,
    );

    return totalGastos;
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;

    final box = await _getSettingsBox();
    await box.put(_themeKey, value);

    notifyListeners();
  }

  Future<void> setNotifications(bool value) async {
    _isEnableNotifications = value;

    final box = await _getSettingsBox();
    await box.put(_notificationKey, value);

    notifyListeners();
  }

  void changeTab(int index) {
    if (currentTab == index) return;
    if (index > pageNames.length) {
      index = 0;
    }

    currentTab = index;
    currentPageName = pageNames[index];
    notifyListeners();
  }

  Future<void> changeMovementsMonth(DateTime month) async {
    selectedMovementsMonth = month;
    _isLoadingMonth = true;
    notifyListeners();

    await loadMovementsByMonthAndYear(month);
    await Future.delayed(const Duration(milliseconds: 300));

    _isLoadingMonth = false;
    notifyListeners();
  }

  Future<void> changeBudgetMonth(DateTime month) async {
    selectedBudgetMonth = month;
    _isLoadingBudget = true;
    notifyListeners();

    await loadPresupuestosByMonthAndYear(month);
    await Future.delayed(const Duration(milliseconds: 300));

    _isLoadingBudget = false;
    notifyListeners();
  }

  Future<void> changeHistoryYear(int year) async {
    selectedHistoryMonth = DateTime(year);
    _isLoadingHistory = true;
    notifyListeners();

    await updateHistory();
    await Future.delayed(const Duration(milliseconds: 300));

    _isLoadingHistory = false;
    notifyListeners();
  }

  Future<void> gotoMovements(DateTime dateSelected) async {
    changeTab(0);
    await changeMovementsMonth(dateSelected);
    notifyListeners();
  }

  Future<void> exportarMovimientos() async {
    final result = await _movimientosRepository.exportarMovimientosExcel();
    transactionResultMessage = result.message;
    transactionSuccess = result.success;
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

  Future<void> restoreFromBackup(String encryptKey, String pickedFile) async {
    final result = await BackupService().restoreData(encryptKey, pickedFile);
    transactionResultMessage = result.message;
    transactionSuccess = result.success;
    if (result.success) {
      await loadInitialData();
    }
    notifyListeners();
  }

  Future<void> createBackup(String encryptKey) async {
    final result = await BackupService().backupData(encryptKey);
    transactionResultMessage = result.message;
    transactionSuccess = result.success;
    notifyListeners();
  }

  // ================================= MOVIMIENTOS CRUD =================================
  Future<void> sincronizarContadoresCategorias() async {
    final counts = await _movimientosRepository.getMovementsCountByCategory();

    for (var entry in counts.entries) {
      final categoryId = entry.key;
      final newCount = entry.value;
      final index = categorias.indexWhere((c) => c.id == categoryId);
      if (index == -1) {
        AppLogger.log('Categoría con id $index no encontrada.');
      }

      final updatedCategoria = categorias[index].copyWith(
        movementsCount: newCount,
      );
      categorias[index] = updatedCategoria;
    }
    notifyListeners();
  }

  Future<List<Movimiento>> obtenerMovimientosPorCategoria(
    int categoryID,
  ) async {
    final movimientos = _movimientosRepository.getMovementsByCategoryID(
      categoryID,
    );

    return movimientos;
  }

  Future<Movimiento?> obtenerMovimientoPorId(int id) async {
    return await _movimientosRepository.fetchMovimientoById(id);
  }

  Future<DetalleMovimiento?> obtenerDetalleMovimientoPorId(int id) async {
    return await _movimientosRepository.fetchDetalleMovimientoById(id);
  }

  Future<int> agregarMovimiento(Movimiento movimiento) async {
    final result = await _movimientosRepository.addMovimiento(movimiento);
    transactionResultMessage = result.message;
    transactionSuccess = result.success;
    if (result.success == true) {
      await sincronizarContadoresCategorias();
      await loadMovementsByMonthAndYear(selectedMovementsMonth);
      await loadPresupuestosByMonthAndYear(selectedBudgetMonth);
      await updateHistory();
    }
    return result.data ?? -1;
  }

  Future<int?> actualizarMovimiento(Movimiento movimiento) async {
    final result = await _movimientosRepository.updateMovimiento(movimiento);
    transactionResultMessage = result.message;
    transactionSuccess = result.success;
    if (result.success == true) {
      await sincronizarContadoresCategorias();
      await loadMovementsByMonthAndYear(selectedMovementsMonth);
      await loadPresupuestosByMonthAndYear(selectedBudgetMonth);
      await updateHistory();
    }
    return null;
  }

  Future<void> eliminarMovimiento(int id, int categoryId) async {
    final result = await _movimientosRepository.deleteMovimiento(id);
    transactionResultMessage = result.message;
    transactionSuccess = result.success;
    if (result.success == true) {
      await sincronizarContadoresCategorias();
      await loadMovementsByMonthAndYear(selectedMovementsMonth);
      await loadPresupuestosByMonthAndYear(selectedBudgetMonth);
      await updateHistory();
    }
  }

  // ================================ CATEGORIAS CRUD =================================
  Future<DetalleCategoria?> obtenerDetalleCategoriaPorId(int id) async {
    return await _categoriasRepository.fetchDetalleCategoriaById(id);
  }

  Future<void> agregarCategoria(Categoria categoria) async {
    final result = await _categoriasRepository.addCategoria(categoria);
    transactionResultMessage = result.message;
    transactionSuccess = result.success;
    if (result.success == true) {
      categorias.add(categoria.copyWith(id: result.data!));
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
  Future<int> agregarPresupuesto(Presupuesto presupuesto) async {
    final result = await _presupuestosRepository.addPresupuesto(presupuesto);
    transactionResultMessage = result.message;
    transactionSuccess = result.success;
    if (result.success == true) {
      await loadPresupuestosByMonthAndYear(selectedBudgetMonth);
    }
    return result.data ?? -1;
  }

  Future<int?> actualizarPresupuesto(Presupuesto presupuesto) async {
    final result = await _presupuestosRepository.updatePresupuesto(presupuesto);
    transactionResultMessage = result.message;
    transactionSuccess = result.success;
    if (result.success == true) {
      await loadPresupuestosByMonthAndYear(selectedBudgetMonth);
    }
    return null;
  }

  Future<void> eliminarPresupuesto(int id) async {
    final result = await _presupuestosRepository.deletePresupuesto(id);
    transactionResultMessage = result.message;
    transactionSuccess = result.success;
    if (result.success == true) {
      await loadPresupuestosByMonthAndYear(selectedBudgetMonth);
    }
  }

  // ================================ NOTIFICACIONES CRUD =================================
  Future<Notificacion?> getNotificacionById(int id) async {
    final result = await _notificacionRepository.fetchNotificacionById(id);

    return result;
  }

  Future<bool> allNotificationsRead() async {
    final unreadCount = await _notificacionRepository.getUnreadCount();
    return unreadCount == 0;
  }

  Future<bool> insertarBudgetNotificationEvent(
    BudgetNotificationEvent event,
  ) async {
    final result = await _notificacionRepository.addBudgetNotificationEvent(
      event,
    );
    return result.success;
  }

  Future<bool> insertarNotificacion(
    Notificacion notificacion, {
    bool showNotification = false,
  }) async {
    final result = await _notificacionRepository.addNotificacion(notificacion);
    if (result.success) {
      notificaciones.insert(0, notificacion.copyWith(id: result.data!));
      await updateCountersNotif();

      if (showNotification && (Platform.isAndroid || Platform.isIOS)) {
        await NotificationService.showNotification(
          title: notificacion.title,
          body: notificacion.description,
          id: result.data!,
          type: notificacion.type,
        );
      }
    }

    return result.success;
  }

  Future<bool> eliminarNotificacion(int id) async {
    final success = await _notificacionRepository.deleteNotificacion(id);
    if (success) {
      notificaciones.removeWhere((n) => n.id == id);
      await updateCountersNotif();
    }

    return success;
  }

  Future<bool> eliminarTodasNotificaciones() async {
    final result = await _notificacionRepository.deleteAllNotificaciones();
    if (result.success) {
      notificaciones.clear();
      await updateCountersNotif();
    }

    return result.success;
  }

  Future<void> ocultarNotificacion(int id) async {
    await NotificationService.cancelNotification(id);
  }

  Future<void> ocultarTodasNotificaciones() async {
    await NotificationService.cancelAllNotifications();
  }

  Future<void> marcarNotifLeida(Notificacion notificacion) async {
    if (notificacion.isRead == true) return;

    await _notificacionRepository.markAsRead(notificacion.id!);
    await NotificationService.cancelNotification(notificacion.id!);
    final index = notificaciones.indexWhere((n) => n.id! == notificacion.id!);
    if (index != -1) {
      notificaciones[index] = notificacion.copyWith(isRead: true);
    }
    await updateCountersNotif();
  }

  Future<void> marcarTodaNotifLeida() async {
    if (await allNotificationsRead()) return;

    await _notificacionRepository.markAllRead();
    await NotificationService.cancelAllNotifications();

    notificaciones = notificaciones
        .map((n) => n.copyWith(isRead: true))
        .toList();
    await updateCountersNotif();
  }
}
