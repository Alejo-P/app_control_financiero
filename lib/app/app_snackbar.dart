import 'package:flutter/material.dart';

class AppSnackbar {
  static void error(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.error_outline,
      backgroundColor: Colors.red,
      durationSeconds: 4,
    );
  }

  static void info(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.info_outline,
      backgroundColor: Colors.blue,
      durationSeconds: 4,
    );
  }

  static void success(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle_outline,
      backgroundColor: Colors.green,
      durationSeconds: 4,
    );
  }

  static void warning(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.warning_amber_outlined,
      backgroundColor: Colors.orange,
      durationSeconds: 4,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    Color backgroundColor = Colors.red,
    required int durationSeconds,
  }) {
    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          margin: const EdgeInsets.all(16),
          behavior: SnackBarBehavior.floating,
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: backgroundColor,
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(message, style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          showCloseIcon: true,
          closeIconColor: Colors.white,
          duration: Duration(seconds: durationSeconds),
        ),
      );
  }
}
