// ignore_for_file: use_build_context_synchronously

import 'package:control_financiero/app/app_snackbar.dart';
import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/app/app_routes.dart';
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:control_financiero/features/notificaciones/models/notificacion.dart';
import 'package:control_financiero/features/notificaciones/widgets/notification_card.dart';
import 'package:control_financiero/features/shared/widgets/dialogs.dart';
import 'package:control_financiero/features/shared/widgets/loading_screen.dart';
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
  final Set<int> selectedNotifications = {};
  bool _isLoading = false;
  bool _isDeleting = false;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshNotificaciones();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshNotificaciones() async {
    setState(() {
      _isLoading = true;
    });
    final appState = context.read<AppState>();
    await appState.loadNotifications();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  void _onScroll() {
    if (_isDeleting) return;
    if (!_scrollController.hasClients) return;

    final appState = context.read<AppState>();
    final threshold = 200;
    final max = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;

    if (current >= max - threshold) {
      if (!appState.isLoadingNotif && appState.hasMoreNotif) {
        appState.fetchMoreNotifications();
      }
    }
  }

  void _toggleSelection(int id) {
    setState(() {
      if (selectedNotifications.contains(id)) {
        selectedNotifications.remove(id);
      } else {
        selectedNotifications.add(id);
      }
    });
  }

  void _toggleAll(List<Notificacion> notifications) {
    final notificationIds = notifications.map((n) => n.id!).toSet();
    final allSelected =
        notificationIds.isNotEmpty &&
        notificationIds.every(selectedNotifications.contains);

    setState(() {
      if (allSelected) {
        selectedNotifications.removeAll(notificationIds);
      } else {
        selectedNotifications.addAll(notificationIds);
      }
    });
  }

  void _clearSelection() {
    setState(() => selectedNotifications.clear());
  }

  Future<void> _verDetallesNotificacion(int id) async {
    Navigator.pushNamed(context, AppRoutes.notifDetalleRoute, arguments: id);
  }

  Future<void> _marcarSeleccionadasComoLeidas() async {
    final selectedIds = selectedNotifications.toList();
    final appState = context.read<AppState>();

    for (final id in selectedIds) {
      await appState.marcarNotifLeida(id);
    }
  }

  Future<void> _eliminarNotificacion(int id) async {
    final appState = context.read<AppState>();

    final confirmed = await showConfirmDialog(
      context,
      title: 'Eliminar Notificación',
      content: 'Esta seguro de eliminar esta notificación?',
    );

    if (!mounted || confirmed != true) return;
    if (_isDeleting || appState.isLoadingNotif) return;

    setState(() => _isDeleting = true);

    try {
      final limiteRecarga = appState.notificaciones.length < 10
          ? 10
          : appState.notificaciones.length;

      final success = await appState.eliminarNotificacion(id);
      if (!mounted) return;

      if (success) {
        await appState.loadNotifications(limit: limiteRecarga);
        if (!mounted) return;
        setState(() => selectedNotifications.remove(id));
        AppSnackbar.success(context, 'Notificación eliminada con éxito');
        return;
      }

      AppSnackbar.error(context, 'No se pudo eliminar la notificación');
    } on Exception catch (_) {
      if (mounted) {
        AppSnackbar.error(
          context,
          'No se pudo completar la operación. Actualiza la lista.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  Future<void> _eliminarSeleccionadas() async {
    final appState = context.read<AppState>();
    final selectedIds = selectedNotifications.toList();
    final count = selectedIds.length;

    final confirmed = await showConfirmDialog(
      context,
      title: 'Eliminar Notificaciones',
      content: 'Esta seguro de eliminar $count notificaciones?',
    );

    if (!mounted || confirmed != true) return;
    if (_isDeleting || appState.isLoadingNotif) return;

    setState(() => _isDeleting = true);

    try {
      final limiteRecarga = appState.notificaciones.length < 10
          ? 10
          : appState.notificaciones.length;

      var eliminadas = 0;
      for (final id in selectedIds) {
        if (await appState.eliminarNotificacion(id)) {
          eliminadas++;
        }
      }
      await appState.loadNotifications(limit: limiteRecarga);
      if (!mounted) return;

      if (eliminadas == count) {
        AppSnackbar.success(
          context,
          '$count notificaciones eliminadas con éxito',
        );
      } else {
        AppSnackbar.warning(
          context,
          '$eliminadas de $count notificaciones eliminadas con éxito',
        );
      }
    } on Exception catch (_) {
      if (mounted) {
        AppSnackbar.error(
          context,
          'No se pudo completar la operación. Actualiza la lista.',
        );
      }
    } finally {
      if (mounted) {
        _clearSelection();
        setState(() => _isDeleting = false);
      }
    }
  }

  Future<void> _eliminarTodasNotificaciones() async {
    final appState = context.read<AppState>();

    final confirmed = await showConfirmDialog(
      context,
      title: 'Eliminar Todas las Notificaciones',
      content: '¿Está seguro de eliminar todas las notificaciones?',
    );

    if (confirmed != true) return;

    final success = await appState.eliminarTodasNotificaciones();
    if (!mounted) return;

    if (success) {
      _clearSelection();
      AppSnackbar.success(
        context,
        'Todas las notificaciones han sido eliminadas',
      );
      return;
    }

    AppSnackbar.error(context, 'No se pudieron eliminar las notificaciones');
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
    final notificationIds = notifications.map((n) => n.id!).toSet();
    final selectedCount = notificationIds
        .where(selectedNotifications.contains)
        .length;
    final allSelected =
        notificationIds.isNotEmpty && selectedCount == notificationIds.length;
    final someSelected = selectedCount > 0 && !allSelected;
    final grouped = agruparNotificaciones(notifications);
    final keys = grouped.keys.toList();
    keys.sort((a, b) {
      const orden = ['Hoy', 'Ayer', 'Esta semana', 'Este mes'];

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
        body: SafeArea(
          top: false,
          child: RefreshIndicator(
            onRefresh: _refreshNotificaciones,
            child: (_isLoading || _isDeleting)
                ? LoadingScreen(message: 'Cargando notificaciones...')
                : Center(
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
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Notificaciones'),
        actions: [
          if (selectedNotifications.isNotEmpty && !(_isLoading || _isDeleting))
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _clearSelection,
              tooltip: 'Cancelar selección',
            ),

          if (unReadNotif > 0 && selectedNotifications.isNotEmpty && !(_isLoading || _isDeleting))
            IconButton(
              icon: Icon(Icons.done_all),
              onPressed: _marcarSeleccionadasComoLeidas,
              tooltip: 'Marcar seleccionadas como leídas',
            ),

          if (notifications.isNotEmpty && !(_isLoading || _isDeleting))
            IconButton(
              icon: Icon(Icons.delete_forever_outlined),
              onPressed: selectedNotifications.isNotEmpty
                  ? _eliminarSeleccionadas
                  : _eliminarTodasNotificaciones,
              tooltip: selectedNotifications.isNotEmpty
                  ? 'Eliminar seleccionadas'
                  : 'Eliminar todas las notificaciones',
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _refreshNotificaciones,
          child: (_isLoading || _isDeleting)
              ? LoadingScreen(message: 'Cargando notificaciones...')
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  itemCount: keys.length + 2,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return CheckboxListTile(
                        value: someSelected ? null : allSelected,
                        tristate: true,
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                        ),
                        title: const Text('Seleccionar todas'),
                        subtitle: selectedCount > 0
                            ? Text(
                                '$selectedCount de ${notifications.length} seleccionadas',
                              )
                            : null,
                        onChanged: (_) => _toggleAll(notifications),
                      );
                    }

                    final groupIndex = index - 1;
                    if (groupIndex < keys.length) {
                      final key = keys[groupIndex];
                      final items = grouped[key]!;

                      return WidgetsContainer(
                        padding: EdgeInsetsGeometry.all(4),
                        title: key,
                        showDivider: false,
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
        ),
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
      onTap: () {
        if (selectedNotifications.isNotEmpty) {
          _toggleSelection(notif.id!);
        } else {
          _verDetallesNotificacion(notif.id!);
        }
      },
      onDelete: () => _eliminarNotificacion(notif.id!),
      onLongPress: () => _toggleSelection(notif.id!),
      isSelected: selectedNotifications.contains(notif.id!),
    );
  }
}
