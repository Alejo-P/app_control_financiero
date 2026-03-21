import 'package:timeago/timeago.dart' as timeago;

String formatRelativeTime(DateTime date) {
  return timeago.format(date, locale: 'es');
}
