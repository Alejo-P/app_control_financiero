import 'package:control_financiero/core/utils/relative_time.dart';
import 'package:control_financiero/features/notificaciones/models/notificacion.dart';
import 'package:flutter/material.dart';

class NotificacionDetailCard extends StatelessWidget {
  final Notificacion notif;

  const NotificacionDetailCard({super.key, required this.notif});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: notif.isRead ? Colors.grey.shade400 : Colors.orange,
          width: 1.5,
        ),
      ),
      elevation: 3,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Header (icon + title + estado)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: notif.iconColor.withOpacity(0.15),
                  child: Icon(notif.iconData, color: notif.iconColor),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notif.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        notif.createdAt != null
                            ? formatRelativeTime(notif.createdAt!)
                            : '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // 🔴 Indicador no leído
                if (!notif.isRead)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // 🔹 Descripción
            if (notif.description.isNotEmpty)
              Text(notif.description, style: theme.textTheme.bodyMedium),

            // 🔹 Extra data (si existe)
            if (notif.extraData != null && notif.extraData!.isNotEmpty) ...[
              const SizedBox(height: 16),

              Divider(),

              const SizedBox(height: 8),

              Text('Detalles adicionales', style: theme.textTheme.labelLarge),

              const SizedBox(height: 8),

              ...notif.extraData!.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        '${entry.key}: ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(child: Text(entry.value.toString())),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
