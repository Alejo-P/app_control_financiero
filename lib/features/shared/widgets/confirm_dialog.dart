import 'package:control_financiero/features/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';

Future<bool?> showConfirmAddDialog(
  BuildContext context, {
  required String titleModal,
  required List<Widget> content,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false, // obliga a elegir
    builder: (context) {
      return AlertDialog(
        title: Text(
          titleModal,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: content,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          CustomButton(
            onTap: () => Navigator.pop(context, true),
            text: 'Confirmar',
          ),
        ],
      );
    },
  );
}

// Dialogo de confirmacion
Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String content,
}) {
  final theme = Theme.of(context);
  final textTheme = theme.textTheme;
  final colorScheme = theme.colorScheme;

  return showDialog<bool>(
    context: context,
    barrierDismissible: false, // obliga a elegir
    builder: (context) {
      return AlertDialog(
        title: Text(
          title,
          style: textTheme.displayLarge?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Text(content),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          CustomButton(
            onTap: () => Navigator.pop(context, true),
            text: 'Confirmar',
          ),
        ],
      );
    },
  );
}