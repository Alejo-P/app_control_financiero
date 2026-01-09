import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

class AppAppbar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final actions = appState.appBarActions;

    return AppBar(
      title: Text(
        appState.currentPageName
      ),
      centerTitle: false,
      actions: actions
          .map(
            (action) => IconButton(
              icon: Icon(action.icon),
              onPressed: action.onPressed,
              tooltip: action.tooltip,
            ),
          )
          .toList(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}