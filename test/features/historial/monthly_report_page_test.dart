import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/app/app_routes.dart';
import 'package:control_financiero/features/historial/models/monthly_report_page_args.dart';
import 'package:control_financiero/core/theme/app_theme.dart';
import 'package:control_financiero/features/historial/models/month_data.dart';
import 'package:control_financiero/features/historial/models/monthly_report.dart';
import 'package:control_financiero/features/historial/presentation/historial_page.dart';
import 'package:control_financiero/features/historial/presentation/monthly_report_page.dart';
import 'package:control_financiero/features/historial/widgets/report_charts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../../support/app_state_fakes.dart';
import 'monthly_report_test.dart' show category, report;

class ReportState extends TestAppState {
  final requested = <DateTime>[];
  MonthlyReport value = report(
    categories: [
      category(1, name: 'Alimentación', spent: 210, budget: 250),
      category(2, name: 'Servicios', spent: 125, budget: 140),
      category(3, name: 'Transporte', spent: 95, budget: 200),
      category(4, name: 'Compras', spent: 90, budget: 90),
      category(5, name: 'Salud', spent: 65, budget: 50),
      category(6, name: 'Otros gastos', spent: 95),
      category(7, name: 'Sin gastos', budget: 100),
    ],
  );
  Completer<MonthlyReport>? pending;
  bool fail = false;
  @override
  Future<MonthlyReport> fetchMonthlyReport(DateTime month) {
    requested.add(month);
    if (pending != null) return pending!.future;
    if (fail) return Future.error(StateError('Prueba de error de lectura'));
    return Future.value(
      MonthlyReport(
        month: month,
        income: value.income,
        spent: value.spent,
        previousSpent: value.previousSpent,
        categories: value.categories,
      ),
    );
  }
}

Widget app(
  ReportState state,
  Widget home, {
  bool dark = false,
  double scale = 1,
}) => ChangeNotifierProvider<AppState>.value(
  value: state,
  child: MaterialApp(
    theme: _theme(dark),
    locale: const Locale('es', 'EC'),
    supportedLocales: const [Locale('es', 'EC')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    routes: {AppRoutes.reporteMensualRoute: (_) => const MonthlyReportPage()},
    home: home,
  ),
);

Widget reportPage({required DateTime month}) => Navigator(
  key: ValueKey(month),
  onGenerateRoute: (_) => MaterialPageRoute<void>(
    settings: RouteSettings(arguments: MonthlyReportPageArgs(month: month)),
    builder: (_) => const MonthlyReportPage(),
  ),
);
ThemeData _theme(bool dark) {
  final theme = dark ? AppTheme.dark : AppTheme.light;
  if (const String.fromEnvironment('REPORT_PREVIEW_FONT').isEmpty) return theme;
  return theme.copyWith(
    textTheme: theme.textTheme.apply(fontFamily: 'ReportPreview'),
    appBarTheme: theme.appBarTheme.copyWith(
      titleTextStyle: theme.appBarTheme.titleTextStyle?.copyWith(
        fontFamily: 'ReportPreview',
      ),
    ),
  );
}

void main() {
  setUpAll(() async {
    const path = String.fromEnvironment('REPORT_PREVIEW_FONT');
    if (path.isEmpty) return;
    final loader = FontLoader('ReportPreview')
      ..addFont(
        File(path).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
      );
    await loader.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });
  testWidgets(
    'Historial abre también el mes seleccionado y vuelve sin cambiar períodos',
    (tester) async {
      final state = ReportState()..loadingInitialData = false;
      final month = state.selectedMovementsMonth;
      final budgetMonth = state.selectedBudgetMonth;
      final historyMonth = state.selectedHistoryMonth;
      state.historialAnual = [MonthData(month: month, spent: 680, income: 850)];
      await tester.pumpWidget(
        app(state, const Scaffold(body: HistorialPage())),
      );
      await tester.pumpAndSettle();
      expect(find.text('Ver informe'), findsOneWidget);
      await tester.tap(find.text('Ver informe'));
      await tester.pumpAndSettle();
      expect(find.text('Informe mensual'), findsOneWidget);
      expect(find.text('Mes en curso'), findsOneWidget);
      expect(state.requested.single, month);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Ver informe'), findsOneWidget);
      expect(state.selectedMovementsMonth, month);
      expect(state.selectedBudgetMonth, budgetMonth);
      expect(state.selectedHistoryMonth, historyMonth);
      expect(tester.takeException(), isNull);
    },
  );

  for (final dark in [false, true]) {
    testWidgets('sin desbordamientos a 320 px y texto 2x, tema $dark', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final state = ReportState();
      await tester.pumpWidget(
        app(state, reportPage(month: DateTime(2026, 1)), dark: dark, scale: 2),
      );
      await tester.pumpAndSettle();
      final outer = find.byType(ListView).first;
      for (var i = 0; i < 18; i++) {
        await tester.drag(outer, const Offset(0, -300));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  }

  testWidgets(
    'lista completa, selección de categoría y caja de presupuestos fija',
    (tester) async {
      tester.view.physicalSize = const Size(430, 2800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final state = ReportState();
      final previewKey = GlobalKey();
      await tester.pumpWidget(
        app(
          state,
          RepaintBoundary(
            key: previewKey,
            child: reportPage(month: DateTime(2026, 10)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Ver todas las categorías'), findsNothing);
      expect(find.text('Tasa de cobertura'), findsNothing);
      expect(find.text('Margen libre'), findsNothing);
      expect(find.byType(ReportDonut), findsOneWidget);
      await tester.tap(find.text('Otros gastos').first);
      await tester.pumpAndSettle();
      expect(
        find.byType(ReportDonut).evaluate().single.widget,
        isA<ReportDonut>().having(
          (chart) => chart.selectedId,
          'categoría seleccionada',
          6,
        ),
      );
      final budgetList = find.byKey(const Key('report-budget-list'));
      expect(tester.getSize(budgetList).height, 320);
      await tester.drag(budgetList, const Offset(0, -1500));
      await tester.pumpAndSettle();
      expect(find.text('Sin presupuesto'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tapAt(
        tester.getCenter(find.byType(ReportDonut)) + const Offset(90, 0),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<ReportDonut>(find.byType(ReportDonut)).selectedId,
        1,
      );
      await tester.tap(
        find
            .ancestor(
              of: find.text('Alimentación'),
              matching: find.byType(InkWell),
            )
            .first,
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<ReportDonut>(find.byType(ReportDonut)).selectedId,
        isNull,
      );
      if (const bool.fromEnvironment('REPORT_PREVIEW')) {
        await tester.drag(budgetList, const Offset(0, 2000));
        await tester.pumpAndSettle();
        final boundary =
            previewKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            'build/monthly_report_preview.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
    },
  );

  testWidgets(
    'mes vacío muestra No aplica y variación cero sin gráfica ficticia',
    (tester) async {
      final state = ReportState()
        ..value = report(income: 0, spent: 0, previous: 0);
      await tester.pumpWidget(app(state, reportPage(month: DateTime(2026, 1))));
      await tester.pumpAndSettle();
      expect(find.text('No aplica'), findsOneWidget);
      await tester.drag(find.byType(ListView).first, const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(find.text('Sin gastos registrados'), findsOneWidget);
      expect(find.byType(ReportDonut), findsNothing);
      expect(find.text('Sin base porcentual'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'presupuesto cero sin porcentaje y excedido con porcentaje real',
    (tester) async {
      tester.view.physicalSize = const Size(430, 2800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final state = ReportState()
        ..value = report(
          income: 0,
          spent: 150,
          previous: 0,
          categories: [
            category(1, name: 'A', budget: 100, spent: 125),
            category(2, name: 'B', budget: 0),
            category(3, name: 'C', budget: 0, spent: 25),
          ],
        );
      await tester.pumpWidget(app(state, reportPage(month: DateTime(2026, 1))));
      await tester.pumpAndSettle();
      expect(find.text('No aplica'), findsOneWidget);
      expect(find.text('Sin base porcentual'), findsOneWidget);
      expect(find.text('125 %'), findsOneWidget);
      expect(find.text('Límite alcanzado'), findsOneWidget);
      final bars = tester
          .widgetList<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          )
          .toList();
      expect(bars.length, 1);
      expect(bars.single.value, 1);
      final budgetList = find.byKey(const Key('report-budget-list'));
      await tester.drag(budgetList, const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(find.text('Excedido por \$25,00'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('respuesta de una ruta cerrada no reemplaza el informe nuevo', (
    tester,
  ) async {
    final state = ReportState()..pending = Completer<MonthlyReport>();
    final previous = state.pending!;
    await tester.pumpWidget(app(state, reportPage(month: DateTime(2026, 1))));
    state.pending = null;
    await tester.pumpWidget(app(state, reportPage(month: DateTime(2026, 2))));
    await tester.pumpAndSettle();
    previous.complete(
      MonthlyReport(
        month: DateTime(2026, 1),
        income: 99999,
        spent: 0,
        previousSpent: 0,
        categories: [],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Febrero 2026'), findsOneWidget);
    expect(find.textContaining('99.999'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('error de lectura permite reintentar', (tester) async {
    final state = ReportState()..fail = true;
    await tester.pumpWidget(app(state, reportPage(month: DateTime(2026, 1))));
    await tester.pumpAndSettle();
    expect(find.text('No se pudo cargar el informe mensual.'), findsOneWidget);
    state.fail = false;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('RESUMEN DEL PERÍODO'), findsOneWidget);
    expect(state.requested.length, 2);
  });
}
