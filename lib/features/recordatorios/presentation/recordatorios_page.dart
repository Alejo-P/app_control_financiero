import 'package:control_financiero/app/app_routes.dart';
import 'package:control_financiero/app/app_snackbar.dart';
import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/utils/app_logger.dart';
import 'package:control_financiero/features/recordatorios/models/recordatorio.dart';
import 'package:control_financiero/features/recordatorios/presentation/reminder_permission_dialog.dart';
import 'package:control_financiero/features/recordatorios/models/recordatorio_form_args.dart';
import 'package:control_financiero/features/shared/widgets/dialogs.dart';
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
  bool _isLoading = false;
  bool _changingEnabled = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshRecordatorios();
    });
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
    setState(() {
      _isLoading = true;
    });
    final appState = context.read<AppState>();
    await appState.loadRecordatoriosData();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
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
    if (_changingEnabled) return;
    final appState = context.read<AppState>();
    setState(() => _changingEnabled = true);
    try {
      var exactAccess = true;
      if (enabled) {
        final reminder = await appState.getRecordatorioById(id);
        if (!mounted) return;
        if (reminder == null) {
          AppSnackbar.error(context, 'El recordatorio no existe.');
          return;
        }
        final recurrence = Recurrencia.values.firstWhere(
          (r) => r.name == reminder.recurrency,
          orElse: () => Recurrencia.ninguno,
        );
        if (resolveReminderDate(
              reminder.scheduledAt,
              recurrence,
              DateTime.now(),
            ) ==
            null) {
          AppSnackbar.warning(
            context,
            'No se puede reactivar recordatorios vencidos sin recurrencia.',
          );
          return;
        }
        exactAccess = await confirmReminderExactAlarmAccess(context);
        if (!mounted) return;
      }
      await appState.actualizarEstadoRecordatorio(id, enabled);
      if (!mounted) return;
      if (appState.transactionSuccess != true) {
        AppSnackbar.error(context, appState.transactionResultMessage);
      } else if (enabled && !exactAccess) {
        AppSnackbar.warning(
          context,
          'Recordatorio activado. Sin permiso para alarmas exactas, puede llegar con retraso.',
        );
      }
    } catch (error, stackTrace) {
      AppLogger.reportError(
        'Cambiar estado del recordatorio',
        error,
        stackTrace,
      );
      if (mounted) {
        AppSnackbar.error(
          context,
          'No se pudo cambiar el estado del recordatorio.',
        );
      }
    } finally {
      if (mounted) setState(() => _changingEnabled = false);
    }
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
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
          child: appState.loadingInitialData
              ? const LoadingScreen(message: 'Cargando recordatorios...')
              : RefreshIndicator(
                  onRefresh: _refreshRecordatorios,
                  child: _isLoading
                      ? LoadingScreen(message: 'Cargando recordatorios...')
                      : recordatorios.isEmpty
                      ? ListView(
                          controller: _controller,
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [_EmptyRecordatorios()],
                        )
                      : ListView.separated(
                          controller: _controller,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: recordatorios.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final recordatorio = recordatorios[index];
                            final isDefaultReminder = recordatorio.isDefault;

                            return RecordatorioCard(
                              icon:
                                  recordatorio.categoryIcon ??
                                  Icons.notifications_active_outlined,
                              iconColor:
                                  recordatorio.categoryColor ?? Colors.orange,
                              isEnabled: recordatorio.isEnabled,
                              categoryName: isDefaultReminder
                                  ? 'Predeterminada'
                                  : recordatorio.categoryName ?? 'Sin definir',
                              recurrency: recordatorio.recurrency,
                              createdAt: recordatorio.scheduledAt,
                              title: recordatorio.title,
                              isDefault: recordatorio.isDefault,
                              onTap: isDefaultReminder
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
                              onChange: isDefaultReminder || _changingEnabled
                                  ? null
                                  : (enabled) => _onEnabledChanged(
                                      recordatorio.id!,
                                      enabled,
                                    ),
                              onDelete: isDefaultReminder
                                  ? null
                                  : () => _onDeleteRecordatorio(
                                      recordatorio.title,
                                      recordatorio.id!,
                                    ),
                            );
                          },
                        ),
                ),
        ),
      ),
    );
  }
}

class _EmptyRecordatorios extends StatelessWidget {
  const _EmptyRecordatorios();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 150),
      child: Column(
        children: [
          Icon(Icons.hourglass_disabled_rounded, size: 80, color: Colors.grey),
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
            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
