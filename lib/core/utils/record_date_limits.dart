import 'package:control_financiero/core/utils/date_utils.dart';

class RecordDateLimits {
  final DateTime first;
  final DateTime last;

  const RecordDateLimits(this.first, this.last);

  factory RecordDateLimits.movimientos({DateTime? now}) {
    final reference = now ?? currentDateTime;
    final today = DateTime(reference.year, reference.month, reference.day);
    final year = today.year - 3;
    final lastDay = DateTime(year, today.month + 1, 0).day;
    return RecordDateLimits(
      DateTime(year, today.month, today.day > lastDay ? lastDay : today.day),
      today,
    );
  }

  factory RecordDateLimits.presupuestos({DateTime? now}) {
    final reference = now ?? currentDateTime;
    return RecordDateLimits(
      DateTime(reference.year - 1, reference.month),
      DateTime(reference.year + 1, reference.month),
    );
  }

  bool contains(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return !day.isBefore(first) && !day.isAfter(last);
  }

  DateTime clamp(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    if (day.isBefore(first)) return first;
    if (day.isAfter(last)) return last;
    return day;
  }
}
