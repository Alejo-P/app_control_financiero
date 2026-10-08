import 'package:control_financiero/app/app_scaffold.dart';
import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/core/tutorials/tutorial_host.dart';
import 'package:control_financiero/core/tutorials/tutorial_progress.dart';
import 'package:control_financiero/core/tutorials/tutorial_step.dart';
import 'package:control_financiero/features/presupuestos/models/ingreso_presupuestado.dart';
import 'package:control_financiero/features/presupuestos/models/category_card_info.dart';
import 'package:control_financiero/features/movimientos/models/detalle_movimiento.dart';
import 'package:control_financiero/features/historial/models/month_data.dart';
import 'package:control_financiero/features/shared/widgets/record_actions_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../support/app_state_fakes.dart';

class TutorialState extends TestAppState {
  TutorialState() {
    loadingInitialData = false;
  }
  bool monthLoading = false;
  IngresoPresupuestado? income;
  @override
  bool get isLoadingMonth => monthLoading;
  @override
  IngresoPresupuestado? get ingresoPresupuestado => income;
  @override
  List<DateTime> get uniqueMovementDates =>
      movimientos.map((m) => m.date).toSet().toList();
  @override
  Map<DateTime, List<DetalleMovimiento>> get movimientosPorFecha => {
    for (final date in uniqueMovementDates)
      date: movimientos.where((m) => m.date == date).toList(),
  };
  @override
  List<DetalleMovimiento> getMovimientosByDateAndFilter(
    DateTime fecha, {
    MovimientoFiltro filtro = MovimientoFiltro.todos,
  }) => (movimientosPorFecha[fecha] ?? [])
      .where(
        (m) =>
            filtro == MovimientoFiltro.todos ||
            (filtro == MovimientoFiltro.ingresos
                ? m.movementType == TipoMovimiento.ingreso
                : m.movementType == TipoMovimiento.gasto),
      )
      .toList();
}

class MemorySettings extends Fake implements Box<dynamic> {
  final _stored = <dynamic, dynamic>{};
  @override
  dynamic get(dynamic key, {dynamic defaultValue}) =>
      _stored[key] ?? defaultValue;
  @override
  Future<void> put(dynamic key, dynamic value) async {
    _stored[key] = value;
  }

  @override
  Future<void> delete(dynamic key) async {
    _stored.remove(key);
  }
}

void main() {
  late MemorySettings box;
  late TutorialState state;
  late GlobalKey<NavigatorState> navigator;

  setUp(() {
    box = MemorySettings();
    state = TutorialState();
    navigator = GlobalKey<NavigatorState>();
  });

  Widget app(Widget child, {double textScale = 1, bool dark = false}) =>
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
          theme: dark ? ThemeData.dark() : ThemeData.light(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          locale: const Locale('es', 'EC'),
          supportedLocales: const [Locale('es', 'EC')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          navigatorKey: navigator,
          navigatorObservers: [tutorialRouteObserver],
          home: TutorialHost(progress: TutorialProgress(box), child: child),
        ),
      );

  Widget targets(List<TutorialStep> steps) => Scaffold(
    body: Column(
      children: [
        for (final step in steps)
          TutorialTarget(
            key: ValueKey(step),
            step: step,
            child: SizedBox(width: 120, height: 45, child: Text(step.name)),
          ),
      ],
    ),
  );

  List<TutorialStep> group(String name) =>
      TutorialStep.values.where((step) => step.group == name).toList();

  Future<void> ready(WidgetTester tester) async {
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
  }

  testWidgets('inicio espera carga y solo empieza con todos sus controles', (
    tester,
  ) async {
    state.monthLoading = true;
    await tester.pumpWidget(app(targets(group('movimientos_inicio'))));
    await ready(tester);
    expect(ShowcaseView.getNamed('tutoriales').isShowcaseRunning, isFalse);
    state.monthLoading = false;
    state.notifyListeners();
    await ready(tester);
    expect(find.text('Notificaciones'), findsOneWidget);
    expect(ShowcaseView.getNamed('tutoriales').isShowcaseRunning, isTrue);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('objetivo ausente no consume recorrido', (tester) async {
    await tester.pumpWidget(app(targets([TutorialStep.notifications])));
    await ready(tester);
    expect(ShowcaseView.getNamed('tutoriales').isShowcaseRunning, isFalse);
    expect(TutorialProgress(box).isPending('movimientos_inicio'), isTrue);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'cerrar a mitad conserva pendiente; reapertura vuelve a iniciar',
    (tester) async {
      await tester.pumpWidget(app(targets(group('movimientos_inicio'))));
      await ready(tester);
      await tester.pumpWidget(const SizedBox());
      expect(TutorialProgress(box).isPending('movimientos_inicio'), isTrue);
      await tester.pumpWidget(app(targets(group('movimientos_inicio'))));
      await ready(tester);
      expect(find.text('Notificaciones'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('omitir no reaparece y no consume datos futuros', (tester) async {
    await tester.pumpWidget(app(targets(group('movimientos_inicio'))));
    await ready(tester);
    await tester.tap(find.text('Omitir'));
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    expect(TutorialProgress(box).states['movimientos_inicio'], 'omitido');
    expect(TutorialProgress(box).isPending('movimientos_datos'), isTrue);
    await tester.pumpWidget(app(targets(group('movimientos_inicio'))));
    await ready(tester);
    expect(ShowcaseView.getNamed('tutoriales').isShowcaseRunning, isFalse);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('finalizar se guarda solo después del último paso', (
    tester,
  ) async {
    state.currentTab = 2;
    await tester.pumpWidget(app(targets(group('historial_inicio'))));
    await ready(tester);
    expect(TutorialProgress(box).isPending('historial_inicio'), isTrue);
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    expect(TutorialProgress(box).states['historial_inicio'], 'completado');
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('ruta externa pospone tutorial y regreso lo reanuda', (
    tester,
  ) async {
    await tester.pumpWidget(app(targets(group('movimientos_inicio'))));
    navigator.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Otra pantalla')),
      ),
    );
    await ready(tester);
    expect(ShowcaseView.getNamed('tutoriales').isShowcaseRunning, isFalse);
    navigator.currentState!.pop();
    await tester.pump(const Duration(milliseconds: 400));
    await ready(tester);
    expect(find.text('Notificaciones'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('al aparecer datos inicia el recorrido pendiente', (
    tester,
  ) async {
    final steps = ValueNotifier<List<TutorialStep>>([]);
    await tester.pumpWidget(
      app(
        ValueListenableBuilder<List<TutorialStep>>(
          valueListenable: steps,
          builder: (_, value, _) => targets(value),
        ),
      ),
    );
    await ready(tester);
    expect(ShowcaseView.getNamed('tutoriales').isShowcaseRunning, isFalse);
    steps.value = group('movimientos_datos');
    await tester.pump();
    await ready(tester);
    expect(find.text('Balance mensual'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    steps.dispose();
  });

  testWidgets('menú explica copiar y mover sin ejecutar operaciones', (
    tester,
  ) async {
    await box.put(TutorialProgress.storageKey, {
      'movimientos_inicio': 'completado',
      'movimientos_datos': 'completado',
    });
    await tester.pumpWidget(
      app(
        Scaffold(
          body: RecordActionsMenu(
            id: 1,
            date: DateTime(2026, 10, 8),
            tutorialStep: TutorialStep.movementMenu,
          ),
        ),
      ),
    );
    await tester.tap(find.byType(PopupMenuButton<RecordAction>));
    await ready(tester);
    expect(find.text('Copiar movimiento'), findsOneWidget);
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    expect(find.text('Mover movimiento'), findsOneWidget);
    expect(find.byType(CalendarDatePicker), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  for (final amount in [null, 0.0, 100.0]) {
    testWidgets('presupuestos: ingreso $amount controla objetivo de agregar', (
      tester,
    ) async {
      state.currentTab = 1;
      if (amount != null) {
        state.income = IngresoPresupuestado(
          monto: amount,
          fecha: DateTime(2026, 10),
        );
      }
      await box.put(TutorialProgress.storageKey, {
        'presupuestos_inicio': 'completado',
      });
      await tester.pumpWidget(app(const AppScaffold()));
      await ready(tester);
      final add = find.byWidgetPredicate(
        (widget) =>
            widget is TutorialTarget && widget.step == TutorialStep.addBudget,
      );
      expect(add, amount != null && amount > 0 ? findsOneWidget : findsNothing);
      expect(
        ShowcaseView.getNamed('tutoriales').isShowcaseRunning,
        amount != null && amount > 0,
      );
      expect(TutorialProgress(box).isPending('presupuestos_agregar'), isTrue);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets(
    'Movimientos real inicia vacío y explica menú al crear un registro',
    (tester) async {
      await tester.pumpWidget(app(const AppScaffold()));
      await ready(tester);
      expect(find.text(TutorialStep.notifications.description), findsOneWidget);
      await tester.tap(find.text('Omitir'));
      await tester.pumpAndSettle();
      state.movimientos.add(
        DetalleMovimiento(
          id: 1,
          title: 'Compra',
          amount: 10,
          movementType: TipoMovimiento.gasto,
          date: DateTime(2026, 10, 8),
          categoryName: 'Comida',
          categoryId: 1,
          categoryIcon: Icons.restaurant,
          categoryColor: Colors.orange,
          time: const TimeOfDay(hour: 12, minute: 0),
        ),
      );
      state.notifyListeners();
      await ready(tester);
      expect(
        find.text(TutorialStep.movementSummary.description),
        findsOneWidget,
      );
      for (final step in [
        TutorialStep.movementFilters,
        TutorialStep.movementMenu,
      ]) {
        await tester.tap(find.text('Siguiente'));
        await tester.pumpAndSettle();
        expect(find.text(step.description), findsOneWidget);
      }
      await tester.tap(find.text('Abrir menú'));
      await ready(tester);
      expect(find.text(TutorialStep.movementCopy.description), findsOneWidget);
      expect(TutorialProgress(box).states['movimientos_datos'], 'completado');
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
      expect(find.text(TutorialStep.movementMove.description), findsOneWidget);
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
      expect(TutorialProgress(box).states['movimientos_menu'], 'completado');
      expect(find.byType(CalendarDatePicker), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('Historial real pospone tarjetas hasta tener datos', (
    tester,
  ) async {
    state.currentTab = 2;
    await tester.pumpWidget(app(const AppScaffold()));
    await ready(tester);
    expect(find.text(TutorialStep.historyYear.description), findsOneWidget);
    await tester.tap(find.text('Omitir'));
    await tester.pumpAndSettle();
    state.historialAnual = [
      MonthData(month: state.selectedMovementsMonth, spent: 10, income: 100),
    ];
    state.notifyListeners();
    await ready(tester);
    expect(find.text(TutorialStep.historyMonth.description), findsOneWidget);
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    await ready(tester);
    expect(find.text(TutorialStep.historyBalance.description), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Más acciones real recorre ocho opciones y permite repetir', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    state.currentTab = 3;
    await tester.pumpWidget(
      app(const AppScaffold(), textScale: 1.3, dark: true),
    );
    await ready(tester);
    for (final step in group('mas_acciones')) {
      expect(find.text(step.description), findsOneWidget);
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
    }
    expect(TutorialProgress(box).states['mas_acciones'], 'completado');
    expect(state.isDarkMode, isFalse);
    await tester.ensureVisible(find.text('Ver tutoriales'));
    await tester.tap(find.text('Ver tutoriales'));
    await ready(tester);
    expect(state.currentTab, 0);
    expect(TutorialProgress(box).states, isEmpty);
    expect(find.text(TutorialStep.notifications.description), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'Presupuestos real: nuevo ingreso habilita guía; cards explican sus acciones',
    (tester) async {
      state.currentTab = 1;
      await tester.pumpWidget(app(const AppScaffold()));
      await ready(tester);
      expect(find.text(TutorialStep.budgetMonth.description), findsOneWidget);
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
      expect(find.text(TutorialStep.budgetIncome.description), findsOneWidget);
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
      state.income = IngresoPresupuestado(
        monto: 100,
        fecha: state.selectedBudgetMonth,
      );
      state.notifyListeners();
      await ready(tester);
      expect(find.text(TutorialStep.addBudget.description), findsOneWidget);
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
      state.presupuestos.add(
        CategoryCardInfo(
          icon: Icons.restaurant,
          color: Colors.orange,
          title: 'Comida',
          spent: 10,
          total: 50,
          date: state.selectedBudgetMonth,
          percentage: 0.2,
          categoryId: 1,
          budgetId: 1,
        ),
      );
      state.notifyListeners();
      await ready(tester);
      expect(find.text(TutorialStep.budgetSummary.description), findsOneWidget);
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
      await ready(tester);
      expect(find.text(TutorialStep.budgetCard.description), findsOneWidget);
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
      expect(find.text(TutorialStep.budgetMenu.description), findsOneWidget);
      await tester.tap(find.text('Abrir menú'));
      await ready(tester);
      expect(find.text(TutorialStep.budgetCopy.description), findsOneWidget);
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
      expect(find.text(TutorialStep.budgetMove.description), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('salir al fondo conserva pendiente y reanuda al volver', (
    tester,
  ) async {
    await tester.pumpWidget(app(targets(group('movimientos_inicio'))));
    await ready(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(ShowcaseView.getNamed('tutoriales').isShowcaseRunning, isFalse);
    expect(TutorialProgress(box).isPending('movimientos_inicio'), isTrue);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await ready(tester);
    expect(find.text(TutorialStep.notifications.description), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
