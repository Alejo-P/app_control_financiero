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
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home, size: 30),
          label: 'Inicio',
          tooltip: 'Pestaña de Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.compare_arrows_outlined),
          activeIcon: Icon(Icons.compare_arrows, size: 30),
          label: 'Movimientos',
          tooltip: 'Pestaña de Movimientos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.pie_chart_outline_outlined),
          activeIcon: Icon(Icons.pie_chart, size: 30),
          label: 'Presupuesto',
          tooltip: 'Pestaña de Presupuesto',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_outlined),
          activeIcon: Icon(Icons.history, size: 30),
          label: 'Historial',
          tooltip: 'Pestaña de Historial',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings, size: 30),
          label: 'Ajustes',
          tooltip: 'Pestaña de Ajustes',
        ),
      ],
      onTap: (index) => appState.changeTab(index),
    );
  }
}
