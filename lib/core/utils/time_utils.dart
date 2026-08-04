import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

String formatRelativeTime(DateTime date) {
  return timeago.format(date, locale: 'es');
}

String formatTimeFromDateTime(BuildContext context, DateTime dateTime) {
  final formated = TimeOfDay.fromDateTime(dateTime);
  return formated.format(context);
}
