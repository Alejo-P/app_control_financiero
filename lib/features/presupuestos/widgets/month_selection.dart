import 'package:flutter/material.dart';
import '../../../core/utils/date_utils.dart';

class MonthSelection extends StatefulWidget {
  const MonthSelection({super.key});

  @override
  _MonthSelectionState createState() => _MonthSelectionState();
}

class _MonthSelectionState extends State<MonthSelection> {
  DateTime selectedDate = DateTime.now();

  String get monthYearLabel {
    final monthName = monthNames[selectedDate.month - 1];
    return '$monthName ${selectedDate.year}';
  }

  void changeMonth(int offset) {
    setState(() {
      selectedDate = DateTime(
        selectedDate.year,
        selectedDate.month + offset,
      );
    });
  }

  void returnToday() {
    setState(() {
      selectedDate = DateTime.now();
    });
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

