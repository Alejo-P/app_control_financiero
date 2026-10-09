import 'package:control_financiero/features/shared/widgets/custom_button.dart';
import 'package:control_financiero/features/shared/widgets/text_input_card.dart';
import 'package:flutter/material.dart';

bool _isValid(String text) => text.length == 32 && !text.contains(' ');

// Dialogo de confirmacion
Future<String?> showEncryptionKeyInputDialog(
  BuildContext context, [
  String? message,
]) {
  final textController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> isValid = ValueNotifier(false);

  textController.addListener(() {
    isValid.value = _isValid(textController.text);
  });

  return showDialog<String>(
    context: context,
    barrierDismissible: false, // obliga a elegir
    builder: (context) {
      final theme = Theme.of(context);
      final textTheme = theme.textTheme;
      final colorScheme = theme.colorScheme;
      return AlertDialog(
        title: Text(
          'Clave de encriptación',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
              key: formKey,
              child: TextInputCard(
                textController: textController,
                maxLength: 32,
                iconData: Icons.key_rounded,
                iconColor: Colors.red,
                placeholder: 'Ingrese una clave de 32 caracteres',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo requerido';
                  }

                  if (value.contains(' ')) {
                    return 'No debe contener espacios';
                  }

                  if (value.length != 32) {
                    return 'Debe tener exactamente 32 caracteres';
                  }

                  return null;
                },
              ),
            ),
            if (message != null && message.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(message, style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancelar'),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: isValid,
            builder: (context, value, _) {
              return CustomButton(
                onTap: value
                    ? () => Navigator.pop(context, textController.text)
                    : null,
                text: 'Confirmar',
              );
            },
          ),
        ],
      );
    },
  );
}
