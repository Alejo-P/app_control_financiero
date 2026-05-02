import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return BottomNavigationBar(
      currentIndex: appState.currentTab,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      landscapeLayout: BottomNavigationBarLandscapeLayout.linear,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.compare_arrows_outlined),
          activeIcon: Icon(Icons.compare_arrows, size: 30),
          label: 'Movimientos',
          tooltip: 'Pestaña de Movimientos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.donut_large_outlined),
          activeIcon: Icon(Icons.donut_large, size: 30),
          label: 'Presupuestos',
          tooltip: 'Pestaña de Presupuesto',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_outlined),
          activeIcon: Icon(Icons.history, size: 30),
          label: 'Historial',
          tooltip: 'Pestaña de Historial',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.more_horiz_outlined),
          activeIcon: Icon(Icons.more_horiz, size: 30),
          label: 'Más acciones',
          tooltip: 'Pestaña de Más acciones',
        ),
      ],
      onTap: (index) => appState.changeTab(index),
    );
  }
}
