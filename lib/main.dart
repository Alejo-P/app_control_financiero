import 'package:control_financiero/core/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:control_financiero/app/app.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  await Hive.initFlutter();
  await NotificationService.init();

  final NotificationAppLaunchDetails? details;

  if (Platform.isAndroid || Platform.isIOS) {
    details = await NotificationService.getLaunchDetails();
  } else {
    details = null;
  }

  runApp(App(notificationLaunchDetails: details));
}
