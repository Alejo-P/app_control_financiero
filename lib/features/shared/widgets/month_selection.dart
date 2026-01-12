import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:flutter/material.dart';

class MonthSelection extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime>? onMonthChanged;
  
  const MonthSelection({
    super.key,
    required this.initialDate,
    this.onMonthChanged
  });

  @override
  State<MonthSelection> createState() => _MonthSelectionState();
}

class _MonthSelectionState extends State<MonthSelection> {
  late DateTime selectedDate = widget.initialDate;

  String get monthYearLabel {
    return formatMonthYear(selectedDate);
  }

  void changeMonth(int offset) {
    setState(() {
      selectedDate = DateTime(
        selectedDate.year,
        selectedDate.month + offset,
      );
    });

    // Notificar el cambio de mes si se proporcionó un callback
    if (widget.onMonthChanged != null) {
      widget.onMonthChanged!(selectedDate);
    }
  }

  void returnToday() {
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
    return Card(
        color: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  InkWell(
                      onTap: () => changeMonth(-1),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.grey.shade500,
                            size: 16,
                          )
                      )
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                            monthYearLabel,
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold
                            )
                        ),
                        const SizedBox(height: 2),
                        InkWell(
                          onTap: returnToday,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Hoy',
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          )
                        )
                      ]
                  ),
                  InkWell(
                      onTap: () => changeMonth(1),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey,
                            size: 16,
                          )
                      )
                  )
                ]
            )
        )
    );
  }
}

