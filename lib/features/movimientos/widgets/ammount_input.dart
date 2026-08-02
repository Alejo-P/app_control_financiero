import 'package:control_financiero/features/shared/widgets/number_input.dart';
import 'package:flutter/material.dart';

class AmountInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isEditable;
  final bool showLabel;
  final double fontSize;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final MainAxisAlignment position;
  final String? Function(String?)? validator;

  const AmountInput({
    super.key,
    required this.controller,
    this.isEditable = true,
    this.showLabel = true,
    this.fontSize = 20,
    this.fontWeight = FontWeight.bold,
    this.textAlign = TextAlign.center,
    this.position = MainAxisAlignment.center,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showLabel) 
          ...[
            // Label
            Text('Monto', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 5),
          ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: position,
          spacing: 8,
          children: [
            // Símbolo $
            Text(
              '\$',
              style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
            ),

            // Input
            IntrinsicWidth(
              child: NumberInput(
                controller: controller,
                isEditable: isEditable,
                validator: validator,
                fontSize: fontSize,
                fontWeight: fontWeight,
                textAlign: textAlign,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
