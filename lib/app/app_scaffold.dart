import 'package:control_financiero/app/app_appbar.dart';
import 'package:control_financiero/app/app_bottom_nav.dart';
import 'package:control_financiero/features/historial/presentation/historial_page.dart';
import 'package:control_financiero/features/movimientos/presentation/movimientos_page.dart';
import 'package:control_financiero/features/presupuestos/presentation/presupuestos_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/features/ajustes/presentation/ajustes_page.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final currentTab = appState.currentTab;
    final currentFAB = appState.floatingActionButton;
    final showFAB = appState.showFAB;

    final pages = [
      MovimientosPage(),
      PresupuestosPage(),
      HistorialPage(),
      AjustesPage(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: AnimatedOpacity(
        opacity: showFAB ? 1 : 0,
        duration: const Duration(milliseconds: 250),
        child: AnimatedSlide(
          offset: showFAB ? Offset.zero : const Offset(0, 2),
          duration: const Duration(milliseconds: 200),
          child: currentFAB,
        ),
      ),
      appBar: const AppAppbar(),
      body: pages[currentTab],
      bottomNavigationBar: const AppBottomNav(),
    );
  }
}
