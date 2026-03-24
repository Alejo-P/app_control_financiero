import 'package:control_financiero/features/historial/widgets/ammount_detail_card.dart';
import 'package:control_financiero/features/shared/widgets/custom_button.dart';
import 'package:control_financiero/features/shared/widgets/custom_progress_bar.dart';
import 'package:flutter/material.dart';

class AccordeonContent extends StatelessWidget {
  final double totalIncome;
  final double spent;
  final VoidCallback? onTapButton;

  const AccordeonContent({
    super.key,
    required this.spent,
    required this.totalIncome,
    this.onTapButton,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final percentage = totalIncome == 0 ? 0 : (spent / totalIncome);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AmmountDetailCard(
              amount: totalIncome,
              name: 'Ingresos',
              icon: Icons.arrow_upward,
              iconColor: Colors.green,
            ),

            AmmountDetailCard(
              amount: spent,
              name: 'Gastos',
              icon: Icons.arrow_downward,
              iconColor: Colors.red,
            ),
          ],
        ),
        Text(
          "Presupuesto mensual:",
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: CustomProgressBar(
                currentValue: percentage.toDouble(),
                color: colorScheme.primary,
                backgroundColor: colorScheme.onSurface.withOpacity(0.18),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "Utilizado el ${(percentage * 100).toStringAsFixed(0)}% del total de ingresos",
        ),
        const SizedBox(height: 4),

        if (onTapButton != null)
          CustomButton(
            onTap: onTapButton,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Ver movimientos"),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward),
              ],
            ),
          ),
      ],
    );
  }
}
