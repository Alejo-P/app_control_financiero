import 'package:control_financiero/app/app_routes.dart';
import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/features/recordatorios/models/recordatorio_form_args.dart';
import 'package:control_financiero/features/shared/widgets/confirm_dialog.dart';
import 'package:control_financiero/features/shared/widgets/loading_screen.dart';
import 'package:control_financiero/features/recordatorios/widgets/recordatorio_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecordatoriosPage extends StatelessWidget {
  const RecordatoriosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final recordatorios = appState.recordatorios;

    return Scaffold(
      appBar: AppBar(title: const Text('Recordatorios')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRoutes.recordatorioFormRoute,
            arguments: RecordatorioFormArgs(id: -1),
          );
        },
        tooltip: 'Agregar recordatorio',
        elevation: 2,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
        child: appState.loadingInitialData
            ? const LoadingScreen(message: 'Cargando recordatorios...')
            : recordatorios.isEmpty
            ? _EmptyRecordatorios()
            : ListView.separated(
                itemCount: recordatorios.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final recordatorio = recordatorios[index];
                  return RecordatorioCard(
                    icon: recordatorio.categoryIcon,
                    iconColor: recordatorio.categoryColor,
                    isEnabled: recordatorio.isEnabled,
                    categoryName: recordatorio.categoryName,
                    recurrency: recordatorio.recurrency,
                    createdAt: recordatorio.scheduledAt,
                    title: recordatorio.title,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.recordatorioFormRoute,
                        arguments: RecordatorioFormArgs(
                          id: recordatorio.id!,
                        ),
                      );
                    },
                    onDelete: () async {
                      final confirm = await showConfirmDialog(
                        context,
                        title: 'Eliminar recordatorio',
                        content:
                            'Va a eliminar el recordatorio \'${recordatorio.title}\'',
                      );

                      if (confirm != true) return;
                    },
                  );
                },
              ),
      ),
    );
  }
}

class _EmptyRecordatorios extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.hourglass_disabled_rounded,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No hay recordatorios establecidos.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          Text(
            'Establece un recordatorio nuevo para algun movimiento futuro.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
