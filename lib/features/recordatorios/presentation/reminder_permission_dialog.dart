import 'package:control_financiero/core/services/notification_service.dart';
import 'package:control_financiero/features/shared/widgets/dialogs.dart';
import 'package:flutter/material.dart';

Future<bool> confirmReminderExactAlarmAccess(BuildContext context) async {
  if (await NotificationService.getExactAlarmAccess()) return true;
  if (!context.mounted) return false;
  final confirm = await showConfirmDialog(
    context,
    title: 'Permiso de alarmas exactas',
    content:
        '¿Desea otorgar permiso para alarmas exactas? Sin este permiso, el recordatorio puede llegar con retraso.',
    confirmText: 'Ir a configuración',
    cancelText: 'Continuar sin permiso',
  );
  if (!context.mounted || confirm != true) return false;
  return NotificationService.requestExactAlarmAccess();
}
