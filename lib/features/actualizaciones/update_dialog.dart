import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:control_financiero/features/shared/widgets/custom_button.dart';

import 'update_controller.dart';
import 'update_service.dart';

Future<void> showUpdateDialog(BuildContext context) => showDialog<void>(
  context: context,
  barrierDismissible: false,
  builder: (_) => const UpdateDialog(),
);

class UpdateDialog extends StatefulWidget {
  const UpdateDialog({super.key, this.controller});
  final UpdateController? controller;
  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog>
    with WidgetsBindingObserver {
  late final UpdateController controller;
  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? UpdateController(UpdateService());
    WidgetsBinding.instance.addObserver(this);
    controller.addListener(_changed);
    if (widget.controller == null) unawaited(controller.check());
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(controller.resume());
    } else {
      controller.leaveForeground();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.removeListener(_changed);
    controller.dispose();
    super.dispose();
  }

  void _close() {
    controller.cancel();
    Navigator.of(context).pop();
  }

  String _mb(num bytes) => (bytes / (1024 * 1024)).toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final accent = colors.secondary;
    final phase = controller.phase;
    final downloading = phase == UpdatePhase.downloading;
    final ready = phase == UpdatePhase.ready;
    final title = switch (phase) {
      UpdatePhase.checking => 'Buscando actualizaciones',
      UpdatePhase.available => 'Nueva versión disponible',
      UpdatePhase.downloading => 'Descargando actualización',
      UpdatePhase.ready => 'Actualización lista para instalar',
      UpdatePhase.current => 'La aplicación está actualizada',
      UpdatePhase.failed => 'No se pudo completar la actualización',
      UpdatePhase.cancelled => 'Descarga cancelada',
    };
    final progress = controller.progress;
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) controller.cancel();
      },
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 448),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      theme.dialogTheme.titleTextStyle ??
                      theme.textTheme.titleLarge,
                ),
                if (controller.release != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Versión ${controller.release!.version}',
                    style: theme.textTheme.titleSmall?.copyWith(color: accent),
                  ),
                ],
                const SizedBox(height: 28),
                if (phase == UpdatePhase.checking)
                  const Center(child: CircularProgressIndicator()),
                if (phase == UpdatePhase.available) ...[
                  Text(
                    'Novedades de esta versión:',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  ..._notes(controller.release!.notes),
                ],
                if (downloading) ...[
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 16,
                    runSpacing: 6,
                    children: [
                      Text(
                        progress == null
                            ? '0%'
                            : '${(progress.fraction * 100).floor()}%',
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        '${_mb(progress?.received ?? 0)} MB / ${_mb(controller.release!.size)} MB',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: progress?.fraction ?? 0,
                      minHeight: 12,
                      color: accent,
                      backgroundColor: accent.withValues(alpha: .08),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 16,
                    runSpacing: 6,
                    children: [
                      Text(
                        'Velocidad: ${_mb(progress?.bytesPerSecond ?? 0)} MB/s',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        progress?.received == controller.release!.size
                            ? 'Verificando paquete…'
                            : 'Tiempo restante: ${progress?.remainingSeconds == null ? "calculando…" : "~${progress!.remainingSeconds}s"}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _notice(
                    'Permanezca en esta vista hasta completar la descarga. Si sale, cierra o minimiza la aplicación, la descarga se cancelará.',
                  ),
                ],
                if (ready) ...[
                  Text(
                    'Descarga completada con éxito',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Paquete verificado • ${_mb(controller.release!.size)} MB',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 20),
                  _notice(
                    'La actualización se ha descargado y está lista para instalarse.',
                  ),
                ],
                if (phase == UpdatePhase.current)
                  const Text('Tiene la última versión disponible.'),
                if (phase == UpdatePhase.cancelled)
                  const Text(
                    'La descarga se detuvo. Puede volver a intentarlo permaneciendo en esta vista.',
                  ),
                if (controller.error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    controller.error!,
                    style: TextStyle(color: colors.error),
                  ),
                ],
                const SizedBox(height: 28),
                Align(
                  alignment: Alignment.centerRight,
                  child: OverflowBar(
                    alignment: MainAxisAlignment.end,
                    overflowAlignment: OverflowBarAlignment.end,
                    spacing: 8,
                    overflowSpacing: 8,
                    children: [
                      if (phase == UpdatePhase.available) ...[
                        TextButton(
                          onPressed: _close,
                          child: const Text('Cancelar'),
                        ),
                        CustomButton(
                          onTap: controller.download,
                          text: 'Descargar la actualización',
                        ),
                      ] else if (ready) ...[
                        TextButton(
                          onPressed: controller.installing ? null : _close,
                          child: const Text('Cerrar'),
                        ),
                        CustomButton(
                          onTap: controller.installing
                              ? null
                              : controller.install,
                          text: controller.installing
                              ? 'Preparando…'
                              : 'Instalar',
                        ),
                      ] else if (phase == UpdatePhase.failed ||
                          phase == UpdatePhase.cancelled) ...[
                        TextButton(
                          onPressed: _close,
                          child: const Text('Cerrar'),
                        ),
                        CustomButton(
                          onTap: controller.check,
                          text: 'Reintentar',
                        ),
                      ] else
                        TextButton(
                          onPressed: _close,
                          child: Text(
                            downloading || phase == UpdatePhase.checking
                                ? 'Cancelar'
                                : 'Cerrar',
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _notice(String message) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5),
      ),
    );
  }

  List<Widget> _notes(String notes) {
    final theme = Theme.of(context);
    final lines = notes.trim().isEmpty
        ? ['Mejoras y correcciones de la aplicación.']
        : notes
              .split('\n')
              .map((line) => line.trim())
              .where((line) => line.isNotEmpty);
    return lines.map((line) {
      final text = line
          .replaceFirst(RegExp(r'^(?:[-*+]\s+|#{1,6}\s+)'), '')
          .replaceAllMapped(
            RegExp(r'\[([^\]]+)\]\([^)]+\)'),
            (match) => match[1]!,
          )
          .replaceAll('**', '')
          .replaceAll('`', '');
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
        ),
      );
    }).toList();
  }
}

bool get supportsAppUpdates => Platform.isAndroid;
