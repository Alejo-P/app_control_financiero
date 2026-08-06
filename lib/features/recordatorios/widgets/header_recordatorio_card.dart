import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/core/utils/time_utils.dart';
import 'package:control_financiero/features/shared/widgets/icon_container.dart';
import 'package:flutter/material.dart';

class HeaderRecordatorioCard extends StatelessWidget {
  const HeaderRecordatorioCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.createdAt,
    required this.onDelete,
    required this.isEnabled,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final DateTime createdAt;
  final VoidCallback? onDelete;
  final bool isEnabled;
  final ValueChanged<bool>? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 10,
        children: [
          IconContainer(icon: icon, color: iconColor, size: 26),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [
                Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 16,
                      color: colorScheme.secondary,
                    ),
                    Text(
                      formatDate(createdAt),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    Icon(
                      Icons.access_time_outlined,
                      size: 16,
                      color: colorScheme.secondary,
                    ),
                    Text(
                      formatTimeFromDateTime(context, createdAt),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ],
            ),
          ),
      
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  tooltip: 'Eliminar',
                  icon: Icon(Icons.delete_forever_outlined),
                ),
              Switch(value: isEnabled, onChanged: onTap),
            ],
          ),
        ],
      ),
    );
  }
}
