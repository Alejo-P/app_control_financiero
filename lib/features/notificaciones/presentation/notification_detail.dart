import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/features/notificaciones/models/notificacion.dart';
import 'package:control_financiero/features/shared/widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationDetail extends StatefulWidget {
  const NotificationDetail({super.key});

  @override
  State<NotificationDetail> createState() => _NotificationDetailState();
}

class _NotificationDetailState extends State<NotificationDetail> {
  Notificacion? notif;
  bool isLoading = false;
  bool _loaded = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;

    final id = ModalRoute.of(context)!.settings.arguments as int;

    _load(id);
    _loaded = true;
  }

  Future<void> _load(int id) async {
    final appState = context.read<AppState>();

    setState(() {
      isLoading = true;
    });

    final result = await appState.getNotificacionById(id);

    if (result != null) {
      await appState.marcarNotifLeida(result);
    }

    if (!mounted) return;

    setState(() {
      notif = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? LoadingScreen(message: 'Cargando detalles de la notificación...')
        : notif == null
        ? _EmptyNotificacion()
        : Scaffold(
            appBar: AppBar(title: Text('Detalle')),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(notif!.description),
            ),
          );
  }
}

class _EmptyNotificacion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
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
            'No se encontro la notificación.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          Text(
            'Posiblemente se busco una notificacion que no existe o fue eliminada.',
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
