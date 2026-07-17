import 'package:control_financiero/core/utils/color_utils.dart';
import 'package:flutter/material.dart';

class InfoCategoriaPredeterminada extends StatelessWidget {
  final bool isDefault;

  const InfoCategoriaPredeterminada({super.key, required this.isDefault});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final [r, g, b] = getRGBFromColor(isDefault ? Colors.orange : Colors.grey);

    return Center(
      child: IntrinsicWidth(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Color.fromRGBO(r, g, b, 0.5),
          ),
          alignment: Alignment.center,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 9),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isDefault ? Icons.lock : Icons.lock_open,
                color: isDefault
                    ? colorScheme.primary
                    : colorScheme.onSurface.withOpacity(0.6),
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                isDefault
                    ? 'Esta es una categoría predeterminada'
                    : 'Esta categoría no es predeterminada',
                style: textTheme.bodySmall?.copyWith(
                  color: isDefault
                      ? colorScheme.primary
                      : colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}