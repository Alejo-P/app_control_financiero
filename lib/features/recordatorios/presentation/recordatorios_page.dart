import 'package:control_financiero/app/app_routes.dart';
import 'package:control_financiero/app/app_snackbar.dart';
import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/services/notification_service.dart';
import 'package:control_financiero/features/recordatorios/models/recordatorio_form_args.dart';
import 'package:control_financiero/features/shared/widgets/confirm_dialog.dart';
import 'package:control_financiero/features/shared/widgets/loading_screen.dart';
import 'package:control_financiero/features/recordatorios/widgets/recordatorio_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class RecordatoriosPage extends StatefulWidget {
  const RecordatoriosPage({super.key});

  @override
  State<RecordatoriosPage> createState() => _RecordatoriosPageState();
}

class _RecordatoriosPageState extends State<RecordatoriosPage> {
  final ScrollController _controller = ScrollController();
  bool _showFAB = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    final shouldShow =
        _controller.offset <= 0 ||
        _controller.position.userScrollDirection == ScrollDirection.forward;

    if (_showFAB != shouldShow) {
      setState(() => _showFAB = shouldShow);
    }
  }

  Future<void> _refreshRecordatorios() async {
    final appState = context.read<AppState>();
    await appState.loadRecordatiosData();
  }

  Future<void> _onDeleteRecordatorio(String title, int id) async {
    final appState = context.read<AppState>();

    final confirm = await showConfirmDialog(
      context,
      title: 'Eliminar recordatorio',
      content: 'Va a eliminar el recordatorio \'$title\'',
    );

    if (confirm != true) return;

    await appState.eliminarRecordatorio(id);

    if (!mounted) return;

    if (appState.transactionSuccess == true) {
      AppSnackbar.success(context, appState.transactionResultMessage);
    } else {
      AppSnackbar.error(context, appState.transactionResultMessage);
    }
  }

  Future<void> _onEnabledChanged(int id, bool enabled) async {
    final appState = context.read<AppState>();
    await appState.actualizarEstadoRecordatorio(id, enabled);

    if (!mounted || appState.transactionSuccess == true) return;
    AppSnackbar.error(context, appState.transactionResultMessage);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final recordatorios = appState.recordatorios;

    return Scaffold(
      appBar: AppBar(title: const Text('Recordatorios')),
      floatingActionButton: AnimatedOpacity(
        opacity: _showFAB ? 1 : 0,
        duration: const Duration(milliseconds: 250),
        child: AnimatedSlide(
          offset: _showFAB ? Offset.zero : const Offset(0, 2),
          duration: const Duration(milliseconds: 200),
          child: FloatingActionButton(
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
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
        child: appState.loadingInitialData
            ? const LoadingScreen(message: 'Cargando recordatorios...')
            : recordatorios.isEmpty
            ? _EmptyRecordatorios()
            : ListView.separated(
                controller: _controller,
                itemCount: recordatorios.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final recordatorio = recordatorios[index];
                  final isSystemReminder =
                      recordatorio.id ==
                      NotificationService.getDailyMovementReminderId();

                  return RecordatorioCard(
                    icon: recordatorio.categoryIcon,
                    iconColor: recordatorio.categoryColor,
                    isEnabled: recordatorio.isEnabled,
                    categoryName: recordatorio.categoryName,
                    recurrency: recordatorio.recurrency,
                    createdAt: recordatorio.scheduledAt,
                    title: recordatorio.title,
                    onTap: isSystemReminder
                        ? null
                        : () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.recordatorioFormRoute,
                              arguments: RecordatorioFormArgs(
                                id: recordatorio.id!,
                              ),
                            );
                          },
                    onChange: isSystemReminder
                        ? null
                        : (enabled) =>
                              _onEnabledChanged(recordatorio.id!, enabled),
                    onDelete: isSystemReminder
                        ? null
                        : () => _onDeleteRecordatorio(
                            recordatorio.title,
                            recordatorio.id!,
                          ),
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
