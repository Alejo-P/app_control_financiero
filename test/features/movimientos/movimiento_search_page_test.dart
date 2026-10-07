import 'package:control_financiero/features/movimientos/models/detalle_movimiento.dart';
import 'package:control_financiero/features/movimientos/models/movimiento_search_page_result.dart';
import 'package:control_financiero/features/movimientos/presentation/movimiento_search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/constants/movimiento_constants.dart';
import '../../support/app_state_fakes.dart';

class SearchState extends TestAppState {
  final requests = <({String text, int page})>[];

  @override
  Future<MovimientoSearchPageResult> buscarMovimientosPaginados({
    int categoryId = -1,
    String text = '',
    DateTime? startDate,
    DateTime? endDate,
    int page = 0,
  }) async {
    text = text.trim().toLowerCase();
    requests.add((text: text, page: page));
    final total = text == 'ninguno'
        ? 0
        : text.isEmpty
        ? 47
        : 25;
    final count = total == 0
        ? 0
        : page == 0
        ? 20
        : total - 20;
    return MovimientoSearchPageResult(
      total: total,
      page: page,
      movimientos: List.generate(
        count,
        (i) => DetalleMovimiento(
          id: page * 20 + i + 1,
          title: '$text registro ${page * 20 + i + 1}',
          amount: 1,
          movementType: TipoMovimiento.gasto,
          date: DateTime(2026, 10, 1),
          categoryIcon: Icons.category,
          categoryColor: Colors.grey,
          categoryName: 'Alimentación',
          time: const TimeOfDay(hour: 10, minute: 0),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('pagina coincidencias y reinicia al cambiar o limpiar el texto', (
    tester,
  ) async {
    final state = SearchState();
    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: const MaterialApp(
          home: MovimientoSearchPage(listaCategorias: []),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('1–20 de 47 resultados'), findsOneWidget);
    expect(state.requests.last, (text: '', page: 0));

    await tester.enterText(find.byType(TextField).first, 'super');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(find.text('1–20 de 25 resultados'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byTooltip('Siguiente'),
      400,
      scrollable: find
          .descendant(
            of: find.byType(ListView).first,
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.byTooltip('Siguiente'));
    await tester.pumpAndSettle();
    expect(state.requests.last, (text: 'super', page: 1));
    expect(find.text('21–25 de 25 resultados'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'ninguno');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(state.requests.last, (text: 'ninguno', page: 0));
    expect(find.text('Resultados: 0'), findsOneWidget);
    expect(find.byTooltip('Siguiente'), findsNothing);

    await tester.tap(find.byTooltip('Limpiar campo de busqueda'));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(state.requests.last, (text: '', page: 0));
    expect(find.text('1–20 de 47 resultados'), findsOneWidget);
  });
}
