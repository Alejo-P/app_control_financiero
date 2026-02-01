import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class Movimiento {
  final int? id;
  final String title;
  final int categoryID;
  final double amount;
  final DateTime date;
  final TimeOfDay time;
  final String note;

  Movimiento({
    this.id,
    required this.title,
    required this.categoryID,
    required this.amount,
    required this.date,
    required this.time,
    this.note = '',
  });

  Movimiento copyWith({
    int? id,
    String? title,
    int? categoryID,
    double? amount,
    DateTime? date,
    TimeOfDay? time,
    String? note,
  }) {
    return Movimiento(
      id: id ?? this.id,
      title: title ?? this.title,
      categoryID: categoryID ?? this.categoryID,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      time: time ?? this.time,
      note: note ?? this.note,
    );
  }

  // Factory constructor to create a Movimiento from JSON
  factory Movimiento.fromMap(Map<String, dynamic> map) {
    return Movimiento(
      id: map['id'] != null ? map['id'] as int : null,
      title: map['title'],
      categoryID: map['category_id'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      time: TimeOfDay(
        hour: int.parse(map['time'].split(':')[0]),
        minute: int.parse(map['time'].split(':')[1]),
      ),
      note: map['note'],
    );
  }

  // Method to convert a Movimiento to JSON
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category_id': categoryID,
      'amount': amount,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      'note': note,
    };
  }

  // Funtion for debugging purposes
  @override
  String toString() {
    return 'Movimiento{id: $id, title: $title, categoryID: $categoryID, amount: $amount, date: $date, time: $time, note: $note}';
  }
}
