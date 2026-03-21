// ignore_for_file: use_build_context_synchronously

import 'package:control_financiero/app/app_snackbar.dart';
import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/features/notificaciones/models/notificacion.dart';
import 'package:control_financiero/features/notificaciones/widgets/notification_card.dart';
import 'package:control_financiero/features/shared/widgets/confirm_dialog.dart';
import 'package:control_financiero/features/shared/widgets/widgets_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class NotificacionesPage extends StatefulWidget {
  const NotificacionesPage({super.key});

  @override
  State<NotificacionesPage> createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  final ScrollController _scrollController = ScrollController();
  late final Timer _timer;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
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

  Map<String, List<Notificacion>> agruparNotificaciones(
    List<Notificacion> notificaciones,
  ) {
    final Map<String, List<Notificacion>> grupos = {};

    for (final notif in notificaciones) {
      final label = getDateGroupLabel(notif.createdAt!);

      if (!grupos.containsKey(label)) {
        grupos[label] = [];
      }

      grupos[label]!.add(notif);
    }

    return grupos;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final unReadNotif = appState.notifSinLeer;
    final notifications = appState.notificaciones;
    final grouped = agruparNotificaciones(notifications);
    final keys = grouped.keys.toList();
    keys.sort((a, b) {
      const orden = ['Hoy', 'Ayer', 'Esta semana'];

      final ia = orden.indexOf(a);
      final ib = orden.indexOf(b);

      if (ia != -1 && ib != -1) return ia.compareTo(ib);
      if (ia != -1) return -1;
      if (ib != -1) return 1;

      return b.compareTo(a); // fallback (meses/años)
    });

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
        itemCount: keys.length + 1,
        itemBuilder: (context, index) {
          if (index < keys.length) {
            final key = keys[index];
            final items = grouped[key]!;

            return WidgetsContainer(
              padding: EdgeInsetsGeometry.all(4),
              title: key,
              children: items.map((notif) {
                return _buildNotifItem(notif);
              }).toList(),
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

  Widget _buildNotifItem(Notificacion notif) {
    return NotificationCard(
      title: notif.title,
      description: notif.description,
      iconData: notif.iconData,
      iconColor: notif.iconColor,
      createdAt: notif.createdAt!,
      isRead: notif.isRead,
      onTap: () => _marcarComoLeido(notif),
      onDelete: () => _eliminarNotificacion(notif.id!),
    );
  }
}
