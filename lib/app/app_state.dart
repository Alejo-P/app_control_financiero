import 'package:control_financiero/features/movimientos/models/movimiento_search_page_result.dart';
import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/models/app_bar_action.dart';
import 'package:control_financiero/core/services/backup_service.dart';
import 'package:control_financiero/core/services/notification_service.dart';
import 'package:control_financiero/core/utils/app_logger.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/core/utils/record_date_limits.dart';
import 'package:control_financiero/core/models/operation_result.dart';
import 'package:control_financiero/core/utils/encryption_helper.dart';
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
import 'package:control_financiero/features/notificaciones/models/movement_notification_config.dart';
import 'package:control_financiero/features/notificaciones/models/notificacion.dart';
import 'package:control_financiero/features/presupuestos/data/presupuestos_repository.dart';
import 'package:control_financiero/features/presupuestos/models/category_card_info.dart';
import 'package:control_financiero/features/presupuestos/models/detalle_presupuesto.dart';
import 'package:control_financiero/features/presupuestos/models/ingreso_presupuestado.dart';
import 'package:control_financiero/features/presupuestos/models/presupuesto.dart';
import 'package:control_financiero/features/recordatorios/data/recordatorios_repository.dart';
import 'package:control_financiero/features/recordatorios/models/detalle_recordatorio.dart';
import 'package:control_financiero/features/recordatorios/models/info_card_recordatorio.dart';
import 'package:control_financiero/features/recordatorios/models/recordatorio.dart';
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
  int _movementsLoadId = 0;
  int _movementsMonthChangeId = 0;

  // Estado unico para presupuestos
  DateTime selectedBudgetMonth = currentDateTime;
  DateTime get getSelectedBudgetMonth => selectedBudgetMonth;
  bool _isLoadingBudget = false;
  bool get isLoadingBudget => _isLoadingBudget;
  int _budgetLoadId = 0;
  int _budgetMonthChangeId = 0;

  // Estado unico para el historial
  DateTime selectedHistoryMonth = currentDateTime;
  bool _isLoadingHistory = false;
  bool get isLoadingHistory => _isLoadingHistory;
  int _historyLoadId = 0;
  int _historyYearChangeId = 0;

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

  static const _backupBox = 'backup';
  static const _backupKey = 'backup_encryption_key';

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  String _backupEncryptionKey = '';
  String get backupEncryptionKey => _backupEncryptionKey;

  List<AppBarAction> _appBarActions = [];
  FloatingActionButton? _floatingActionButton;
  bool _showFAB = true;
  List<AppBarAction> get appBarActions => _appBarActions;
  FloatingActionButton? get floatingActionButton => _floatingActionButton;
  bool get showFAB => _showFAB;

  final MovimientosRepository _movimientosRepository;
  final CategoriasRepository _categoriasRepository;
  final TipoCategoriaRepository _tipoCategoriaRepository;
  final PresupuestosRepository _presupuestosRepository;
  final HistorialRepository _historialRepository;
  final NotificacionRepository _notificacionRepository;
  final RecordatoriosRepository _recordatoriosRepository;

  AppState(
    this._movimientosRepository,
    this._categoriasRepository,
    this._tipoCategoriaRepository,
    this._presupuestosRepository,
    this._historialRepository,
    this._notificacionRepository,
    this._recordatoriosRepository,
  );

  TotalesMensuales? _totalesMensuales;
  IngresoPresupuestado? _ingresoPresupuestado;
  double? _totalIngresoPresupuestado;
  double? _variacionAhorro;
  double? _totalGastos;
  List<DateTime> _uniqueMovementDates = [];
  Map<DateTime, List<DetalleMovimiento>> _movimientosPorFecha = {};
  Map<DateTime, List<DetalleMovimiento>> get movimientosPorFecha =>
      _movimientosPorFecha;
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

  List<DetalleMovimiento> movimientos = [];
  List<Categoria> categorias = [];
  List<InfoCardRecordatorio> recordatorios = [];
  List<CategoryCardInfo> presupuestos = [];
  List<DetalleMovimiento> movimientosPresupuestos = [];
  List<BudgetNotification> budgetNotifications = [];
  List<MovementNotificationConfig> movementNotificationConfigs = [];
  List<double> get budgetThresholds =>
      budgetNotifications.map((n) => n.threshold).toList();
  double? get totalGastos => _totalGastos;

  List<MonthData> historialAnual = [];
  List<int> aniosDisponibles = [];
  List<Notificacion> notificaciones = [];
  int notifSinLeer = 0;
  int totalNotif = 0;
  int offset = 0;

  String transactionResultMessage = '';
  bool transactionSuccess = false;
  bool loadingInitialData = true;

  // Cargar datos iniciales de los repositorios
  Future<void> loadInitialData() async {
    try {
      await initialize();

      await Future.wait([
        _tipoCategoriaRepository.fetchTipoCategorias(),
        _categoriasRepository.fetchAllCategorias(),
        loadMovementsByMonthAndYear(selectedMovementsMonth, notify: false),
        loadPresupuestosByMonthAndYear(selectedBudgetMonth, notify: false),
        updateHistory(),
        getAllThresholds(),
        loadMovementNotificationConfigs(),
        loadNotifications(),
      ]);
      await loadCategoryData(notify: false);
      await loadRecordatoriosData(notify: false);
      loadingInitialData = false;

      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.reportError('AppState.loadInitialData', error, stackTrace);
      rethrow;
    }
  }

  Future<void> loadCategoryData({bool notify = true}) async {
    try {
      categorias = await _categoriasRepository.fetchAllCategorias();
      _uniqueTipeCategoryNames = getUniqueTipeCategoryNames();

      if (notify) notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.reportError('AppState.loadCategoryData', error, stackTrace);
      rethrow;
    }
  }

  Future<void> loadRecordatoriosData({bool notify = true}) async {
    try {
      recordatorios = await _recordatoriosRepository
          .fetchAllDetailedRecordatorios();

      await syncRecordatorioNotifications();

      if (notify) notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.reportError(
        'AppState.loadRecordatoriosData',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  // Serialize refreshes and read current data when each refresh starts.
  Future<void> _reminderSync = Future<void>.value();

  Future<void> syncRecordatorioNotifications() {
    final next = _reminderSync.then((_) => _syncReminders());
    _reminderSync = next.catchError((Object _) {});
    return next;
  }

  Future<void> _syncReminders({DateTime? referenceDateTime}) async {
    try {
      final now = referenceDateTime ?? currentDateTime;
      final reminders = await _recordatoriosRepository.fetchAllRecordatorios();
      for (var i = 0; i < reminders.length; i++) {
        final reminder = reminders[i];
        if (!reminder.enabled ||
            reminder.id == null ||
            reminder.scheduledAt.isAfter(now)) {
          continue;
        }
        var nextDate = reminder.scheduledAt;
        final recurring = reminder.recurrencia != Recurrencia.ninguno;
        if (recurring) {
          while (!nextDate.isAfter(now)) {
            nextDate = calculateNextOccurrence(nextDate, reminder.recurrencia);
          }
        }
        // Derive the displayed next occurrence without overwriting a concurrent
        // edit/toggle in SQLite. The persisted date remains the recurrence anchor.
        final index = recordatorios.indexWhere((r) => r.id == reminder.id);
        if (index != -1) {
          recordatorios[index] = recordatorios[index].copyWith(
            scheduledAt: nextDate,
            isEnabled: recurring,
          );
        }
      }
      final hasEnabledDaily = reminders.any((r) => r.isDefault && r.enabled);
      final hasMovementsToday =
          hasEnabledDaily &&
          (await _movimientosRepository.fetchMovimientosByDate(now)).isNotEmpty;
      await NotificationService.syncReminders(
        reminders,
        now: now,
        hasMovementsToday: hasMovementsToday,
      );
    } catch (error, stackTrace) {
      AppLogger.reportError('AppState._syncReminders', error, stackTrace);
      rethrow;
    }
  }

  Future<void> loadMovementsByMonthAndYear(
    DateTime date, {
    bool notify = true,
  }) async {
    try {
      final requestId = ++_movementsLoadId;

      final loadedMovements = await _movimientosRepository
          .fetchMovimientosByMonthAndYear(date);

      final loadedTotals = await _movimientosRepository.fetchTotalesMensuales(
        date,
      );

      final loadedVariation = await calcularVariacionAhorro(date);

      // No publicar una petición reemplazada por otra.
      if (requestId != _movementsLoadId ||
          !isSameMonth(date, selectedMovementsMonth)) {
        return;
      }

      movimientos = loadedMovements;
      _totalesMensuales = loadedTotals;
      _variacionAhorro = loadedVariation;
      _movimientosPorFecha = _fetchMovimientosPorFecha();
      _uniqueMovementDates = _fetchUniqueMovementDates();

      if (notify) notifyListeners();

      await syncDailyMovementReminder();
    } catch (error, stackTrace) {
      AppLogger.reportError(
        'AppState.loadMovementsByMonthAndYear',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<void> syncDailyMovementReminder({DateTime? referenceDateTime}) {
    final next = _reminderSync.then((_) async {
      try {
        await _syncReminders(referenceDateTime: referenceDateTime);
      } on Exception catch (error, stackTrace) {
        await AppLogger.log(
          'Error al sincronizar recordatorios: ${error.runtimeType}',
          level: LogLevel.error,
          stackTrace: stackTrace,
        );
      }
    });
    _reminderSync = next.catchError((Object _) {});
    return next;
  }

  Future<Box> _getSettingsBox() async {
    if (!Hive.isBoxOpen(_settingsBox)) {
      return await Hive.openBox(_settingsBox);
    }
    return Hive.box(_settingsBox);
  }

  Future<Box> _getBackupBox() async {
    if (!Hive.isBoxOpen(_backupBox)) {
      return await Hive.openBox(_backupBox);
    }
    return Hive.box(_backupBox);
  }

  Future<void> initialize() async {
    final settingsBox = await _getSettingsBox();
    final backupBox = await _getBackupBox();
    final storedKey = backupBox.get(_backupKey, defaultValue: '') as String;
    if (storedKey.isEmpty) {
      final newKey = EncryptionHelper.generateRandomKey();
      await backupBox.put(_backupKey, newKey);
      _backupEncryptionKey = newKey;
    } else {
      _backupEncryptionKey = storedKey;
    }

    _isDarkMode = settingsBox.get(_themeKey, defaultValue: false);
  }

  Future<void> loadPresupuestosByMonthAndYear(
    DateTime date, {
    bool notify = true,
  }) async {
    try {
      final requestId = ++_budgetLoadId;

      final loadedBudgets = await _presupuestosRepository
          .fetchCategoryCardInfoByMonthAndYear(date);

      final loadedMovements = await _presupuestosRepository
          .fetchGastosByMonthAndYear(date);

      final loadedIncome = await _presupuestosRepository
          .fetchIngresosPresupuestadosByMonthAndYear(date);

      if (requestId != _budgetLoadId ||
          !isSameMonth(date, selectedBudgetMonth)) {
        return;
      }

      presupuestos
        ..clear()
        ..addAll(loadedBudgets);

      movimientosPresupuestos
        ..clear()
        ..addAll(loadedMovements);

      _ingresoPresupuestado = loadedIncome;
      _totalGastos = loadedMovements.fold<double>(
        0.0,
        (sum, movimiento) => sum + movimiento.amount,
      );

      await calculateTotalIngresoPresupuestado(notify: false);

      if (notify) notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.reportError(
        'AppState.loadPresupuestosByMonthAndYear',
        error,
        stackTrace,
      );
      rethrow;
    }
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

    configs.sort((a, b) => a.compareTo(b));

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

  Future<void> loadMovementNotificationConfigs() async {
    final configs = await _notificacionRepository
        .fetchAllMovementNotificationConfigs();
    movementNotificationConfigs = configs;
    notifyListeners();
  }

  MovementNotificationConfig? getMovementNotificationConfigByType(
    String typeKey,
  ) {
    try {
      return movementNotificationConfigs.firstWhere(
        (config) => config.typeKey == typeKey,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> addOrUpdateMovementNotificationConfig(
    MovementNotificationConfig config,
  ) async {
    try {
      int newId = await _notificacionRepository
          .addOrUpdateMovementNotificationConfig(config);
      if (config.id == null) {
        final newConfig = config.copyWith(id: newId);
        movementNotificationConfigs.add(newConfig);
      } else {
        movementNotificationConfigs = movementNotificationConfigs
            .map(
              (existing) =>
                  existing.typeKey == config.typeKey ? config : existing,
            )
            .toList();
      }
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.reportError(
        'AppState.addOrUpdateMovementNotificationConfig',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<void> updateMovementNotificationConfig({
    required String typeKey,
    required bool isEnabled,
  }) async {
    try {
      final config = getMovementNotificationConfigByType(typeKey);
      if (config == null) return;

      final updatedConfig = config.copyWith(isEnabled: isEnabled);
      await addOrUpdateMovementNotificationConfig(updatedConfig);
    } catch (error, stackTrace) {
      AppLogger.reportError(
        'AppState.updateMovementNotificationConfig',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<void> addOrUpdateBudgetNotification(
    BudgetNotification notification,
  ) async {
    try {
      int newId = await _notificacionRepository.addOrUpdateBudgetNotification(
        notification,
      );
      if (notification.id == null) {
        final newNotification = notification.copyWith(id: newId);
        budgetNotifications.add(newNotification);
        budgetNotifications.sort((a, b) => b.threshold.compareTo(a.threshold));
      }
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.reportError(
        'AppState.addOrUpdateBudgetNotification',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<void> updateBudgetNotification({
    required int id,
    bool? isEnabledNotification,
  }) async {
    try {
      final notification = budgetNotifications.firstWhere((n) => n.id == id);
      final updatedNotification = notification.copyWith(
        isEnabledNotification:
            isEnabledNotification ?? notification.isEnabledNotification,
      );
      budgetNotifications = budgetNotifications
          .map((n) => n.id == id ? updatedNotification : n)
          .toList();
      budgetNotifications.sort((a, b) => b.threshold.compareTo(a.threshold));

      await addOrUpdateBudgetNotification(updatedNotification);
    } catch (error, stackTrace) {
      AppLogger.reportError(
        'AppState.updateBudgetNotification',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<void> deleteBudgetNotification(int id) async {
    try {
      final success = await _notificacionRepository.deleteBudgetNotification(
        id,
      );
      if (success) {
        budgetNotifications.removeWhere((n) => n.id == id);
        notifyListeners();
      }
    } catch (error, stackTrace) {
      AppLogger.reportError(
        'AppState.deleteBudgetNotification',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<void> updateHistory({bool notify = true}) async {
    try {
      final requestId = ++_historyLoadId;
      final selectedDate = selectedHistoryMonth;

      final loadedYears = await _historialRepository.fetchAvailableYears();
      final loadedHistory = await _historialRepository.fetchYearHistory(
        selectedDate,
      );

      if (requestId != _historyLoadId ||
          selectedDate.year != selectedHistoryMonth.year) {
        return;
      }

      aniosDisponibles = loadedYears;
      historialAnual = loadedHistory;

      if (notify) notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.reportError('AppState.updateHistory', error, stackTrace);
      rethrow;
    }
  }

  Future<void> loadNotifications({int limit = 10}) async {
    try {
      _isLoadingNotif = true;
      notifyListeners();

      try {
        final data = await _notificacionRepository.fetchNotificaciones(
          offset: 0,
          limit: limit,
        );

        await updateCountersNotif(notify: false);

        notificaciones = data;
        offset = data.length;
        _hasMoreNotif = offset < totalNotif;
      } finally {
        _isLoadingNotif = false;
        notifyListeners();
      }
    } catch (error, stackTrace) {
      AppLogger.reportError('AppState.loadNotifications', error, stackTrace);
      rethrow;
    }
  }

  Future<void> updateCountersNotif({bool notify = true}) async {
    totalNotif = await _notificacionRepository.countNotificaciones();
    notifSinLeer = await _notificacionRepository.getUnreadCount();
    if (notify) notifyListeners();
  }

  Future<void> fetchMoreNotifications() async {
    try {
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

        _hasMoreNotif = newData.length >= 10;
      }

      _isLoadingNotif = false;
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.reportError(
        'AppState.fetchMoreNotifications',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<IngresoPresupuestado> getIngresoPresupuestadoByMonthAndYear(
    DateTime date,
  ) async {
    return await _presupuestosRepository
        .fetchIngresosPresupuestadosByMonthAndYear(date);
  }

  // Descontar del ingreso total presupuestado el monto de los presupuestos asignados
  Future<void> calculateTotalIngresoPresupuestado({bool notify = true}) async {
    if (_ingresoPresupuestado == null) return;

    _totalIngresoPresupuestado = _ingresoPresupuestado!.monto;
    if (_totalIngresoPresupuestado == null) return;

    if (_totalIngresoPresupuestado! <= 0) return;

    for (var presupuesto in presupuestos) {
      _totalIngresoPresupuestado =
          _totalIngresoPresupuestado! - presupuesto.total;
    }
    if (notify) notifyListeners();
  }

  Future<void> setIngresoPresupuestado(IngresoPresupuestado ingreso) async {
    try {
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
    } catch (error, stackTrace) {
      AppLogger.reportError(
        'AppState.setIngresoPresupuestado',
        error,
        stackTrace,
      );
      rethrow;
    }
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
    List<DetalleMovimiento> listaMovimientos,
  ) {
    final dates = listaMovimientos
        .map((m) => DateTime(m.date.year, m.date.month, m.date.day))
        .toSet()
        .toList();

    dates.sort((a, b) => b.compareTo(a));
    return dates;
  }

  // Obtener movimientos (para presupuesto) por categoria (id)
  List<DetalleMovimiento> getMovimientosPresupuestoByCategoriaId(
    int categoriaId,
  ) {
    return movimientosPresupuestos
        .where((m) => m.categoryId == categoriaId)
        .toList();
  }

  // Obtener movimientos presupuestos filtrados por fecha (mes y año)

  // Obtener movimientos agrupados por fecha
  Map<DateTime, List<DetalleMovimiento>> _fetchMovimientosPorFecha() {
    final Map<DateTime, List<DetalleMovimiento>> groupedMovements = {};

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

    final sortedMap = <DateTime, List<DetalleMovimiento>>{};
    for (var key in sortedKeys) {
      sortedMap[key] = groupedMovements[key]!;
    }

    return sortedMap;
  }

  // Obtener movimientos filtrados por fecha (mes y año)
  List<DetalleMovimiento> getMovimientosByDateAndFilter(
    DateTime fecha, {
    MovimientoFiltro filtro = MovimientoFiltro.todos,
  }) {
    final movimientos = _movimientosPorFecha[fecha] ?? [];

    if (filtro == MovimientoFiltro.todos) return movimientos;

    return movimientos
        .where(
          (m) => filtro == MovimientoFiltro.ingresos
              ? m.movementType == TipoMovimiento.ingreso
              : m.movementType == TipoMovimiento.gasto,
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
        .where((m) => m.categoryId == categoriaId)
        .toList();

    final gastosEnMes = movimientosCategoria.where((m) {
      return m.movementType == TipoMovimiento.gasto &&
          isSameMonth(m.date, selectedBudgetMonth);
    }).toList();

    final totalGastos = gastosEnMes.fold<double>(
      0.0,
      (sum, m) => sum + m.amount,
    );

    return totalGastos;
  }

  Future<void> setDarkMode(bool value) async {
    try {
      _isDarkMode = value;

      final box = await _getSettingsBox();
      await box.put(_themeKey, value);

      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.reportError('AppState.setDarkMode', error, stackTrace);
      rethrow;
    }
  }

  Future<void> setBackupEncryptionKey(String key) async {
    try {
      _backupEncryptionKey = key;

      final box = await _getBackupBox();
      await box.put(_backupKey, key);

      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.reportError(
        'AppState.setBackupEncryptionKey',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  void changeTab(int index) {
    if (currentTab == index) return;
    if (index >= pageNames.length) {
      index = 0;
    }

    currentTab = index;
    currentPageName = pageNames[index];
    notifyListeners();
  }

  Future<void> changeMovementsMonth(DateTime month) async {
    final changeId = ++_movementsMonthChangeId;

    selectedMovementsMonth = month;
    _isLoadingMonth = true;
    notifyListeners();

    try {
      await loadMovementsByMonthAndYear(month);
    } finally {
      if (changeId == _movementsMonthChangeId) {
        _isLoadingMonth = false;
        notifyListeners();
      }
    }
  }

  Future<void> changeBudgetMonth(DateTime month) async {
    final changeId = ++_budgetMonthChangeId;

    selectedBudgetMonth = month;
    _isLoadingBudget = true;
    notifyListeners();

    try {
      await loadPresupuestosByMonthAndYear(month);
    } finally {
      if (changeId == _budgetMonthChangeId) {
        _isLoadingBudget = false;
        notifyListeners();
      }
    }
  }

  Future<void> changeHistoryYear(int year) async {
    final changeId = ++_historyYearChangeId;

    selectedHistoryMonth = DateTime(year);
    _isLoadingHistory = true;
    notifyListeners();

    try {
      await updateHistory();
    } finally {
      if (changeId == _historyYearChangeId) {
        _isLoadingHistory = false;
        notifyListeners();
      }
    }
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

  void setFloatingActionButton(FloatingActionButton? button) {
    _floatingActionButton = button;
    notifyListeners();
  }

  void setShowFloatingActionButton(bool show) {
    _showFAB = show;
    notifyListeners();
  }

  void clearFloatingActionButton() {
    _floatingActionButton = null;
    notifyListeners();
  }

  Future<void> restoreFromBackup(String password, String pickedFile) async {
    final result = await BackupService().restoreData(password, pickedFile);
    transactionResultMessage = result.message;
    transactionSuccess = result.success;
    if (result.success) {
      await loadInitialData();
    }
    notifyListeners();
  }

  Future<void> createBackup(String password) async {
    final result = await BackupService().backupData(password);
    transactionResultMessage = result.message;
    transactionSuccess = result.success;
    notifyListeners();
  }

  // ================================= MOVIMIENTOS CRUD =================================
  Future<void> sincronizarContadoresCategorias({bool notify = true}) async {
    final counts = await _movimientosRepository.getMovementsCountByCategory();

    for (var index = 0; index < categorias.length; index++) {
      final categoria = categorias[index];
      categorias[index] = categoria.copyWith(
        movementsCount: counts[categoria.id] ?? 0,
      );
    }
    if (notify) notifyListeners();
  }

  void _ordenarMovimientos() {
    movimientos.sort((a, b) {
      final dateComparison = b.date.compareTo(a.date);
      if (dateComparison != 0) return dateComparison;

      final aMinutes = (a.time?.hour ?? 0) * 60 + (a.time?.minute ?? 0);
      final bMinutes = (b.time?.hour ?? 0) * 60 + (b.time?.minute ?? 0);
      return bMinutes.compareTo(aMinutes);
    });
  }

  Future<void> _sincronizarDatosDerivadosMovimientos() async {
    _ordenarMovimientos();
    _totalesMensuales = await _movimientosRepository.fetchTotalesMensuales(
      selectedMovementsMonth,
    );
    _variacionAhorro = await calcularVariacionAhorro(selectedMovementsMonth);
    _movimientosPorFecha = _fetchMovimientosPorFecha();
    _uniqueMovementDates = _fetchUniqueMovementDates();

    await sincronizarContadoresCategorias(notify: false);
    await updateHistory(notify: false);
    await syncDailyMovementReminder();
    await loadPresupuestosByMonthAndYear(selectedBudgetMonth, notify: false);
  }

  Future<MovimientoSearchPageResult> buscarMovimientosPaginados({
    int categoryId = -1,
    String text = '',
    DateTime? startDate,
    DateTime? endDate,
    int page = 0,
  }) => _movimientosRepository.searchMovimientos(
    categoryId: categoryId,
    text: text,
    startDate: startDate,
    endDate: endDate,
    page: page,
  );

  Future<List<DetalleMovimiento>> obtenerMovimientosPorCategoria(
    int categoryID,
  ) async {
    if (categoryID == -1) {
      return _movimientosRepository.fetchAllDetalleMovimiento();
    }

    final movimientos = _movimientosRepository.getMovementsByCategoryID(
      categoryID,
    );

    return movimientos;
  }

  Future<DetalleMovimiento?> obtenerDetalleMovimientoPorId(int id) async {
    if (id == -1) return null;

    final detalle = await _movimientosRepository.fetchDetalleMovimientoById(id);
    return detalle;
  }

  Future<int> agregarMovimiento(Movimiento movimiento) async {
    try {
      if (!RecordDateLimits.movimientos().contains(movimiento.date)) {
        transactionSuccess = false;
        transactionResultMessage =
            'La fecha debe estar entre hace 3 años y hoy.';
        return -1;
      }
      final result = await _movimientosRepository.addMovimiento(movimiento);
      transactionResultMessage = result.message;
      transactionSuccess = result.success;
      if (!result.success || result.data == null) return -1;

      final detalle = await _movimientosRepository.fetchDetalleMovimientoById(
        result.data!,
      );
      if (detalle != null &&
          isSameMonth(selectedMovementsMonth, detalle.date)) {
        movimientos.add(detalle);
      }

      await _sincronizarDatosDerivadosMovimientos();
      notifyListeners();
      return result.data!;
    } catch (error, stackTrace) {
      AppLogger.reportError('AppState.agregarMovimiento', error, stackTrace);
      rethrow;
    }
  }

  Future<int> actualizarMovimiento(Movimiento movimiento) async {
    try {
      if (!RecordDateLimits.movimientos().contains(movimiento.date)) {
        transactionSuccess = false;
        transactionResultMessage =
            'La fecha debe estar entre hace 3 años y hoy.';
        return -1;
      }
      final result = await _movimientosRepository.updateMovimiento(movimiento);

      // Actualizacion de un movimiento
      transactionResultMessage = result.message;
      transactionSuccess = result.success;
      if (!result.success || result.data == null) return -1;

      final updatedMovimiento = result.data!;
      final index = movimientos.indexWhere((m) => m.id == updatedMovimiento.id);
      final sameMonth = isSameMonth(
        selectedMovementsMonth,
        updatedMovimiento.date,
      );

      if (!sameMonth) {
        movimientos.removeWhere((m) => m.id == updatedMovimiento.id);
      } else if (index == -1) {
        movimientos.add(updatedMovimiento);
      } else {
        movimientos[index] = updatedMovimiento;
      }

      await _sincronizarDatosDerivadosMovimientos();
      notifyListeners();
      return updatedMovimiento.id ?? -1;
    } catch (error, stackTrace) {
      AppLogger.reportError('AppState.actualizarMovimiento', error, stackTrace);
      rethrow;
    }
  }

  Future<int> eliminarMovimiento(int id, int categoryId) async {
    try {
      final result = await _movimientosRepository.deleteMovimiento(id);
      transactionResultMessage = result.message;
      transactionSuccess = result.success;
      if (!result.success || result.data == -1) return -1;

      movimientos.removeWhere((m) => m.id == result.data);

      await _sincronizarDatosDerivadosMovimientos();
      notifyListeners();

      return result.data ?? -1;
    } catch (error, stackTrace) {
      AppLogger.reportError('AppState.eliminarMovimiento', error, stackTrace);
      rethrow;
    }
  }

  // ================================ CATEGORIAS CRUD =================================
  void _ordenarCategorias() {
    categorias.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
  }

  Future<DetalleCategoria?> obtenerDetalleCategoriaPorId(int id) async {
    return await _categoriasRepository.fetchDetalleCategoriaById(id);
  }

  Future<void> agregarCategoria(Categoria categoria) async {
    try {
      final result = await _categoriasRepository.addCategoria(categoria);
      transactionResultMessage = result.message;
      transactionSuccess = result.success;
      if (!result.success || result.data == null) return;

      categorias.add(categoria.copyWith(id: result.data!));
      _ordenarCategorias();
      _uniqueTipeCategoryNames = getUniqueTipeCategoryNames();
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.reportError('AppState.agregarCategoria', error, stackTrace);
      rethrow;
    }
  }

  Future<void> actualizarCategoria(Categoria categoria) async {
    try {
      final result = await _categoriasRepository.updateCategoria(categoria);
      transactionResultMessage = result.message;
      transactionSuccess = result.success;
      if (!result.success || result.data == null) return;

      final updatedCategoria = result.data!;
      final index = categorias.indexWhere((c) => c.id == updatedCategoria.id);
      if (index == -1) return;

      categorias[index] = updatedCategoria;
      _ordenarCategorias();
      _uniqueTipeCategoryNames = getUniqueTipeCategoryNames();
      movimientos = movimientos.map((movimiento) {
        if (movimiento.categoryId != updatedCategoria.id) return movimiento;
        return movimiento.copyWith(
          categoryName: updatedCategoria.name,
          categoryIcon: updatedCategoria.iconData,
          categoryColor: updatedCategoria.iconColor,
          movementType: updatedCategoria.movementType,
        );
      }).toList();
      recordatorios = recordatorios.map((recordatorio) {
        if (recordatorio.categoryId != updatedCategoria.id) {
          return recordatorio;
        }
        return recordatorio.copyWith(
          categoryName: updatedCategoria.name,
          categoryIcon: updatedCategoria.iconData,
          categoryColor: updatedCategoria.iconColor,
        );
      }).toList();
      _movimientosPorFecha = _fetchMovimientosPorFecha();
      await loadPresupuestosByMonthAndYear(selectedBudgetMonth, notify: false);
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.reportError('AppState.actualizarCategoria', error, stackTrace);
      rethrow;
    }
  }

  Future<void> eliminarCategoria(int id) async {
    try {
      final result = await _categoriasRepository.deleteCategoria(id);
      transactionResultMessage = result.message;
      transactionSuccess = result.success;
      if (!result.success || result.data == null) return;

      categorias.removeWhere((categoria) => categoria.id == result.data);
      _uniqueTipeCategoryNames = getUniqueTipeCategoryNames();
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.reportError('AppState.eliminarCategoria', error, stackTrace);
      rethrow;
    }
  }

  // ================================ PRESUPUESTOS CRUD =================================
  Future<OperationResult<int>> transferirMovimiento(
    int id,
    DateTime date, {
    required bool move,
  }) async {
    try {
      if (!RecordDateLimits.movimientos().contains(date)) {
        return const OperationResult(
          success: false,
          message: 'La fecha debe estar entre hace 3 años y hoy.',
        );
      }
      final source = await _movimientosRepository.fetchMovimientoById(id);
      if (source == null) {
        return const OperationResult(
          success: false,
          message: 'El movimiento ya no existe.',
        );
      }
      if (move && isSameDay(source.date, date)) {
        return const OperationResult(
          success: false,
          message: 'Selecciona una fecha diferente a la de origen.',
        );
      }
      final updated = Movimiento(
        id: move ? source.id : null,
        title: source.title,
        categoryID: source.categoryID,
        amount: source.amount,
        date: DateTime(date.year, date.month, date.day),
        time: source.time,
        note: source.note,
      );
      final savedId = move
          ? await actualizarMovimiento(updated)
          : await agregarMovimiento(updated);
      return OperationResult(
        success: savedId != -1,
        data: savedId,
        message: savedId == -1
            ? transactionResultMessage
            : 'Movimiento ${move ? 'movido' : 'copiado'} al ${date.day}/${date.month}/${date.year}.',
      );
    } catch (error, stackTrace) {
      AppLogger.reportError('AppState.transferirMovimiento', error, stackTrace);
      rethrow;
    }
  }

  Future<Presupuesto?> presupuestoEnDestino(int categoryId, DateTime date) =>
      _presupuestosRepository.fetchPresupuestoByCategoryAndMonth(
        categoryId,
        date,
      );

  Future<double> ingresoPresupuestadoTotalEnDestino(DateTime date) async {
    final result = await _presupuestosRepository
        .fetchIngresosPresupuestadosByMonthAndYear(date);
    return result.monto;
  }

  Future<double> ingresoPresupuestadoAsignadoEnDestino(DateTime date) =>
      _presupuestosRepository.fetchPresupuestosAmountSumByMonthAndYear(date);

  Future<OperationResult<int>> transferirPresupuesto(
    int id,
    DateTime date, {
    required bool move,
    Presupuesto? replacement,
  }) async {
    try {
      final month = DateTime(date.year, date.month);
      if (!RecordDateLimits.presupuestos().contains(month)) {
        return const OperationResult(
          success: false,
          message:
              'El mes debe estar entre un año antes y un año después del mes actual.',
        );
      }
      final result = await _presupuestosRepository.transferPresupuesto(
        id,
        month,
        move: move,
        replacement: replacement,
      );
      transactionSuccess = result.success;
      transactionResultMessage = result.message;
      if (result.success) {
        await loadPresupuestosByMonthAndYear(selectedBudgetMonth);
      }
      return OperationResult(
        success: result.success,
        data: result.data,
        message: result.success
            ? 'Presupuesto ${move ? 'movido' : 'copiado'} a ${formatMonthYear(month)}.'
            : result.message,
      );
    } catch (error, stackTrace) {
      AppLogger.reportError(
        'AppState.transferirPresupuesto',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<int> agregarPresupuesto(Presupuesto presupuesto) async {
    try {
      final result = await _presupuestosRepository.addPresupuesto(presupuesto);
      transactionResultMessage = result.message;
      transactionSuccess = result.success;
      if (!result.success || result.data == null) return -1;

      final saved = result.data!;
      await loadPresupuestosByMonthAndYear(selectedBudgetMonth, notify: false);
      notifyListeners();
      return saved.budgetId!;
    } catch (error, stackTrace) {
      AppLogger.reportError('AppState.agregarPresupuesto', error, stackTrace);
      rethrow;
    }
  }

  Future<int?> actualizarPresupuesto(Presupuesto presupuesto) async {
    try {
      final result = await _presupuestosRepository.updatePresupuesto(
        presupuesto,
      );
      transactionResultMessage = result.message;
      transactionSuccess = result.success;
      if (!result.success || result.data == null) return null;

      final updatedPresupuesto = result.data!;
      await loadPresupuestosByMonthAndYear(selectedBudgetMonth, notify: false);
      notifyListeners();
      return updatedPresupuesto.budgetId;
    } catch (error, stackTrace) {
      AppLogger.reportError(
        'AppState.actualizarPresupuesto',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<void> eliminarPresupuesto(int id) async {
    try {
      final result = await _presupuestosRepository.deletePresupuesto(id);
      transactionResultMessage = result.message;
      transactionSuccess = result.success;
      if (!result.success || result.data == null) return;

      await loadPresupuestosByMonthAndYear(selectedBudgetMonth, notify: false);
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.reportError('AppState.eliminarPresupuesto', error, stackTrace);
      rethrow;
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
    try {
      final result = await _notificacionRepository.addBudgetNotificationEvent(
        event,
      );
      return result.success;
    } catch (error, stackTrace) {
      AppLogger.reportError(
        'AppState.insertarBudgetNotificationEvent',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<bool> insertarNotificacion(
    Notificacion notificacion, {
    bool showNotification = false,
  }) async {
    try {
      final result = await _notificacionRepository.addNotificacion(
        notificacion,
      );
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
    } catch (error, stackTrace) {
      AppLogger.reportError('AppState.insertarNotificacion', error, stackTrace);
      rethrow;
    }
  }

  Future<bool> eliminarNotificacion(int id) async {
    try {
      final success = await _notificacionRepository.deleteNotificacion(id);
      if (success) {
        notificaciones.removeWhere((n) => n.id == id);
        await updateCountersNotif();
      }

      return success;
    } catch (error, stackTrace) {
      AppLogger.reportError('AppState.eliminarNotificacion', error, stackTrace);
      rethrow;
    }
  }

  Future<bool> eliminarTodasNotificaciones() async {
    try {
      final result = await _notificacionRepository.deleteAllNotificaciones();
      if (result.success) {
        notificaciones.clear();
        await updateCountersNotif();
      }

      return result.success;
    } catch (error, stackTrace) {
      AppLogger.reportError(
        'AppState.eliminarTodasNotificaciones',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<bool> marcarNotifLeida(int id) async {
    try {
      final result = await _notificacionRepository.markAsRead(id);
      if (!result.success) return false;

      final index = notificaciones.indexWhere((n) => n.id! == id);
      if (index != -1) {
        notificaciones[index] = notificaciones[index].copyWith(isRead: true);
      }

      await updateCountersNotif();
      await NotificationService.cancelNotification(id);
      return true;
    } catch (error, stackTrace) {
      AppLogger.reportError('AppState.marcarNotifLeida', error, stackTrace);
      rethrow;
    }
  }

  // ================================ RECORDATORIOS CRUD =================================
  Future<DetalleRecordatorio?> getRecordatorioById(int id) async {
    final result = await _recordatoriosRepository.fetchDetalleRecordatorioById(
      id,
    );

    if (result == null) return result;
    final now = currentDateTime;
    if (result.scheduledAt.isAfter(now)) return result;
    final recurrence = Recurrencia.values.firstWhere(
      (value) => value.name == result.recurrency,
      orElse: () => Recurrencia.ninguno,
    );
    final next = resolveReminderDate(result.scheduledAt, recurrence, now);
    if (next == null) return result;
    return result.copyWith(scheduledAt: next);
  }

  Future<int> agregarRecordatorio(Recordatorio recordatorio) async {
    try {
      final result = await _recordatoriosRepository.insertRecordatorio(
        recordatorio,
      );
      transactionResultMessage = result.message;
      transactionSuccess = result.success;
      if (!result.success || result.data == null) return -1;

      final savedId = result.data!;
      final detalle = await _recordatoriosRepository
          .fetchDetailedRecordatorioById(savedId);
      if (detalle != null) {
        recordatorios.add(detalle);
      }
      await syncRecordatorioNotifications();
      notifyListeners();
      return savedId;
    } catch (error, stackTrace) {
      AppLogger.reportError('AppState.agregarRecordatorio', error, stackTrace);
      rethrow;
    }
  }

  Future<void> actualizarRecordatorio(Recordatorio recordatorio) async {
    try {
      final result = await _recordatoriosRepository.updateRecordatorio(
        recordatorio,
      );

      transactionResultMessage = result.message;
      transactionSuccess = result.success;
      if (!result.success || result.data == null) return;

      final updatedRecordatorio = result.data!;
      final index = recordatorios.indexWhere(
        (r) => r.id == updatedRecordatorio.id,
      );

      if (index == -1) {
        return;
      }

      recordatorios[index] = updatedRecordatorio;
      await syncRecordatorioNotifications();
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.reportError(
        'AppState.actualizarRecordatorio',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<void> actualizarEstadoRecordatorio(int id, bool enabled) async {
    try {
      final result = await _recordatoriosRepository.updateRecordatorioEnabled(
        id,
        enabled,
      );
      transactionResultMessage = result.message;
      transactionSuccess = result.success;
      if (!result.success) return;

      final updated = await _recordatoriosRepository
          .fetchDetailedRecordatorioById(id);
      final index = recordatorios.indexWhere((r) => r.id == id);
      if (updated != null && index != -1) {
        recordatorios[index] = updated;
      }

      await syncRecordatorioNotifications();
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.reportError(
        'AppState.actualizarEstadoRecordatorio',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<void> eliminarRecordatorio(int id) async {
    try {
      final result = await _recordatoriosRepository.deleteRecordatorio(id);
      transactionResultMessage = result.message;
      transactionSuccess = result.success;
      if (!result.success || result.data == null) return;

      await NotificationService.cancelNotification(
        NotificationService.getRecordatorioNotificationId(id),
      );
      recordatorios.removeWhere(
        (recordatorio) => recordatorio.id == result.data,
      );
      await syncRecordatorioNotifications();
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.reportError('AppState.eliminarRecordatorio', error, stackTrace);
      rethrow;
    }
  }
}
