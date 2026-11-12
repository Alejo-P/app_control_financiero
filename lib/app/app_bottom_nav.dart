import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final currentTab = context.select<AppState, int>(
      (state) => state.currentTab,
    );
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return NavigationBar(
      indicatorColor: colorScheme.primary,
      selectedIndex: currentTab,
      onDestinationSelected: (index) => appState.changeTab(index),
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
        final isSelected = states.contains(WidgetState.selected);

        return textTheme.labelSmall!.copyWith(
          color: colorScheme.primary,
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : null,
        );
      }),
      animationDuration: const Duration(milliseconds: 250),
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.compare_arrows_outlined, color: colorScheme.primary,),
          selectedIcon: Icon(Icons.compare_arrows),
          label: 'Movimientos',
          tooltip: 'Movimientos',
        ),
        NavigationDestination(
          icon: Icon(Icons.donut_large_outlined, color: colorScheme.primary,),
          selectedIcon: Icon(Icons.donut_large),
          label: 'Presupuestos',
          tooltip: 'Presupuesto',
        ),
        NavigationDestination(
          icon: Icon(Icons.history_outlined, color: colorScheme.primary,),
          selectedIcon: Icon(Icons.history),
          label: 'Historial',
          tooltip: 'Historial',
        ),
        NavigationDestination(
          icon: Icon(Icons.more_horiz_outlined, color: colorScheme.primary,),
          selectedIcon: Icon(Icons.more_horiz),
          label: 'Más acciones',
          tooltip: 'Más acciones',
        ),
      ],
    );
  }
}
