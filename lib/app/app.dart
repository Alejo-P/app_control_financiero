import 'package:control_financiero/app/splash_screen.dart';
import 'package:control_financiero/app/app_routes.dart';
import 'package:control_financiero/core/services/navigation_service.dart';
import 'package:control_financiero/core/services/notification_service.dart';
import 'package:control_financiero/features/ajustes/presentation/about_page.dart';
import 'package:control_financiero/features/ajustes/presentation/notification_config_page.dart';
import 'package:control_financiero/features/categorias/data/categorias_local_datasource.dart';
import 'package:control_financiero/features/categorias/data/categorias_repository.dart';
import 'package:control_financiero/features/categorias/presentation/categoria_form_page.dart';
import 'package:control_financiero/features/historial/data/historial_local_datasource.dart';
import 'package:control_financiero/features/historial/data/historial_repository.dart';
import 'package:control_financiero/features/movimientos/data/movimientos_local_datasource.dart';
import 'package:control_financiero/features/movimientos/data/movimientos_repository.dart';
import 'package:control_financiero/features/movimientos/presentation/movimiento_form_page.dart';
import 'package:control_financiero/features/notificaciones/data/notificacion_local_datasource.dart';
import 'package:control_financiero/features/notificaciones/data/notificacion_repository.dart';
import 'package:control_financiero/features/notificaciones/presentation/notification_detail_page.dart';
import 'package:control_financiero/features/presupuestos/data/presupuestos_local_datasource.dart';
import 'package:control_financiero/features/presupuestos/data/presupuestos_repository.dart';
import 'package:control_financiero/features/presupuestos/presentation/presupuesto_form_page.dart';
import 'package:control_financiero/features/recordatorios/presentation/recordatorios_page.dart';
import 'package:control_financiero/features/tipo_categorias/data/tipo_categoria_local_datasource.dart';
import 'package:control_financiero/features/tipo_categorias/data/tipo_categoria_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:control_financiero/core/constants/app_strings.dart';
import 'package:control_financiero/core/theme/app_theme.dart';
import 'app_state.dart';
import 'app_scaffold.dart';

class App extends StatefulWidget {
  final NotificationAppLaunchDetails? notificationLaunchDetails;

  const App({super.key, this.notificationLaunchDetails});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final details = widget.notificationLaunchDetails;

      if (details?.didNotificationLaunchApp ?? false) {
        final payload = details!.notificationResponse?.payload;

        if (payload != null) {
          NotificationService.handleNotificationTap(payload);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
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

        final historialRepository = HistorialRepository(
          HistorialLocalDataSource(),
        );

        final notificacionRepository = NotificacionRepository(
          NotificacionLocalDataSource(),
        );

        final appState = AppState(
          movimientosRepository,
          categoriasRepository,
          tipoCategoriasRepository,
          presupuestosRepository,
          historialRepository,
          notificacionRepository,
        );

        appState.loadInitialData();

        return appState;
      },
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            title: appName,
            theme: appState.isDarkMode ? AppTheme.dark : AppTheme.light,

            // Rutas (pendiente por usar en todas las vistas)
            routes: {
              AppRoutes.notifDetalleRoute: (context) =>
                  const NotificationDetailPage(),
              AppRoutes.movimientoFormRoute: (context) =>
                  const MovimientoFormPage(),
              AppRoutes.presupuestoFormRoute: (context) =>
                  const PresupuestoFormPage(),
              AppRoutes.categoriaFormRoute: (context) =>
                  const CategoriaFormPage(),
              AppRoutes.notificationConfigRoute: (context) =>
                  const NotificationConfigPage(),
              AppRoutes.aboutRoute: (context) => const AboutPage(),
              AppRoutes.recordatoriosRoute: (context) =>
                  const RecordatoriosPage(),
            },

            home: appState.loadingInitialData
                ? const SplashScreen()
                : const AppScaffold(),
          );
        },
      ),
    );
  }
}
