import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:flutter/material.dart';

class MonthSelection extends StatefulWidget {
  final DateTime initialDate;
  final bool isLoading;
  final ValueChanged<DateTime>? onMonthChanged;

  const MonthSelection({
    super.key,
    required this.initialDate,
    this.isLoading = false,
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

  DateTime getMinAllowedDate() {
    final now = currentDateTime;
    return DateTime(now.year - 3, now.month);
  }

  bool isBeforeLimit(DateTime selectedDate) {
    final minDate = getMinAllowedDate();
    return normalizeDate(selectedDate).isBefore(minDate);
  }

  bool isAtLimit(DateTime selectedDate) {
    final minDate = getMinAllowedDate();
    return isSameMonth(selectedDate, minDate);
  }

  bool canGoBack(DateTime selectedDate) {
    final minDate = getMinAllowedDate();
    final current = normalizeDate(selectedDate);

    return current.isAfter(minDate);
  }

  bool isFutureMonth(DateTime selectedDate) {
    final now = currentDateTime;
    return normalizeDate(selectedDate).isAfter(normalizeDate(now));
  }

  bool isLimitFutureMonth(DateTime selectedDate) {
    return isCurrentMonth(selectedDate) || isFutureMonth(selectedDate);
  }

  bool isLimitPastMonth(DateTime selectedDate) {
    return (isBeforeLimit(selectedDate) || isAtLimit(selectedDate)) &&
        !canGoBack(selectedDate);
  }

  void changeMonth(int offset) {
    // Validacion extra
    if (widget.isLoading) {
      return; // No permitir cambiar mes si está cargando
    }

    if (offset < 0 && isLimitPastMonth(selectedDate)) {
      return; // No permitir retroceder más allá del límite
    }

    if (offset > 0 && isLimitFutureMonth(selectedDate)) {
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
    if (widget.isLoading) {
      return; // No permitir cambiar mes si está cargando
    }

    if (isCurrentMonth(selectedDate)) {
      return; // Ya estamos en el mes actual
    }
    // Solo tomar el año y mes actual para evitar problemas con días que no existen en meses anteriores
    final now = currentDateTime;
    final today = DateTime(now.year, now.month);

    setState(() {
      selectedDate = today;
    });

    // Notificar el cambio de mes si se proporcionó un callback
    if (widget.onMonthChanged != null) {
      widget.onMonthChanged!(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFuture = isLimitFutureMonth(selectedDate);
    final isCurrent = isCurrentMonth(selectedDate);
    final isLimitPast = isLimitPastMonth(selectedDate);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundThemeColor = Theme.of(context).colorScheme.surface;

    return Card(
      color: backgroundThemeColor,
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
              onPressed: (widget.isLoading || isLimitPast)
                  ? null
                  : () => changeMonth(-1),
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: (widget.isLoading || isLimitPast)
                    ? Colors.grey
                    : Colors.blueAccent,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  monthYearLabel,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                InkWell(
                  onTap: (isCurrent || widget.isLoading) ? null : returnToday,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Ir a mes actual',
                      style: TextStyle(
                        color: (isCurrent || widget.isLoading)
                            ? Colors.grey[600]
                            : Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: (widget.isLoading || isFuture)
                  ? null
                  : () => changeMonth(1),
              icon: Icon(
                Icons.arrow_forward_ios,
                color: (widget.isLoading || isFuture)
                    ? Colors.grey
                    : Colors.blueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
