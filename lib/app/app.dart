import 'package:control_financiero/core/constants/categoria_constants.dart';
import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/features/categorias/data/categorias_local_datasource.dart';
import 'package:control_financiero/features/categorias/data/categorias_repository.dart';
import 'package:control_financiero/features/categorias/presentation/categoria_form_page.dart';
import 'package:control_financiero/features/movimientos/data/movimientos_local_datasource.dart';
import 'package:control_financiero/features/movimientos/data/movimientos_repository.dart';
import 'package:control_financiero/features/movimientos/presentation/movimiento_form_page.dart';
import 'package:control_financiero/features/tipo_categorias/data/tipo_categoria_local_datasource.dart';
import 'package:control_financiero/features/tipo_categorias/data/tipo_categoria_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:control_financiero/core/constants/app_strings.dart';
import 'package:control_financiero/core/theme/app_theme.dart';
import 'app_state.dart';
import 'app_scaffold.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final movimientosRepository = MovimientosRepository(
      MovimientosLocalDataSource()
    );

    final categoriasRepository = CategoriasRepository(
      CategoriasLocalDataSource()
    );

    final tipoCategoriasRepository = TipoCategoriaRepository(
      TipoCategoriaLocalDataSource()
    );

    return ChangeNotifierProvider(
      create: (_) => AppState(
        movimientosRepository,
        categoriasRepository,
        tipoCategoriasRepository,
      )..loadInitialData(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: appName,
        theme: AppTheme.light,
        initialRoute: '/',
        routes: {
          '/': (_) => const AppScaffold(), // navegación principal
          '/agregar_movimiento': (_) => const MovimientoFormPage(mode: MovimientoFormMode.create),
          '/agregar_categoria': (_) => const CategoriaFormPage(mode: CategoriaFormMode.create),
        },
        //home: const AppScaffold(),
      ),
    );
  }
}