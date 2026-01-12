import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:flutter/material.dart';

class MonthSelection extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime>? onMonthChanged;

  const MonthSelection({
    super.key,
    required this.initialDate,
    this.onMonthChanged,
  });

  @override
  State<MonthSelection> createState() => _MonthSelectionState();
}

class _MonthSelectionState extends State<MonthSelection> {
  late DateTime selectedDate = widget.initialDate;

  String get monthYearLabel {
    return formatMonthYear(selectedDate);
  }

  bool isFutureMonth(DateTime selectedDate) {
    final now = DateTime.now();
    final nextDate = DateTime(selectedDate.year, selectedDate.month + 1);
    return (nextDate.year > now.year) ||
        (nextDate.year == now.year && nextDate.month > now.month);
  }

  bool isCurrentMonth() {
    final now = DateTime.now();
    return (selectedDate.year == now.year && selectedDate.month == now.month);
  }

  void changeMonth(int offset) {
    if (offset > 0 && isFutureMonth(selectedDate)) {
      return; // No permitir avanzar a meses futuros
    }

    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month + offset);
    });

    // Notificar el cambio de mes si se proporcionó un callback
    if (widget.onMonthChanged != null) {
      widget.onMonthChanged!(selectedDate);
    }
  }

  void returnToday() {
    if (isCurrentMonth()) {
      return; // Ya estamos en el mes actual
    }

    setState(() {
      selectedDate = DateTime.now();
    });

    // Notificar el cambio de mes si se proporcionó un callback
    if (widget.onMonthChanged != null) {
      widget.onMonthChanged!(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFuture = isFutureMonth(selectedDate);
    final isCurrent = isCurrentMonth();
    return Card(
      color: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          textBaseline: TextBaseline.alphabetic,
          children: [
            IconButton(
              onPressed: () => changeMonth(-1),
              icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.blueAccent,
                ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  monthYearLabel,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                InkWell(
                  onTap: isCurrent ? null : returnToday,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Ir a hoy',
                      style: TextStyle(
                        color: isCurrent ? Colors.grey[600] : Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: isFuture ? null : () => changeMonth(1),
              icon: Icon(
                  Icons.arrow_forward_ios,
                  color: isFuture ? Colors.grey : Colors.blueAccent,
                ),
            ),
          ],
        ),
      ),
    );
  }
}
