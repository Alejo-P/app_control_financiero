import 'package:control_financiero/features/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class BackupPasswordDialog extends StatefulWidget {
  final bool creating;
  const BackupPasswordDialog({super.key, required this.creating});

  @override
  State<BackupPasswordDialog> createState() => _BackupPasswordDialogState();
}

class _BackupPasswordDialogState extends State<BackupPasswordDialog> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _visible = false;

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.creating ? 'Proteger respaldo' : 'Abrir respaldo'),
    content: SingleChildScrollView(
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.creating
                  ? 'Elige al menos 12 caracteres. Guarda esta contraseña en un lugar seguro: '
                        'la necesitarás para restaurar en otro dispositivo o después de reinstalar. '
                        'La app no la guarda y no puede recuperarla si la olvidas.'
                  : 'Escribe la contraseña que elegiste al crear este respaldo.',
            ),
            TextFormField(
              controller: _password,
              obscureText: !_visible,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                suffixIcon: IconButton(
                  tooltip: _visible
                      ? 'Ocultar contraseña'
                      : 'Mostrar contraseña',
                  onPressed: () => setState(() => _visible = !_visible),
                  icon: Icon(
                    _visible ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Escribe la contraseña.';
                }
                if (widget.creating && value.runes.length < 12) {
                  return 'Usa al menos 12 caracteres.';
                }
                return null;
              },
            ),
            if (widget.creating)
              TextFormField(
                controller: _confirmation,
                obscureText: !_visible,
                autocorrect: false,
                enableSuggestions: false,
                decoration: const InputDecoration(
                  labelText: 'Confirmar contraseña',
                ),
                validator: (value) => value == _password.text
                    ? null
                    : 'Las contraseñas no coinciden.',
              ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      CustomButton(
        onTap: () {
          if (_form.currentState!.validate()) {
            Navigator.pop(context, _password.text);
          }
        },
        text: widget.creating ? 'Crear respaldo' : 'Restaurar',
      ),
    ],
  );
}
