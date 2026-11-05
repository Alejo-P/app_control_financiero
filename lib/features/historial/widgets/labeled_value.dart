import 'package:flutter/material.dart';

class LabeledValue extends StatelessWidget {
  final String label;
  final String value;

  const LabeledValue({
    super.key,
    required this.label,
    required this.value,
  });


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          textAlign: TextAlign.right,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurfaceVariant,
          ),
        )
      ],
    );
  }
}
