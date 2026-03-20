import 'package:control_financiero/app/splash_screen.dart';
import 'package:control_financiero/features/categorias/data/categorias_local_datasource.dart';
import 'package:control_financiero/features/categorias/data/categorias_repository.dart';
import 'package:control_financiero/features/historial/data/historial_local_datasource.dart';
import 'package:control_financiero/features/historial/data/historial_repository.dart';
import 'package:control_financiero/features/movimientos/data/movimientos_local_datasource.dart';
import 'package:control_financiero/features/movimientos/data/movimientos_repository.dart';
import 'package:control_financiero/features/presupuestos/data/presupuestos_local_datasource.dart';
import 'package:control_financiero/features/presupuestos/data/presupuestos_repository.dart';
import 'package:control_financiero/features/tipo_categorias/data/tipo_categoria_local_datasource.dart';
import 'package:control_financiero/features/tipo_categorias/data/tipo_categoria_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:control_financiero/core/constants/app_strings.dart';
import 'package:control_financiero/core/theme/app_theme.dart';
import 'app_state.dart';
import 'app_scaffold.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AppState _appState;

  @override
  void initState() {
    super.initState();

    final movimientosRepository = MovimientosRepository(
      MovimientosLocalDataSource(),
    );

    final categoriasRepository = CategoriasRepository(
      CategoriasLocalDataSource(),
    );

    final tipoCategoriasRepository = TipoCategoriaRepository(
      TipoCategoriaLocalDataSource(),
    );

    final presupuestosRepository = PresupuestosRepository(
      PresupuestosLocalDataSource(),
    );

    final historialRepository = HistorialRepository(HistorialLocalDataSource());

    _appState = AppState(
      movimientosRepository,
      categoriasRepository,
      tipoCategoriasRepository,
      presupuestosRepository,
      historialRepository,
    );

    _appState.loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _appState,
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: appName,
            theme: appState.isDarkMode ? AppTheme.dark : AppTheme.light,
            home: appState.loadingInitialData
                ? const SplashScreen()
                : const AppScaffold(),
          );
        },
      ),
    );
  }
}
