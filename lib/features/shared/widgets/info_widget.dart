import 'package:flutter/material.dart';

class InfoWidget extends StatelessWidget {
  final bool loadingInitialData;
  final IconData? icon;
  final String message;

  const InfoWidget({
    super.key,
    required this.loadingInitialData,
    required this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        icon != null
            ? Icon(icon, color: colorScheme.onSurface.withOpacity(0.6))
            : Icon(Icons.info_outline_rounded, color: colorScheme.onSurface.withOpacity(0.6)),
        Expanded(
          child: Text(
            message,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.primary.withOpacity(0.6),
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            softWrap: loadingInitialData ? false : true,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}
