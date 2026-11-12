import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:control_financiero/core/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:control_financiero/app/app.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import 'dart:async';
import 'package:control_financiero/core/utils/app_logger.dart';
import 'package:control_financiero/features/actualizaciones/update_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    unawaited(
      AppLogger.recordError(
        'Error de Flutter',
        details.exception,
        details.stack ?? StackTrace.current,
      ),
    );
  };
  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    unawaited(AppLogger.recordError('Error no controlado', error, stack));
    return true;
  };

  try {
    await AppLogger.log('Inicio de la aplicación');

    await Hive.initFlutter();
    if (Platform.isAndroid) {
      try {
        // Eliminar cualquier archivo pendiente (interrupcion de la descarga)
        await UpdateService().cleanDownloads();
      } catch (_) {
        // Continua con la ejecucion normal de la app
      }
    }
    await NotificationService.init();

    final NotificationAppLaunchDetails? details;
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Guayaquil'));

    if (Platform.isAndroid || Platform.isIOS) {
      details = await NotificationService.getLaunchDetails();
    } else {
      details = null;
    }

    runApp(App(notificationLaunchDetails: details));
  } catch (error, stack) {
    await AppLogger.recordError('Error al iniciar la aplicación', error, stack);
    rethrow;
  }
}
