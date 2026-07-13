import 'package:control_financiero/features/presupuestos/models/ingreso_presupuestado.dart';

class PresupuestoFormArgs {
  final int id;
  final bool viewOnly;
  final IngresoPresupuestado budgetedIncome;
  final DateTime? fechaPresupuesto;

  PresupuestoFormArgs({
    required this.id,
    this.viewOnly = false,
    required this.budgetedIncome,
    this.fechaPresupuesto,
  });
}