import 'package:control_financiero/features/recordatorios/widgets/icon_label_card.dart';
import 'package:flutter/material.dart';

class FooterRecordatorioCard extends StatelessWidget {
  const FooterRecordatorioCard({
    super.key,
    required this.categoryName,
    required this.recurrency,
  });

  final String categoryName;
  final String recurrency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: IconLabelCard(
              label: categoryName,
              icon: Icon(Icons.category_outlined, color: colorScheme.secondary),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: IconLabelCard(
              label: recurrency,
              icon: Icon(Icons.repeat_outlined, color: colorScheme.secondary),
            ),
          ),
        ],
      ),
    );
  }
}
