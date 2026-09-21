import 'package:control_financiero/core/formatters/number_input_formatter.dart';
import 'package:flutter/material.dart';

class NumberInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isEditable;
  final String? Function(String?)? validator;
  final double fontSize;
  final FontWeight fontWeight;
  final TextAlign textAlign;

  const NumberInput({
    super.key,
    required this.controller,
    required this.isEditable,
    required this.validator,
    this.fontSize = 20,
    this.fontWeight = FontWeight.w500,
    this.textAlign = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return TextFormField(
      controller: controller,
      enabled: isEditable,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: textTheme.bodyLarge?.copyWith(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: colorScheme.primary,
      ),
      decoration: InputDecoration(
        hintText: '0.00',
        hintStyle: textTheme.bodyLarge?.copyWith(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: colorScheme.primary.withOpacity(0.5),
        ),
        border: InputBorder.none,
        isDense: true,
      ),
      inputFormatters: [NumberInputFormatter()],
      cursorColor: colorScheme.primary,
      textAlign: textAlign,
      validator: validator,
    );
  }
}
