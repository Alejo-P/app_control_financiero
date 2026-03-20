import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

class AppAppbar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final actions = appState.appBarActions;

    final isWide = MediaQuery.of(context).size.width > 600;

    return AppBar(
      title: Text(appState.currentPageName),
      centerTitle: false,
      actions: actions.map((action) {
        final hasLabel = action.labelValue.isNotEmpty;
        final hasTooltip = action.tooltipValue.isNotEmpty;

        if (isWide && hasLabel) {
          return TextButton.icon(
            onPressed: action.onPressed,
            icon: Icon(action.icon),
            label: Text(action.labelValue),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          );
        }

        return IconButton(
          icon: Icon(action.icon),
          onPressed: action.onPressed,
          tooltip: hasTooltip ? action.tooltipValue : action.labelValue,
        );
      }).toList(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
