import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/features/categorias/models/categoria_form_args.dart';
import 'package:control_financiero/features/categorias/models/detalle_categoria.dart';
import 'package:control_financiero/features/categorias/presentation/categoria_form_page.dart';
import 'package:control_financiero/features/shared/widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../../support/app_state_fakes.dart';

class _State extends TestAppState {
  @override
  Future<DetalleCategoria?> obtenerDetalleCategoriaPorId(int id) async =>
      const DetalleCategoria(
        id: 7,
        name: 'Personal',
        movementType: TipoMovimiento.gasto,
        categoryTypeName: 'Otros',
        categoryTypeID: 1,
        icon: Icons.home,
        color: Colors.blue,
      );
  @override
  Future<void> eliminarCategoria(int id) async =>
      throw Exception('SQLite failure');
}

void main() {
  testWidgets(
    'un error al borrar recupera el formulario y muestra un mensaje',
    (tester) async {
      final state = _State();
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: state,
          child: MaterialApp(
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              settings: RouteSettings(arguments: CategoriaFormArgs(id: 7)),
              builder: (_) => const CategoriaFormPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Eliminar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(LoadingScreen), findsNothing);
      expect(
        find.text('No se pudo eliminar la categoría. Inténtalo nuevamente.'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<IconButton>(
              find.byWidgetPredicate(
                (widget) =>
                    widget is IconButton && widget.tooltip == 'Eliminar',
              ),
            )
            .onPressed,
        isNotNull,
      );
      await tester.pumpWidget(const SizedBox());
      state.dispose();
    },
  );
}
