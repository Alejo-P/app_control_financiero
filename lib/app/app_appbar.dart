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

        Widget widget;

        if (hasLabel) {
          widget = BadgeWidget(
            counter: action.badgeCountValue,
            child: TextButton.icon(
              onPressed: action.onPressed,
              label: Text(action.labelValue),
              icon:
                  action.iconWidget ??
                  Icon(action.icon ?? Icons.help_outline, size: 26),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          );
        } else {
          widget = BadgeWidget(
            counter: action.badgeCountValue,
            child: SizedBox(
              height: 44,
              width: 44,
              child: IconButton(
                icon:
                    action.iconWidget ??
                    Icon(action.icon ?? Icons.help_outline, size: 26),
                onPressed: action.onPressed,
                tooltip: hasTooltip
                    ? action.tooltipValue
                    : (hasLabel ? action.labelValue : null),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: widget,
        );
      }).toList(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
