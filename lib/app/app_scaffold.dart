import 'package:control_financiero/app/app_appbar.dart';
import 'package:control_financiero/app/app_bottom_nav.dart';
import 'package:control_financiero/features/historial/presentation/historial_page.dart';
import 'package:control_financiero/features/movimientos/presentation/movimientos_page.dart';
import 'package:control_financiero/features/presupuestos/presentation/presupuestos_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/features/ajustes/presentation/ajustes_page.dart';
import 'package:control_financiero/core/tutorials/tutorial_host.dart';
import 'package:control_financiero/core/tutorials/tutorial_step.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final currentTab = appState.currentTab;
    final currentFAB = appState.floatingActionButton;
    final showFAB = appState.showFAB;
    final explainFAB =
        showFAB &&
        (currentTab == 0 ||
            (currentTab == 1 &&
                (appState.ingresoPresupuestado?.monto ?? 0) > 0));

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
          child: currentFAB == null
              ? null
              : !explainFAB
              ? currentFAB
              : TutorialTarget(
                  step: currentTab == 1
                      ? TutorialStep.addBudget
                      : TutorialStep.addMovement,
                  child: currentFAB,
                ),
        ),
      ),
      appBar: const AppAppbar(),
      body: pages[currentTab],
      bottomNavigationBar: currentTab == 0
          ? const TutorialTarget(
              step: TutorialStep.navigation,
              child: AppBottomNav(),
            )
          : const AppBottomNav(),
    );
  }
}
