import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:control_financiero/app/app_routes.dart';
import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/features/historial/models/category_report_page_args.dart';
import 'package:control_financiero/features/historial/presentation/category_report_page.dart';
import 'package:control_financiero/features/historial/widgets/report_charts.dart';
import 'package:control_financiero/features/movimientos/models/detalle_movimiento.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'monthly_report_page_test.dart' as base;
import 'monthly_report_test.dart' show category;

class DetailState extends base.ReportState {
  final calls = <({DateTime month, int category, int offset, bool oldest})>[];
  Completer<List<DetalleMovimiento>>? pendingMovements;
  bool failMovements = false;
  @override
  Future<List<DetalleMovimiento>> fetchCategoryReportMovements(
    DateTime month,
    int categoryId, {
    int offset = 0,
    bool oldestFirst = false,
  }) async {
    calls.add((
      month: month,
      category: categoryId,
      offset: offset,
      oldest: oldestFirst,
    ));
    if (pendingMovements != null) return pendingMovements!.future;
    if (failMovements) throw StateError('read error');
    return List.generate(
      offset == 0 ? 10 : 4,
      (index) => DetalleMovimiento(
        id: offset + index,
        title: '${oldestFirst ? 'Antiguo' : 'Reciente'} ${offset + index}',
        amount: 15,
        movementType: TipoMovimiento.gasto,
        date: DateTime(2026, 10, 1),
        categoryIcon: Icons.restaurant,
        categoryColor: Colors.orange,
        time: const TimeOfDay(hour: 18, minute: 30),
      ),
    );
  }
}

Widget detail(DetailState state, {double scale = 1, bool dark = false}) =>
    base.app(
      state,
      Navigator(
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          settings: RouteSettings(
            name: AppRoutes.reporteCategoriaRoute,
            arguments: CategoryReportPageArgs(
              month: DateTime(2026, 10),
              category: category(
                1,
                name: 'Alimentación',
                spent: 210,
                count: 14,
                budget: 250,
              ),
              totalSpent: 680,
              color: Colors.orange,
            ),
          ),
          builder: (_) => const CategoryReportPage(),
        ),
      ),
      scale: scale,
      dark: dark,
    );

void main() {
  if (const bool.fromEnvironment('CATEGORY_REPORT_PREVIEW')) {
    testWidgets('vista previa del detalle', (tester) async {
      await tester.runAsync(() async {
        final loader = FontLoader('ReportPreview')
          ..addFont(
            File(
              const String.fromEnvironment('REPORT_PREVIEW_FONT'),
            ).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
          );
        await loader.load();
        final icons = FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
        await icons.load();
      });
      tester.view.physicalSize = const Size(430, 1700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(key: key, child: detail(DetailState())),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(
          'build/category_report_preview.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    });
  }

  testWidgets(
    'selección desde dona y fila expande una sola categoría y conserva contexto al volver',
    (tester) async {
      tester.view.physicalSize = const Size(430, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final state = DetailState();
      await tester.pumpWidget(
        base.app(state, base.reportPage(month: DateTime(2026, 10))),
      );
      await tester.pumpAndSettle();
      expect(find.text('Ver más detalles'), findsNothing);
      await tester.tapAt(
        tester.getCenter(find.byType(ReportDonut)) + const Offset(90, 0),
      );
      await tester.pumpAndSettle();
      expect(find.text('Ver más detalles'), findsOneWidget);
      expect(
        tester.widget<ReportDonut>(find.byType(ReportDonut)).selectedId,
        1,
      );
      await tester.tap(find.text('Ver más detalles'));
      await tester.pumpAndSettle();
      expect(find.text('Detalle de categoría'), findsOneWidget);
      expect(state.calls.last.month, DateTime(2026, 10));
      expect(state.calls.last.category, 1);
      await tester.tap(find.byType(BackButton).last);
      await tester.pumpAndSettle();
      expect(find.text('Ver más detalles'), findsOneWidget);
      expect(
        tester.widget<ReportDonut>(find.byType(ReportDonut)).selectedId,
        1,
      );
      await tester.tapAt(
        tester.getTopLeft(find.byKey(const ValueKey('report-category-2'))) +
            const Offset(20, 20),
      );
      await tester.pumpAndSettle();
      expect(find.text('Ver más detalles'), findsOneWidget);
      expect(
        tester.widget<ReportDonut>(find.byType(ReportDonut)).selectedId,
        2,
      );
      await tester.tapAt(
        tester.getTopLeft(find.byKey(const ValueKey('report-category-2'))) +
            const Offset(20, 20),
      );
      await tester.pumpAndSettle();
      expect(find.text('Ver más detalles'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('pagina sin cambiar indicadores y cambia orden desde el inicio', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final state = DetailState();
    await tester.pumpWidget(detail(state));
    await tester.pumpAndSettle();
    expect(find.text('Mostrando 10 de 14 movimientos'), findsOneWidget);
    expect(state.calls.single.month, DateTime(2026, 10));
    expect(state.calls.single.category, 1);
    await tester.ensureVisible(find.text('Cargar más'));
    state.failMovements = true;
    await tester.tap(find.text('Cargar más'));
    await tester.pumpAndSettle();
    expect(state.calls.last.offset, 10);
    expect(find.text('Mostrando 10 de 14 movimientos'), findsOneWidget);
    state.failMovements = false;
    await tester.ensureVisible(find.text('Reintentar'));
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(state.calls.last.offset, 10);
    expect(find.text('Mostrando 14 de 14 movimientos'), findsOneWidget);
    expect(find.text('Cargar más'), findsNothing);
    await tester.ensureVisible(find.byType(DropdownButton<bool>));
    await tester.tap(find.byType(DropdownButton<bool>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Más antiguos').last);
    await tester.pumpAndSettle();
    expect(state.calls.last.offset, 0);
    expect(state.calls.last.oldest, isTrue);
    expect(find.text('Reciente 0'), findsNothing);
    expect(find.text('Antiguo 0'), findsOneWidget);
    expect(find.text('Presupuesto en uso (84 %)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('descarta respuesta anterior al cambiar orden', (tester) async {
    tester.view.physicalSize = const Size(430, 1500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final old = Completer<List<DetalleMovimiento>>();
    final state = DetailState()..pendingMovements = old;
    await tester.pumpWidget(detail(state));
    await tester.pump();
    state.pendingMovements = null;
    await tester.ensureVisible(find.byType(DropdownButton<bool>));
    await tester.tap(find.byType(DropdownButton<bool>));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Más antiguos').last);
    await tester.pump(const Duration(seconds: 1));
    old.complete([]);
    await tester.pumpAndSettle();
    expect(find.text('Antiguo 0'), findsOneWidget);
    expect(find.text('Mostrando 10 de 14 movimientos'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('error permite reintentar en pantalla estrecha y texto grande', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final state = DetailState()..failMovements = true;
    await tester.pumpWidget(detail(state, scale: 1.5, dark: true));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Reintentar'));
    state.failMovements = false;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('Mostrando 10 de 14 movimientos'), findsOneWidget);
    final error = tester.takeException();
    if (error is FlutterError) {
      debugPrint(error.toStringDeep());
    }
    expect(error, isNull);
  });
}
