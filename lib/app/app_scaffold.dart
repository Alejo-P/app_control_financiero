import 'package:control_financiero/app/app_appbar.dart';
import 'package:control_financiero/app/app_bottom_nav.dart';
import 'package:control_financiero/features/historial/presentation/historial_page.dart';
import 'package:control_financiero/features/movimientos/presentation/movimientos_page.dart';
import 'package:control_financiero/features/presupuestos/presentation/presupuestos_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/features/home/presentation/home_page.dart';
import 'package:control_financiero/features/ajustes/presentation/ajustes_page.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final pages = [
      const HomePage(),
      const MovimientosPage(),
      const PresupuestoPage(),
      const HistorialPage(),
      const AjustesPage(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AppAppbar(),
      body: pages[appState.currentTab],
      bottomNavigationBar: const AppBottomNav(),
    );
  }
}
