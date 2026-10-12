import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

String formatRelativeTime(DateTime date) {
  return timeago.format(date, locale: 'es');
}

String formatTimeFromDateTime(BuildContext context, DateTime dateTime) {
  return formatDeviceTime(context, TimeOfDay.fromDateTime(dateTime));
}

String formatDeviceTime(BuildContext context, TimeOfDay time) {
  final use24Hours = MediaQuery.alwaysUse24HourFormatOf(context);
  final minutes = time.minute.toString().padLeft(2, '0');
  if (use24Hours) {
    return '${time.hour.toString().padLeft(2, '0')}:$minutes';
  }
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final period = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minutes $period';
}

TimeOfDay getTimeFromDateTime(DateTime dateTime) {
  return TimeOfDay.fromDateTime(dateTime);
}
