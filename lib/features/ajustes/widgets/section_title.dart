import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;

  const SectionTitle({super.key, required this.title, required this.icon, this.iconColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 40.0, color: iconColor ?? Theme.of(context).primaryColor),
          const SizedBox(width: 16.0),
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
