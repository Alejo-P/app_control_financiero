// ignore_for_file: use_build_context_synchronously

import 'package:control_financiero/app/app_snackbar.dart';
import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/features/notificaciones/models/notificacion.dart';
import 'package:control_financiero/features/shared/widgets/confirm_dialog.dart';
import 'package:control_financiero/features/shared/widgets/icon_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificacionesPage extends StatefulWidget {
  const NotificacionesPage({super.key});

  @override
  State<NotificacionesPage> createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final appState = context.read<AppState>();

    if (!_scrollController.hasClients) return;

    final threshold = 200;
    final max = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;

    if (current >= max - threshold) {
      if (!appState.isLoadingNotif && appState.hasMoreNotif) {
        appState.fetchMoreNotifications();
      }
    }
  }

  Future<void> _marcarComoLeido(Notificacion notificacion) async {
    final appState = context.read<AppState>();

    await appState.marcarNotifLeida(notificacion);
  }

  Future<void> _marcarTodoLeido() async {
    final appState = context.read<AppState>();

    await appState.marcarTodaNotifLeida();
  }

  Future<void> _eliminarNotificacion(int id) async {
    final appState = context.read<AppState>();

    final confirmed = await showConfirmDialog(
      context,
      title: 'Eliminar Notificación',
      content: 'Esta seguro de eliminar esta notificación?',
    );

    if (confirmed != true) return;

    final success = await appState.eliminarNotificacion(id);
    if (!mounted) return;

    if (success) {
      AppSnackbar.success(context, 'Notificación eliminada con éxito');
      return;
    }

    AppSnackbar.error(context, 'No se pudo eliminar la notificación');
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final unReadNotif = appState.notifSinLeer;
    final notifications = appState.notificaciones;

    if (notifications.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Notificaciones')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.notifications_off_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              Text(
                'No hay notificaciones nuevas.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Notificaciones'),
        actions: [
          if (unReadNotif > 0)
            IconButton(
              icon: Icon(Icons.done_all),
              onPressed: _marcarTodoLeido,
              tooltip: 'Marcar todo como leído',
            ),
        ],
      ),
      body: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        itemCount: notifications.length + 1,
        itemBuilder: (context, index) {
          if (index < notifications.length) {
            final notif = notifications[index];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: InkWell(
                onTap: () => _marcarComoLeido(notif),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔴 Indicador no leído
                      if (!notif.isRead)
                        Container(
                          margin: const EdgeInsets.only(right: 8, top: 6),
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        )
                      else
                        const SizedBox(width: 8),

                      // 🎨 Icono
                      IconContainer(
                        icon: notif.iconData,
                        color: Color(notif.iconColorValue),
                        size: 28,
                      ),

                      const SizedBox(width: 12),

                      // 📝 Texto
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notif.title,
                              style: TextStyle(
                                fontWeight: notif.isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notif.description,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _eliminarNotificacion(notif.id!),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (appState.hasMoreNotif) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          } else {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: Text("No hay más notificaciones")),
            );
          }
        },
      ),
    );
  }
}
