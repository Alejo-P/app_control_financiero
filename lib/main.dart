import 'package:control_financiero/core/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:control_financiero/app/app.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  await NotificationService.init();

  final details =
      await NotificationService.getLaunchDetails();

  runApp(App(notificationLaunchDetails: details));
}
