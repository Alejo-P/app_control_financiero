import 'package:control_financiero/core/formatters/money_input_formatter.dart';
import 'package:flutter/material.dart';

class AmountInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isEditable;
  final bool showLabel;

  const AmountInput({
    super.key,
    required this.controller,
    this.isEditable = true,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 15),
        if (showLabel) 
          ...[
            // Label
            Text('Monto', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 5),
          ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Símbolo $
            Text(
              '\$',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 18),

            // Input
            IntrinsicWidth(
              child: TextField(
                controller: controller,
                enabled: isEditable,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
                inputFormatters: [MoneyInputFormatter()],
                cursorColor: colorScheme.primary,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
