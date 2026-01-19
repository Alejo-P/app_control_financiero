import 'package:control_financiero/core/constants/presupuesto_constants.dart';
import 'package:control_financiero/features/presupuestos/models/presupuesto.dart';
import 'package:control_financiero/features/shared/widgets/confirm_dialog.dart';
import 'package:flutter/material.dart';

class PresupuestoFormPage extends StatefulWidget {
  final PresupuestoFormMode mode;
  final Presupuesto? presupuesto;

  const PresupuestoFormPage({super.key, required this.mode, this.presupuesto});

  @override
  State<PresupuestoFormPage> createState() => _PresupuestoFormPageState();
}

class _PresupuestoFormPageState extends State<PresupuestoFormPage> {
  final _hasUnsavedChanges = false;

   Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final shouldLeave = await showConfirmDialog(
      context,
      title: 'Salir sin guardar',
      content: 'Tienes cambios sin guardar. ¿Seguro que deseas salir?',
    );

    return shouldLeave == true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.mode == PresupuestoFormMode.create
                ? 'Nuevo Presupuesto'
                : 'Editar Presupuesto',
          ),
        ),
        body: Center(
          child: Text('Formulario de Presupuesto'),
        ),
      ),
    );
  }
}
