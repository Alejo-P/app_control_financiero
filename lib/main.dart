import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:control_financiero/core/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:control_financiero/app/app.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
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
}
