import 'package:flutter/material.dart';

class IconLabelCard extends StatelessWidget {
  final String label;
  final Icon icon;

  const IconLabelCard({super.key, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
