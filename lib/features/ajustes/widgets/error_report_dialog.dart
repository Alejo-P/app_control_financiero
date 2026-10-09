import 'dart:io';
import 'dart:async';
import 'package:control_financiero/core/services/error_report_service.dart';
import 'package:control_financiero/core/services/error_report_sender.dart';
import 'package:control_financiero/core/utils/app_logger.dart';
import 'package:control_financiero/features/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class ErrorReportDialog extends StatefulWidget {
  const ErrorReportDialog({super.key, this.createReport, this.sendReport});
  final Future<File> Function(String)? createReport;
  final Future<void> Function(File)? sendReport;
  @override
  State<ErrorReportDialog> createState() => _ErrorReportDialogState();
}

class _ErrorReportDialogState extends State<ErrorReportDialog> {
  final _description = TextEditingController();
  bool _busy = false;
  String? _error;
  File? _report;

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final file = _report ??=
          await (widget.createReport ?? ErrorReportService().createReport)(
            _description.text,
          );
      if (!mounted) return;
      await (widget.sendReport ?? ErrorReportSender().send)(file);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error, stack) {
      unawaited(AppLogger.recordError('Error al enviar reporte', error, stack));
      if (mounted) {
        setState(() {
          _error = error is ReportSendException
              ? error.message
              : 'No se pudo preparar o enviar el reporte. Intenta nuevamente.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        title: Text(
          'Enviar reporte de error',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Se adjuntarán registros recientes, la versión de la app y datos técnicos del dispositivo. No se adjuntarán tus movimientos ni respaldos.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _description,
                enabled: !_busy,
                onChanged: (_) {
                  _report = null;
                },
                maxLength: 2000,
                minLines: 1,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: '¿Qué ocurrió? (opcional)',
                  hintText: 'Describe los pasos para reproducir el error.',
                  helperText: 'Evita incluir datos personales o financieros.',
                  helperMaxLines: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Se enviará al correo de soporte. Necesitas conexión a internet.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (_busy)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('Enviando reporte…'),
                ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _busy ? null : () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          CustomButton(
            onTap: _busy ? null : _send,
            text: _busy ? 'Enviando…' : 'Enviar reporte',
          ),
        ],
      ),
    );
  }
}
