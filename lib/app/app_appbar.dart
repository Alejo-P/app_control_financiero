import 'package:control_financiero/features/shared/widgets/badge_widget.dart';
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
      title: Text(appState.currentPageName),
      centerTitle: false,
      actions: actions.map((action) {
        final hasLabel = action.labelValue.isNotEmpty;
        final hasTooltip = action.tooltipValue.isNotEmpty;

        if (hasLabel) {
          return BadgeWidget(
            counter: action.badgeCountValue,
            child: TextButton.icon(
              onPressed: action.onPressed,
              label: Text(action.labelValue),
              icon: Icon(action.icon),
              style: TextButton.styleFrom(
                //foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          );
        }

        return BadgeWidget(
          counter: action.badgeCountValue,
          child: IconButton(
            icon: Icon(action.icon),
            onPressed: action.onPressed,
            tooltip: hasTooltip ? action.tooltipValue : action.labelValue,
          ),
        );
      }).toList(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
