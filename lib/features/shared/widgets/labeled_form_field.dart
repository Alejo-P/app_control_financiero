import 'package:control_financiero/features/shared/widgets/label_card.dart';
import 'package:flutter/material.dart';

class LabeledFormField extends StatelessWidget {
  final String label;
  final Icon icon;
  final Widget child;

  const LabeledFormField({
    super.key,
    required this.label,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        LabelCard(
          label: label,
          iconData: icon.icon,
          iconColor: icon.color,
          textStyle: textTheme.bodyMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        child,
      ],
    );
  }
}
