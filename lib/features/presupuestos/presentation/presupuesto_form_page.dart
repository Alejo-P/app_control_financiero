import 'package:control_financiero/core/constants/presupuesto_constants.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/features/presupuestos/models/presupuesto.dart';
import 'package:control_financiero/features/presupuestos/widgets/custom_dropdown.dart';
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
  final meses = monthNames;
  final anios = generateYearList(DateTime.now().year, 10);
  late String mesSeleccionado;
  late int anioSeleccionado;

  @override
  void initState() {
    super.initState();
    if (widget.mode == PresupuestoFormMode.edit &&
        widget.presupuesto != null) {
      mesSeleccionado = getMonthName(widget.presupuesto!.date);
      anioSeleccionado = widget.presupuesto!.date.year;
    } else {
      final now = DateTime.now();
      mesSeleccionado = getMonthName(now);
      anioSeleccionado = now.year;
    }
  }

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
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Periodo del presupuesto',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Selecciona el mes y año',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomDropdown<String>(
                            hintText: 'Mes',
                            items: meses,
                            selectedItem: mesSeleccionado,
                            onChanged: (value) {
                              setState(() => mesSeleccionado = value!);
                            },
                          ),
                          const SizedBox(width: 12),
                          CustomDropdown<int>(
                            hintText: 'Año',
                            items: anios,
                            selectedItem: anioSeleccionado,
                            onChanged: (value) {
                              setState(() => anioSeleccionado = value!);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
