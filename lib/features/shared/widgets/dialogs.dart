import 'package:control_financiero/features/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';

Future<bool?> showConfirmAddDialog(
  BuildContext context, {
  required String titleModal,
  required List<Widget> content,
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
          titleModal,
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: content,
        ),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(content),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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

Future<void> showLoadingDialog(BuildContext context, [String? message]) async {
  final theme = Theme.of(context);
  final textTheme = theme.textTheme;
  final colorScheme = theme.colorScheme;

  // 👇 Loading
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            message ?? 'Cargando...',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
          ),
        ),
      ],
    ),
  );
}
